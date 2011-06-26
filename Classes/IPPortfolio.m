//
//  IPPortfolio.m
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

#import "IPPortfolio.h"

#define kAppDelegatePortfolio           @"portfolio"

@implementation IPPortfolio

@synthesize title = title_;
@synthesize sets = sets_;
@synthesize backgroundImageName = backgroundImageName_;
@synthesize navigationColor = navigationColor_;
@synthesize fontColor = fontColor_;
@synthesize titleFont = titleFont_;
@synthesize textFont = textFont_;
@synthesize version = version_;

-(id)init {
  if ((self = [super init]) != nil) {
    sets_ = [[NSMutableArray alloc] init];
    
    //
    //  Put random 15 bits in the upper part of the version number.
    //  This reduced the likelihood of incorrect matches of different
    //  portfolios.
    //
    
    version_ = rand() & 0x7FFF0000;
  }
  return self;
}

-(void)dealloc {
  [title_ release];
  [sets_ release];
  [backgroundImageName_ release];
  [navigationColor_ release];
  [fontColor_ release];
  [titleFont_ release];
  [textFont_ release];
  [super dealloc];
}

+ (IPPortfolio *)portfolioWithSets:(IPSet *)firstSet, ... {
  
  IPPortfolio *portfolio = [[[IPPortfolio alloc] init] autorelease];
  va_list argList;
  IPSet *eachSet;
  
  if (firstSet != nil) {
    [portfolio appendSet:firstSet];
    va_start(argList, firstSet);
    while ((eachSet = va_arg(argList, IPSet *)) != nil) {
      
      [portfolio appendSet:eachSet];
    }
    va_end(argList);
  }
  
  return portfolio;
}

- (void)didReceiveMemoryWarning {
  
  [self.sets makeObjectsPerformSelector:@selector(didReceiveMemoryWarning)];
}

#pragma mark NSCoding

-(id)initWithCoder:(NSCoder *)aDecoder {
  if ((self = [super init]) != nil) {
    self.title = [aDecoder decodeObjectForKey:kIPPortfolioTitle];
    self.sets  = [aDecoder decodeObjectForKey:kIPPortfolioSets];
    if (sets_ == nil) {
      sets_ = [[NSMutableArray alloc] init];
    }
    [self.sets makeObjectsPerformSelector:@selector(setParent:) withObject:self];
    self.backgroundImageName = [aDecoder decodeObjectForKey:kIPPortfolioBackgroundImageName];
    self.navigationColor = [aDecoder decodeObjectForKey:kIPPortfolioNavigationColor];
    self.fontColor = [aDecoder decodeObjectForKey:kIPPortfolioFontColor];
    if (fontColor_ == nil) {
      self.fontColor = [UIColor whiteColor];
    }
    self.titleFont = [aDecoder decodeObjectForKey:kIPPortfolioTitleFont];
    self.textFont = [aDecoder decodeObjectForKey:kIPPortfolioTextFont];
    version_ = [aDecoder decodeIntegerForKey:kIPPortfolioVersion];
  }
  return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:title_ forKey:kIPPortfolioTitle];
  [aCoder encodeObject:sets_ forKey:kIPPortfolioSets];
  [aCoder encodeObject:backgroundImageName_ forKey:kIPPortfolioBackgroundImageName];
  [aCoder encodeObject:navigationColor_ forKey:kIPPortfolioNavigationColor];
  [aCoder encodeObject:fontColor_ forKey:kIPPortfolioFontColor];
  [aCoder encodeObject:titleFont_ forKey:kIPPortfolioTitleFont];
  [aCoder encodeObject:textFont_ forKey:kIPPortfolioTextFont];
  
  //
  //  Bump the version before encoding.
  //
  
  version_++;
  [aCoder encodeInteger:version_ forKey:kIPPortfolioVersion];
}

#pragma mark NSCopying

