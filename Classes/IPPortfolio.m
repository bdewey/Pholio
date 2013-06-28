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

#import <Security/Security.h>
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
@synthesize layoutStyle = layoutStyle_;
@synthesize version = version_;
@synthesize imageOptimizationVersion = imageOptimizationVersion_;

-(id)init {
  if ((self = [super init]) != nil) {
    sets_ = [[NSMutableArray alloc] init];
    
    //
    //  Start with a random version number.
    //  This reduced the likelihood of incorrect matches of different
    //  portfolios.
    //
    
    SecRandomCopyBytes(kSecRandomDefault, sizeof(version_), (uint8_t *)(&version_));
  }
  return self;
}


+ (IPPortfolio *)portfolioWithSets:(IPSet *)firstSet, ... {
  
  IPPortfolio *portfolio = [[IPPortfolio alloc] init];
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
    self.imageOptimizationVersion = [aDecoder decodeIntegerForKey:kIPPortfolioImageOptimizationVersion];
    self.layoutStyle = [aDecoder decodeIntegerForKey:kIPPortfolioLayoutStyle];
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
  [aCoder encodeInteger:imageOptimizationVersion_ forKey:kIPPortfolioImageOptimizationVersion];
  [aCoder encodeInteger:layoutStyle_ forKey:kIPPortfolioLayoutStyle];
  
  //
  //  Bump the version before encoding.
  //
  
  version_++;
  [aCoder encodeInteger:version_ forKey:kIPPortfolioVersion];
}

#pragma mark NSCopying

-(id)copyWithZone:(NSZone *)zone {
  IPPortfolio *copy = [[IPPortfolio allocWithZone:zone] init];
  copy.title = [title_ copyWithZone:zone];
  copy.sets = [[NSMutableArray alloc] initWithArray:sets_ copyItems:YES];
  copy.backgroundImageName = [backgroundImageName_ copyWithZone:zone];
  copy.fontColor = [fontColor_ copy];
  copy.layoutStyle = layoutStyle_;
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
  NSString *documentsDirectory = paths[0];
  return [documentsDirectory stringByAppendingPathComponent:@"portfolio"];
}

//
//  Saves the portfolio object
//

-(void)savePortfolioToPath:(NSString *)portfolioPath {

  NSMutableData *data = [[NSMutableData alloc] init];
  NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
  [archiver encodeObject:self forKey:kAppDelegatePortfolio];
  [archiver finishEncoding];
  [data writeToFile:portfolioPath atomically:YES];
}

//
//  Private routine to fix up all of the file names in the portfolio
//

-(void)fixPhotoFileNames {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *docDirectory = paths[0];
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
          
          DDLogVerbose(@"%s -- deleting page from set %@; image file %@ does not exist",
                     __PRETTY_FUNCTION__,
                     theSet.title,
                     thePhoto.filename);
          [photosToDelete addObject:thePhoto];
          continue;
        }
        
        //
        //  Things that are in the model but have no thumbnail need to get 
        //  updated. Make sure these get optimized.
        //
        
        fileExists = [[NSFileManager defaultManager] fileExistsAtPath:thePhoto.thumbnailFilename isDirectory:&isDirectory];
        if (!fileExists || isDirectory) {
          
          DDLogVerbose(@"%s -- marking page for optimization from set %@: no thumbnail",
                     __PRETTY_FUNCTION__,
                     theSet.title);
          thePhoto.optimizedVersion = NSNotFound;
          self.imageOptimizationVersion = NSNotFound;
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
    
    IPSet *foundSet = [self setWithFoundPictures];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
      
      completion(foundSet);
    });
  });
}

//
//  Scans the working directory for files that look like pictures yet aren't
//  in the portfolio. Sticks them in a new portfolio at the end.
//

-(IPSet *)setWithFoundPictures {

  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *docDirectory = paths[0];
  NSError *error;
  NSArray *imageExtensions = @[@"jpg", @"jpeg", @"png"];
  NSArray *exclusionList   = @[kBackgroundFilename, kBrandingFilename];
  
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
    
    IPSet *newSet = [[IPSet alloc] init];
    newSet.title = kFoundPicturesGalleryName;
    for (NSString *filename in newFilenames) {
      IPPage *newPage = [[IPPage alloc] init];
      [newSet.pages addObject:newPage];
      IPPhoto *newPhoto = [[IPPhoto alloc] init];
      newPhoto.filename = [docDirectory stringByAppendingPathComponent:filename];
      newPhoto.title = [filename stringByDeletingPathExtension];
      DDLogVerbose(@"%s -- Created new photo. Filename = %@, thumbnail = %@", 
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
  NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
  IPPortfolio *portfolio = [unarchiver decodeObjectForKey:kAppDelegatePortfolio];
  [unarchiver finishDecoding];
  if (portfolio == nil) {
    portfolio = [[IPPortfolio alloc] init];    
  }
  [portfolio fixPhotoFileNames];
  return portfolio;
}

#pragma mark - Properties

- (UIColor *)navigationColor {
  
  if (navigationColor_ == nil) {
    
    navigationColor_ = [UIColor blackColor];
  }
  return navigationColor_;
}

- (BOOL)setDefaultNavigationColor:(UIColor *)navigationColor {
  
  if (navigationColor_ == nil) {
    
    navigationColor_ = navigationColor;
    return YES;
  }
  return NO;
}

- (UIFont *)titleFont {
  
  if (titleFont_ == nil) {
    
    titleFont_ = [UIFont boldSystemFontOfSize:kIPPortfolioTitleFontSize];
  }
  return titleFont_;
}

- (BOOL)setDefaultTitleFont:(UIFont *)titleFont {
  
  if (!titleFont_) {
    
    titleFont_ = titleFont;
    return YES;
  }
  return NO;
}

- (UIFont *)textFont {
  
  if (textFont_ == nil) {
    
    textFont_ = [UIFont systemFontOfSize:[UIFont systemFontSize]];
  }
  return textFont_;
}

- (BOOL)setDefaultTextFont:(UIFont *)textFont {
  
  if (!textFont_) {
    
    textFont_ = textFont;
    return YES;
  }
  return NO;
}

#pragma mark -
#pragma mark Key-Value Coding

-(NSUInteger)countOfSets {
  return [sets_ count];
}

-(IPSet *)objectInSetsAtIndex:(NSUInteger)index {
  return (IPSet *)sets_[index];
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
