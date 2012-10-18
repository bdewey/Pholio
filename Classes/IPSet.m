//
//  IPSet.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 8/5/10.
//  Copyright 2010 Brian's Brain. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "IPSet.h"


@implementation IPSet

@synthesize title = title_;
@synthesize pages = pages_;
@synthesize parent = parent_;
@dynamic thumbnail;

-(id)init {
  if ((self = [super init]) != nil) {
    pages_ = [[NSMutableArray alloc] init];
  }
  return self;
}


////////////////////////////////////////////////////////////////////////////////
//
//  Convenience constructor.
//

+ (IPSet *)setWithPages:(IPPage *)firstPage, ... {
  
  IPSet *set = [[IPSet alloc] init];
  set.title = kNewGalleryName;
  id eachPage;
  va_list argumentList;
  if (firstPage != nil) {
    
    [set appendPage:firstPage];
    va_start(argumentList, firstPage);
    while ((eachPage = va_arg(argumentList, IPPage *)) != nil) {
      
      [set appendPage:eachPage];
    }
    va_end(argumentList);
  }
  return set;
}

#pragma mark Debugging support

////////////////////////////////////////////////////////////////////////////////
//
//  Object description
//

- (NSString *)description {
  
  return [NSString stringWithFormat:@"%@: %d page(s)",
          self.title,
          [self countOfPages]];
}

#pragma mark thumbnailFilename

//
//  |thumbnailFilename| accessor. Gets the thumbnailFilename from
//  the first photo in the first page.
//
//  One important design note: Even though this is a completely synthesized
//  property, we want changes to be observable. Throughout the rest of the
//  code I send willChangeValueForKey: and didChangeValueForKey: messages when
//  it looks like this property could change.
//

- (NSString *)thumbnailFilename {
  if ([self countOfPages] > 0) {
    IPPage *firstPage = [self objectInPagesAtIndex:0];
    if ([firstPage countOfPhotos] > 0) {
      return [firstPage valueForKeyPath:kIPSetThumbnailFilename forPhoto:0];
    }
  }
  return nil;
}

//
//  Gets the thumbnail image for the set. Right now, that's just the thumbnail
//  for the first photo of the first page.
//

- (UIImage *)thumbnail {
  
  if ([self countOfPages] > 0) {
    IPPage *firstPage = [self objectInPagesAtIndex:0];
    if ([firstPage countOfPhotos] > 0) {
      IPPhoto *firstPhoto = [firstPage objectInPhotosAtIndex:0];
      return firstPhoto.thumbnail;
    }
  }
  return nil;
}

//
//  |IPPhoto| objects reach up through the hierarchy and send this message
//  to the grandparent object when the image changes.
//
//  This is hacky but easy. I'd feel better about having the IPSet register
//  as an observer for the IPPhoto object, but with those pesky IPPage
//  objects in the middle it will get really complicated to maintain the right
//  observing relationship. (What happens if the page object adds or reorders
//  pages?) That will confuse me know, but at least it's not dangerous with leaving
//  observers hanging around when I don't expect them.
//

- (void)photoInSetHasChanged:(IPPhoto *)photo {
  if ([self countOfPages] > 0) {
    IPPage *page = [self objectInPagesAtIndex:0];
    if (([page countOfPhotos] > 0) && ([page objectInPhotosAtIndex:0] == photo)) {
      [self willChangeValueForKey:kIPSetThumbnailFilename];
      [self didChangeValueForKey:kIPSetThumbnailFilename];
    }
  }
}

#pragma mark NSCoding

-(id)initWithCoder:(NSCoder *)aDecoder {
  if ((self = [super init]) != nil) {
    self.title = [aDecoder decodeObjectForKey:kIPSetTitle];
    self.pages = [aDecoder decodeObjectForKey:kIPSetPages];
    if (self.pages == nil) {
      pages_ = [[NSMutableArray alloc] init];
    }
    [self.pages makeObjectsPerformSelector:@selector(setParent:) withObject:self];
  }
  return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:title_ forKey:kIPSetTitle];
  [aCoder encodeObject:pages_ forKey:kIPSetPages];
}

#pragma mark NSCopying

-(id)copyWithZone:(NSZone *)zone {
  IPSet *copy = [[IPSet allocWithZone:zone] init];
  copy.title  = [title_ copyWithZone:zone];
  copy.pages = [[NSMutableArray alloc] initWithArray:pages_ copyItems:YES];
  
  //
  //  Fix up the parent pointers
  //
  
  [copy.pages makeObjectsPerformSelector:@selector(setParent:) withObject:copy];
  return copy;
}

#pragma mark Key-value compliance for |pages| collection

-(NSUInteger)countOfPages {
  return [pages_ count];
}

-(IPPage *)objectInPagesAtIndex:(NSUInteger)index {
  return (IPPage *)[pages_ objectAtIndex:index];
}

-(void)insertObject:(IPPage *)page inPagesAtIndex:(NSUInteger) index {
  if (index == 0) {
    [self willChangeValueForKey:kIPSetThumbnailFilename];
  }
  [pages_ insertObject:page atIndex:index];
  page.parent = self;
  if (index == 0) {
    [self didChangeValueForKey:kIPSetThumbnailFilename];
  }
}

-(void)removeObjectFromPagesAtIndex:(NSUInteger)index {
  IPPage *page = [self objectInPagesAtIndex:index];
  [page setParent:nil];
  if (index == 0) {
    [self willChangeValueForKey:kIPSetThumbnailFilename];
  }
  [pages_ removeObjectAtIndex:index];
  if (index == 0) {
    [self didChangeValueForKey:kIPSetThumbnailFilename];
  }
}

-(void)appendPage:(IPPage *)page {
  [self insertObject:page inPagesAtIndex:[self countOfPages]];
}

#pragma mark File Management

-(void)deletePhotoFiles {
  [self.pages makeObjectsPerformSelector:@selector(deletePhotoFiles)];
}

#pragma mark - IPPasteboardObjectDelegate

////////////////////////////////////////////////////////////////////////////////
//
//  We're about to put this set into a pasteboard object. Grab all
//  of the photo data.
//

- (void)pasteboardObjectWillArchive:(IPPasteboardObject *)pasteboardObject {
  
  [self.pages makeObjectsPerformSelector:@selector(pasteboardObjectWillArchive:) 
                              withObject:pasteboardObject];
}

////////////////////////////////////////////////////////////////////////////////
//
//  We just got this set out from a pasteboard object. Create unique photo
//  files from the archived data in the pasteboard object.
//

- (void)pasteboardObjectDidUnarchive:(IPPasteboardObject *)pasteboardObject {
  
  [self.pages makeObjectsPerformSelector:@selector(pasteboardObjectDidUnarchive:) 
                              withObject:pasteboardObject];
}

@end