-(id)copyWithZone:(NSZone *)zone {
  IPPortfolio *copy = [[IPPortfolio allocWithZone:zone] init];
  copy.title = [[title_ copyWithZone:zone] autorelease];
  copy.sets = [[[NSMutableArray alloc] initWithArray:sets_ copyItems:YES] autorelease];
  copy.backgroundImageName = [[backgroundImageName_ copyWithZone:zone] autorelease];
  copy.fontColor = [[fontColor_ copy] autorelease];
  return copy;
}

#pragma mark Debugging support

- (NSString *)description {
  
  return [NSString stringWithFormat:@"%@: %@", self.title, [self.sets description]];
}

#pragma mark Data persistance

//
//  Gets the path to where the portfolio object gets persisted.
//

+(NSString *)defaultPortfolioPath {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  return [documentsDirectory stringByAppendingPathComponent:@"portfolio"];
}

//
//  Saves the portfolio object
//

-(void)savePortfolioToPath:(NSString *)portfolioPath {

  NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
  NSKeyedArchiver *archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
  [archiver encodeObject:self forKey:kAppDelegatePortfolio];
  [archiver finishEncoding];
  [data writeToFile:portfolioPath atomically:YES];
}

//
//  Private routine to fix up all of the file names in the portfolio
//

-(void)fixPhotoFileNames {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *docDirectory = [paths objectAtIndex:0];
  BOOL fileExists, isDirectory;
  NSMutableSet *photosToDelete = [NSMutableSet setWithCapacity:1];
  
  //
  //  Make sure we have a "documents" directory
  //
  
  [IPPhoto createThumbnailDirectory];
  
  for (IPSet *theSet in self.sets) {
    for (IPPage *thePage in theSet.pages) {
      for (IPPhoto *thePhoto in thePage.photos) {
        
        //
        //  Make sure file names are always rooted in this app's doc directory.
        //
        
        thePhoto.filename = [docDirectory stringByAppendingPathComponent:[thePhoto.filename lastPathComponent]];
        fileExists = [[NSFileManager defaultManager] fileExistsAtPath:thePhoto.filename isDirectory:&isDirectory];
        if (!fileExists || isDirectory) {
          
          _GTMDevLog(@"%s -- deleting page from set %@; image file %@ does not exist",
                     __PRETTY_FUNCTION__,
                     theSet.title,
                     thePhoto.filename);
          [photosToDelete addObject:thePhoto];
          continue;
        }
      }
    }
  }
  
  [photosToDelete enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
    IPPhoto *photo = (IPPhoto *)obj;
    IPPage *page = photo.parent;
    IPSet *set = page.parent;
    
    [page.photos removeObject:photo];
    if ([page countOfPhotos] == 0) {
      [set.pages removeObject:page];
    }
  }];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Look for found pictures asynchronously, then call back on the main thread
//  with the resulting set.
//

- (void)lookForFoundPicturesAsyncWithCompletion:(void(^)(IPSet *foundSet))completion {
  
  completion = [completion copy];
  dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  dispatch_async(defaultQueue, ^(void) {
    
    IPSet *foundSet = [[self setWithFoundPictures] retain];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
      
      completion(foundSet);
      [completion release];
      [foundSet release];
    });
  });
}

//
//  Scans the working directory for files that look like pictures yet aren't
//  in the portfolio. Sticks them in a new portfolio at the end.
//

