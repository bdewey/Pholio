//
//  IPPage.m
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

#import "IPPage.h"
#import "IPPhoto.h"

@implementation IPPage

@synthesize photos = photos_, parent = parent_;

//
//  Creates a page with one photo.
//

+ (IPPage *)pageWithPhoto:(IPPhoto *)photo {
  
  IPPage *page = [[IPPage alloc] init];
  [page insertObject:photo inPhotosAtIndex:0];
  return page;
}

//
//  Creates a page with one image.
//

+ (IPPage *)pageWithImage:(UIImage *)image {
 
  return [IPPage pageWithPhoto:[IPPhoto photoWithImage:image]];
}

+ (IPPage *)pageWithImage:(UIImage *)image andTitle:(NSString *)title {
  
  return [IPPage pageWithPhoto:[IPPhoto photoWithImage:image andTitle:title]];
}

+ (IPPage *)pageWithFilename:(NSString *)filename andTitle:(NSString *)title {
  
  return [IPPage pageWithPhoto:[IPPhoto photoWithFilename:filename andTitle:title]];
}

//
//  Object initialization. Note it doesn't let the photos property stay
//  nil.
//

-(id)init {
  if ((self = [super init]) != nil) {
    photos_ = [[NSMutableArray alloc] init];
  }
  return self;
}

//
//  Object deallocation.
//


#pragma mark NSCoding

//
//  Unarchives a page. Only strange bit is it will guarantee that there is
//  a non-nil photos array.
//

-(id)initWithCoder:(NSCoder *)aDecoder {
  if ((self = [super init]) != nil) {
    self.photos = [aDecoder decodeObjectForKey:kIPPagePhotos];
    if (self.photos == nil) {
      self.photos = [[NSMutableArray alloc] init];
    }
    [self.photos makeObjectsPerformSelector:@selector(setParent:) withObject:self];
  }
  return self;
}

//
//  Archives the page.
//

-(void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:self.photos forKey:kIPPagePhotos];
}

#pragma mark NSCopying

//
//  Copies the page. Note it does a deep copy of the photos array.
//

-(id)copyWithZone:(NSZone *)zone {
  IPPage *copy = [[IPPage allocWithZone:zone] init];
  copy.photos = [[NSMutableArray alloc] initWithArray:self.photos copyItems:YES];
  return copy;
}

#pragma mark Getting setting photo values

-(NSString *)valueForKeyPath:(NSString *)keyPath forPhoto:(NSUInteger)index {
  id photo = (self.photos)[index];
  return [photo valueForKeyPath:keyPath];
}

-(void)setValue:(id)value forKeyPath:(NSString *)keyPath forPhoto:(NSUInteger)index {
  id photo = (self.photos)[index];
  [photo setValue:value forKeyPath:keyPath];
}

#pragma mark File management

-(void)deletePhotoFiles {
  [self.photos makeObjectsPerformSelector:@selector(deletePhotoFiles)];
}

#pragma mark Key-Value Encoding

-(NSUInteger)countOfPhotos {
  return [self.photos count];
}

-(IPPhoto *)objectInPhotosAtIndex:(NSUInteger)index {
  return (self.photos)[index];
}

-(void)insertObject:(IPPhoto *)photo inPhotosAtIndex:(NSUInteger) index {
  photo.parent = self;
  [self.photos insertObject:photo atIndex:index];
}

-(void)removeObjectFromPhotosAtIndex:(NSUInteger)index {
  IPPhoto *photo = [self objectInPhotosAtIndex:index];
  [photo setParent:nil];
  [self.photos removeObjectAtIndex:index];
}

#pragma mark - IPPasteboardObjectDelegate

////////////////////////////////////////////////////////////////////////////////
//
//  We're about to get archived as part of a pasteboard object. Get the
//  image data of each photo and stick it in the pasteboard object.
//

- (void)pasteboardObjectWillArchive:(IPPasteboardObject *)pasteboardObject {
  
  _GTMDevAssert(pasteboardObject.imageDataDictionary != nil, 
                @"imageDictionary must not be nil");
  for (IPPhoto *photo in self.photos) {
    
    NSData *imageData = [NSData dataWithContentsOfFile:photo.filename];
    if (imageData) {
      (pasteboardObject.imageDataDictionary)[photo.filename] = imageData;
    }
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  We got unarchived. Unpack the image data. Each photo should have the same
//  image but a different filename at the end of this.
//

- (void)pasteboardObjectDidUnarchive:(IPPasteboardObject *)pasteboardObject {
  
  _GTMDevAssert(pasteboardObject.imageDataDictionary != nil, 
                @"imageDictionary must not be nil");
  for (IPPhoto *photo in self.photos) {

    NSString *oldFilename = photo.filename;
    NSData *data = (pasteboardObject.imageDataDictionary)[oldFilename];
    UIImage *image = [UIImage imageWithData:data];
    if (image != nil) {
      photo.filename = nil;
      photo.image = image;
    }
  }
}


@end