-(IPSet *)setWithFoundPictures {

  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *docDirectory = [paths objectAtIndex:0];
  NSError *error;
  NSArray *imageExtensions = [NSArray arrayWithObjects:@"jpg", @"jpeg", @"png", nil];
  NSArray *exclusionList   = [NSArray arrayWithObjects:kBackgroundFilename, kBrandingFilename, nil];
  
  //
  //  Build up the set of all filenames that are in the portfolio.
  //
  
  NSMutableSet *filenamesInPortfolio = [NSMutableSet setWithCapacity:8];
  for (IPSet *theSet in self.sets) {
    for (IPPage *thePage in theSet.pages) {
      for (IPPhoto *thePhoto in thePage.photos) {
        
        if (thePhoto.filename != nil) {
          [filenamesInPortfolio addObject:[thePhoto.filename lastPathComponent]];
        }
      }
    }
  }
  
  //
  //  Get all files in docDirectory.
  //
  
  NSArray *filenamesInDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:docDirectory error:&error];
  NSMutableArray *newFilenames = [NSMutableArray arrayWithCapacity:8];
  for (NSString *filename in filenamesInDirectory) {
    if (![filenamesInPortfolio containsObject:[filename lastPathComponent]] &&
        [imageExtensions containsObject:[[filename pathExtension] lowercaseString]] &&
        ![exclusionList containsObject:[filename lastPathComponent]]) {
      [newFilenames addObject:filename];
    }
  }
  
  if ([newFilenames count] != 0) {
    
    //
    //  Put all "found" photographs into a new set.
    //
    
    IPSet *newSet = [[[IPSet alloc] init] autorelease];
    newSet.title = kFoundPicturesGalleryName;
    for (NSString *filename in newFilenames) {
      IPPage *newPage = [[[IPPage alloc] init] autorelease];
      [newSet.pages addObject:newPage];
      IPPhoto *newPhoto = [[[IPPhoto alloc] init] autorelease];
      newPhoto.filename = [docDirectory stringByAppendingPathComponent:filename];
      newPhoto.title = [filename stringByDeletingPathExtension];
      _GTMDevLog(@"%s -- Created new photo. Filename = %@, thumbnail = %@", 
            __PRETTY_FUNCTION__, 
            newPhoto.filename, 
            newPhoto.thumbnailFilename);
      [newPage.photos addObject:newPhoto];
    }
    return newSet;
  }
  return nil;
}

//
//  Loads the portfolio object.
//

+(IPPortfolio *)loadPortfolioFromPath:(NSString *)portfolioPath {

  NSData *data = [NSData dataWithContentsOfFile:portfolioPath];
  NSKeyedUnarchiver *unarchiver = [[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
  IPPortfolio *portfolio = [unarchiver decodeObjectForKey:kAppDelegatePortfolio];
  [unarchiver finishDecoding];
  if (portfolio == nil) {
    portfolio = [[[IPPortfolio alloc] init] autorelease];    
  }
  [portfolio fixPhotoFileNames];
  return portfolio;
}

#pragma mark - Properties

- (UIColor *)navigationColor {
  
  if (navigationColor_ == nil) {
    
    navigationColor_ = [[UIColor blackColor] retain];
  }
  return navigationColor_;
}

- (UIFont *)titleFont {
  
  if (titleFont_ == nil) {
    
    titleFont_ = [[UIFont boldSystemFontOfSize:kIPPortfolioTitleFontSize] retain];
  }
  return titleFont_;
}

- (UIFont *)textFont {
  
  if (textFont_ == nil) {
    
    textFont_ = [[UIFont systemFontOfSize:[UIFont systemFontSize]] retain];
  }
  return textFont_;
}

#pragma mark -
#pragma mark Key-Value Coding

-(NSUInteger)countOfSets {
  return [sets_ count];
}

-(IPSet *)objectInSetsAtIndex:(NSUInteger)index {
  return (IPSet *)[sets_ objectAtIndex:index];
}

-(void)insertObject:(IPSet *)set inSetsAtIndex:(NSUInteger)index {
  [set setParent:self];
  [sets_ insertObject:set atIndex:index];
}

-(void)appendSet:(IPSet *)set {
  
  [self insertObject:set inSetsAtIndex:[self countOfSets]];
}

-(void)removeObjectFromSetsAtIndex:(NSUInteger)index {
  [[self objectInSetsAtIndex:index] setParent:nil];
  [sets_ removeObjectAtIndex:index];
}


@end
