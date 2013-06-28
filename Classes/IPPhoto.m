//
//  IPPhoto.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 8/5/10.
//  Copyright 2010 Brian Dewey. 
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

#import <ImageIO/ImageIO.h>
#import "IPPhoto.h"
#import "IPSet.h"
#import "UIImage+Alpha.h"
#import "UIImage+Resize.h"
#import "UIImage+Border.h"
#import "NSString+TestHelper.h"
#import "IPPortfolio.h"

CGFloat kIPPhotoMaxEdgeSize;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
//  Private extensions to IPPhoto
//

#define kIPPhotoOptimizedVersion    @"optimizedVersion"

@interface IPPhoto ()

- (UIImage *)thumbnailFromImage:(UIImage *)image;
- (void)saveThumbnail:(UIImage *)thumbnail toPath:(NSString *)thumbnailPath;
- (void)saveTilesOfSize:(CGSize)size 
               forImage:(UIImage*)image 
            toDirectory:(NSString*)directoryPath 
            usingPrefix:(NSString*)prefix;
+ (UIImage *)rescaleIfNecessary:(UIImage *)image;

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPPhoto

@synthesize filename = filename_;
@dynamic thumbnailFilename;
@synthesize title = title_;
@synthesize caption = caption_;
@synthesize image = image_;
@synthesize imageSize = imageSize_;
@synthesize thumbnail = thumbnail_;
@synthesize parent = parent_;
@synthesize optimizedVersion = optimizedVersion_;

////////////////////////////////////////////////////////////////////////////////////////////////////

+ (void)initialize {
  
  UIScreen *mainScreen = [UIScreen mainScreen];
  CGFloat maxDimension = MAX(mainScreen.bounds.size.width, mainScreen.bounds.size.height);
  maxDimension *= mainScreen.scale;
  kIPPhotoMaxEdgeSize = maxDimension * 1.5;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release all retained properties.
//


#pragma mark NSCoding

////////////////////////////////////////////////////////////////////////////////
//
//  Encode the object.
//

-(void)encodeWithCoder:(NSCoder *)aCoder {
  
  [aCoder encodeObject:self.filename forKey:kIPPhotoFilename];
  [aCoder encodeObject:self.title forKey:kIPPhotoTitle];
  [aCoder encodeObject:self.caption forKey:kIPPhotoCaption];
  [aCoder encodeObject:[NSValue valueWithCGSize:self.imageSize] forKey:kIPPhotoImageSize];
  [aCoder encodeObject:@(self.optimizedVersion) 
                forKey:kIPPhotoOptimizedVersion];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Initialize from an archive.
//

-(id)initWithCoder:(NSCoder *)aDecoder {
  
  if ((self=[super init]) != nil) {
    
    //
    //  Make sure file names are always rooted in this app's doc directory.
    //
    
    self.filename = [aDecoder decodeObjectForKey:kIPPhotoFilename]; 
    self.title    = [aDecoder decodeObjectForKey:kIPPhotoTitle];
    self.caption  = [aDecoder decodeObjectForKey:kIPPhotoCaption];
    self.imageSize = [[aDecoder decodeObjectForKey:kIPPhotoImageSize] CGSizeValue];
    self.optimizedVersion = [[aDecoder decodeObjectForKey:kIPPhotoOptimizedVersion] unsignedIntegerValue];
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Normal initialization.
//

- (id)init {
  
  self = [super init];
  if (self != nil) {
    
    //
    //  Guarantee this is initialized to zero.
    //
    
    self.imageSize = CGSizeZero;
  }
  return self;
}

#pragma mark NSCopying

////////////////////////////////////////////////////////////////////////////////
//
//  Copy the object.
//

-(id)copyWithZone:(NSZone *)zone {
  
  IPPhoto *myCopy = [[IPPhoto allocWithZone:zone] init];
  myCopy.filename = [self.filename copyWithZone:zone];
  myCopy.title    = [self.title copyWithZone:zone];
  myCopy.caption  = [self.caption copyWithZone:zone];
  return myCopy;
}

#pragma mark - Class methods

////////////////////////////////////////////////////////////////////////////////
//
//  This is the location where we store thumbnails.
//

+ (NSString *)thumbnailDirectory {
  
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *docDirectory = paths[0];
  return [docDirectory stringByAppendingPathComponent:kThumbnailPathComponent];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Create the thumbnail directory.
//

+ (void)createThumbnailDirectory {

  NSError *error;
  NSString *targetDirectory = [IPPhoto thumbnailDirectory];
  DDLogVerbose(@"%s -- trying to create %@", __PRETTY_FUNCTION__, targetDirectory);
  if(![[NSFileManager defaultManager] createDirectoryAtPath:targetDirectory
                                withIntermediateDirectories:YES 
                                                 attributes:nil 
                                                      error:&error]) {
    
    DDLogError(@"%s -- unable to create thumbnails directory: %@ (%@)",
               __PRETTY_FUNCTION__, 
               [IPPhoto thumbnailDirectory], 
               error);

    BOOL directory;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:targetDirectory 
                                                       isDirectory:&directory];
    if (exists && !directory) {
      
      DDLogVerbose(@"%s -- %@ exists, but is not a directory. Deleting and retrying.",
                 __PRETTY_FUNCTION__,
                 targetDirectory);
      [[NSFileManager defaultManager] removeItemAtPath:targetDirectory error:NULL];
      if (![[NSFileManager defaultManager] createDirectoryAtPath:targetDirectory 
                                     withIntermediateDirectories:YES 
                                                      attributes:nil 
                                                           error:&error]) {
        
        DDLogVerbose(@"%s -- still could not create %@ (%@)",
                   __PRETTY_FUNCTION__,
                   targetDirectory,
                   error);
      }
    }
  }
}  

////////////////////////////////////////////////////////////////////////////////
//
//  Create a photo with an image.
//

+ (IPPhoto *)photoWithImage:(UIImage *)image {

  IPPhoto *photo = [IPPhoto photoWithImage:image andTitle:nil];
  return photo;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Creates a photo with an image and a title.
//

+ (IPPhoto *)photoWithImage:(UIImage *)image andTitle:(NSString *)title {
  
  IPPhoto *photo = [[IPPhoto alloc] init];
  photo.image = image;
  photo.title = title;
  [photo optimize];
  return photo;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Creates a photo with a filename and a title.
//

+ (IPPhoto *)photoWithFilename:(NSString *)filename andTitle:(NSString *)title {
  
  IPPhoto *photo = [[IPPhoto alloc] init];
  photo.filename = filename;
  photo.title = title;
  [photo optimize];
  return photo;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Gets a new filename suitable for a new image.
//

+ (NSString *)filenameForNewPhoto {
  
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *docDirectory = paths[0];
  
  //
  //  Generate a random filename. TODO: Check for collisions.
  //
  
  NSNumber *random = @(arc4random());
  NSString *_filename = [[random stringValue] stringByAppendingPathExtension:@"jpg"];
  return [docDirectory stringByAppendingPathComponent:_filename];
}

#pragma mark - Properties

////////////////////////////////////////////////////////////////////////////////
//
//  Gets the thumbnailFilename. This is derived from the image filename.
//

- (NSString *)thumbnailFilename {
  
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *docDirectory = paths[0];
  
  NSString *thumbnailFilename_ = [[[docDirectory stringByAppendingPathComponent:kThumbnailPathComponent] 
                                   stringByAppendingPathComponent:[[self.filename lastPathComponent] stringByDeletingPathExtension]] 
                                  stringByAppendingPathExtension:@"png"];
  return thumbnailFilename_;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Deletes the files backing this photo.
//

- (void)deletePhotoFiles {
  BOOL isDirectory;
  NSFileManager *fileManager = [NSFileManager defaultManager];
  
  if (self.filename == nil) {
  
    //
    //  Short-circuit.
    //
    
    return;
  }
  
  if ([fileManager fileExistsAtPath:self.filename isDirectory:&isDirectory]) {
    if (!isDirectory) {
      [fileManager removeItemAtPath:self.filename error:nil];
    }
  }
  if ([fileManager fileExistsAtPath:self.thumbnailFilename isDirectory:&isDirectory]) {
    if (!isDirectory) {
      [fileManager removeItemAtPath:self.thumbnailFilename error:nil];
    }
  }
  
  //
  //  Delete any tiled files. Need to figure out what scales we would have
  //  generated tiles for, find the directory for that scale, and delete it.
  //
  
  NSArray *cacheContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString cachesFolder] error:NULL];
  for (NSString *directoryName in cacheContents) {
    
    NSString *prefix = [[self.filename lastPathComponent] stringByDeletingPathExtension];
    NSRange location = [directoryName rangeOfString:prefix];
    if (location.location == 0) {
      
      DDLogVerbose(@"%s -- removing directory %@", __PRETTY_FUNCTION__, directoryName);
      [fileManager removeItemAtPath:[directoryName asPathInCachesFolder] error:NULL];
    }
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  Creates random values for filename and thumbnailFilename.
//

-(void)createRandomFilenames {

  self.filename = [IPPhoto filenameForNewPhoto];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Creates a thumbnail image from the current image property. This is 
//  |kThumbnailSize| pixels, and it's saved to a PNG file.
//

- (UIImage *)thumbnailFromImage:(UIImage *)image {

  NSURL *imageUrl = [NSURL fileURLWithPath:self.filename];
  CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)imageUrl, NULL);
  NSDictionary *thumbnailOptions = @{(id)kCGImageSourceCreateThumbnailWithTransform: (id)kCFBooleanTrue,
                                    (id)(id)kCGImageSourceCreateThumbnailFromImageAlways: (id)kCFBooleanTrue,
                                    (id)kCGImageSourceThumbnailMaxPixelSize: [NSNumber numberWithFloat:kThumbnailSize]};
  CGImageRef thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (__bridge CFDictionaryRef)thumbnailOptions);
  UIImage *resizedImage = [UIImage imageWithCGImage:thumbnail];
  CFRelease(thumbnail);
  CFRelease(imageSource);
  return resizedImage;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Saves an image to a path in PNG format.
//

- (void)saveThumbnail:(UIImage *)thumbnail toPath:(NSString *)thumbnailPath {
  
  NSData *thumbnailData = UIImagePNGRepresentation(thumbnail);
  NSError *error = nil;
  if (thumbnailData && 
      ![thumbnailData writeToFile:thumbnailPath options:NSDataWritingAtomic error:&error]) {
    
    //
    //  Saving the file failed. This can happen if the 'thumbnails' directory
    //  has not been properly created. Make it and retry.
    //
    
    DDLogVerbose(@"%s -- failed to save to %@ (%@). Trying to create directory, and retrying",
               __PRETTY_FUNCTION__,
               thumbnailPath,
               error);
    [IPPhoto createThumbnailDirectory];
    if (![thumbnailData writeToFile:thumbnailPath options:NSDataWritingAtomic error:&error]) {
      
      DDLogVerbose(@"%s -- really finally failed to save %@ (%@)",
                 __PRETTY_FUNCTION__,
                 thumbnailPath,
                 error);
    }
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  PRIVATE: Saves |image_| to |self.filename|.
//

- (void)saveImageData {
  
  NSData *imageData = UIImageJPEGRepresentation(image_, 0.8);
  NSAssert(image_ != nil, @"Cannot save nil image");
  NSAssert(imageData != nil, 
                @"Cannot get JPEG representation of image %@",
                image_);
  
  DDLogVerbose(@"%s -- saving image to %@", __PRETTY_FUNCTION__, self.filename);
  [imageData writeToFile:self.filename atomically:YES];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Unloads the image.
//

- (void)unloadImage {
  
  image_ = nil;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Returns the image. If the image has not yet been loaded, loads it
//  from |filename_| and resizes if necessary.
//

- (UIImage *)image {
  
  if (image_ != nil) {
    return image_;
  }
  image_ = [[UIImage alloc] initWithContentsOfFile:self.filename];
  
  self.imageSize = [image_ size];
  return image_;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Sets the main image property. This causes a chain reaction... if the image
//  is not |nil|, then the image gets saved to a randomly-generated file name.
//  If there was already a file name associated with this photo, then the old
//  file will get deleted. Finally, a thumbnail image will get created for the
//  image and saved. Finally, if the photo belongs to a set *and* it is the
//  first photo in the set, then the set's thumbnail will get updated.
//

- (void)setImage:(UIImage *)theImage {
  
  [self deletePhotoFiles];
  self.optimizedVersion = 0;
  
  if (theImage == nil) {
    
    //
    //  Short circuit.
    //
    
    image_ = nil;
    return;
  }

  //
  //  NOTE: Instead of just storing |theImage| into |image_|, I'm first going
  //  to save |theImage| (rescaled if necessary) and then load the saved file.
  //  That will mark the image data as purgable.
  //
  
  [self createRandomFilenames];
  
  //
  //  Create & drain an autorelease pool to get rid of |data| from memory as soon
  //  as I'm done with it.
  //
  
  @autoreleasepool {
    NSData *data = UIImageJPEGRepresentation(theImage, 0.8);
    [data writeToFile:self.filename atomically:YES];
  }
  
  //
  //  TODO -- wait, why do I read & decode the image here? I should just
  //  assign |theImage|, right?
  //
  
  image_ = [[UIImage alloc] initWithContentsOfFile:self.filename];
  self.imageSize = [image_ size];

  //
  //  Invalidate any existing thumbnail.
  //
  
  thumbnail_ = nil;

  //
  //  Let the grandparent in the hierarchy know we've changed. This is to
  //  support KVO for the thumbnail object for the set. Note this is safe
  //  to call even if either of the parent pointers are nil.
  //
  
  [[[self parent] parent] photoInSetHasChanged:self];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Gets the thumbnail. Note it is an error to access the thumbnail before calling
//  |optimize|.
//

- (UIImage *)thumbnail {
  
  if (thumbnail_ != nil) {
    return thumbnail_;
  }

  //
  //  This is the caching code.
  //

  NSString *thumbnailFilename = self.thumbnailFilename;
  
  //
  //  Note that if |filename_| is not valid, then |thumbnailFilename| is not
  //  valid.
  //
  
  if (self.filename == nil) {
    
    return nil;
  }
  if (![[NSFileManager defaultManager] fileExistsAtPath:thumbnailFilename]) {

    NSAssert(NO, @"Called -[IPPhoto thumbnail] before calling -[IPPhoto optimize]");
    return nil;
  }
  
  thumbnail_ = [[UIImage alloc] initWithContentsOfFile:thumbnailFilename];
  return thumbnail_;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Get the image size.
//

- (CGSize)imageSize {
  
  if (image_ != nil) {

    //
    //  If the image has been loaded, then we cache and return its value.
    //  The cache is persisted so I don't have to load the image if it later
    //  gets unloaded.
    //
    
    imageSize_ = image_.size;
  }
  return imageSize_;
}

#pragma mark - Image optimization

////////////////////////////////////////////////////////////////////////////////
//
//  "Optimize" the current photo. This involves:
//
//    - Resizing (or tiling) the image so it can be displayed / manipulated
//      without blowing out all memory.
//    - Computing & saving a thumbnail for the image.
//
//  This method runs synchronously, and can take a long time (and a lot of
//  memory) to complete. Thus, the caller is advised to run it off the UI
//  thread, but control how many background operations run concurrently.
//

- (void)optimize {
  
  //
  //  Short-circuit if we've already been optimized.
  //
  
  if ([self isOptimized] || (self.filename == nil)) {
    
    return;
  }
  
  @autoreleasepool {
  
  //
  //  Use ImageIO to inspect the size of the image, and generate a 
  //  resized image if needed.
  //
  
    NSURL *imageUrl = [NSURL fileURLWithPath:self.filename];
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)imageUrl, NULL);
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
    DDLogVerbose(@"%s -- got properties %@", 
               __PRETTY_FUNCTION__,
               imageProperties);
    CFNumberRef pixelWidthRef  = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
    CFNumberRef pixelHeightRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
    CGFloat pixelWidth = [(__bridge NSNumber *)pixelWidthRef floatValue];
    CGFloat pixelHeight = [(__bridge NSNumber *)pixelHeightRef floatValue];
    CGFloat maxEdge = MAX(pixelWidth, pixelHeight);
    DDLogVerbose(@"%s -- found max edge = %f (%f, %f)",
               __PRETTY_FUNCTION__,
               maxEdge,
               pixelWidth,
               pixelHeight);
    
    if (maxEdge > kIPPhotoMaxEdgeSize) {
      
      //
      //  We need to rescale the image. Ask ImageIO to make a thumbnail for us.
      //
      
      NSDictionary *thumbnailOptions = @{(id)kCGImageSourceCreateThumbnailWithTransform: (id)kCFBooleanTrue,
                                        (id)(id)kCGImageSourceCreateThumbnailFromImageAlways: (id)kCFBooleanTrue,
                                        (id)kCGImageSourceThumbnailMaxPixelSize: @(kIPPhotoMaxEdgeSize)};
      CGImageRef thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (__bridge CFDictionaryRef)thumbnailOptions);
      UIImage *resizedImage = [UIImage imageWithCGImage:thumbnail];
      NSData *jpegData = UIImageJPEGRepresentation(resizedImage, 0.8);
      [jpegData writeToFile:self.filename atomically:YES];
      CFRelease(thumbnail);
    }
    
    CFRelease(imageSource);
    CFRelease(imageProperties);

    //
    //  Force a thumbnail, even if one was there already.
    //
    
    [self image];
    UIImage *tempThumbnail = [self thumbnailFromImage:image_];
    [self saveThumbnail:tempThumbnail toPath:self.thumbnailFilename];
    thumbnail_ = [[UIImage alloc] initWithContentsOfFile:self.thumbnailFilename];
    NSAssert([[NSFileManager defaultManager] fileExistsAtPath:self.thumbnailFilename],
                  @"Thumbnail file should have been saved");
    
    //
    //  Update this photo's optimization version.
    //
    
    self.optimizedVersion = kIPPhotoCurrentOptimizationVersion;
  
  }
}

////////////////////////////////////////////////////////////////////////////////

- (BOOL)isOptimized {
  
  return self.optimizedVersion == kIPPhotoCurrentOptimizationVersion;
}

////////////////////////////////////////////////////////////////////////////////
//
//  This is a blunt hammer, and something from earlier incarnations of the program.
//  It force-resizes an image to be something that can be managed more easily.
//
//  If tiling ever works better, then this can get removed.
//

+ (UIImage *)rescaleIfNecessary:(UIImage *)originalImage {
  
  if (originalImage == nil) {
    
    //
    //  Short-circuit.
    //
    
    return nil;
  }
  CGFloat longEdge = MAX(originalImage.size.width, originalImage.size.height);
  if (longEdge < 2 * kImageLongEdgeMinRescaleSize) {
    
    return nil;
  }
  
  //
  //  OK, need to rescale the image.
  //
  
  CGFloat scaleFactor = kIPPhotoMaxEdgeSize / longEdge;
  CGSize newSize = CGSizeApplyAffineTransform(originalImage.size, 
                                              CGAffineTransformMakeScale(scaleFactor, scaleFactor));
  UIImage *rescaled = [originalImage resizedImage:newSize interpolationQuality:kCGInterpolationHigh];
  return rescaled;
}

#pragma mark - Image tiling

////////////////////////////////////////////////////////////////////////////////
//
//  Creates tiles of an image.
//
//  From http://www.cimgf.com/2011/03/01/subduing-catiledlayer/
//

- (void)saveTilesOfSize:(CGSize)size 
               forImage:(UIImage*)image 
            toDirectory:(NSString*)directoryPath 
            usingPrefix:(NSString*)prefix {

  CGFloat cols = [image size].width / size.width;
  CGFloat rows = [image size].height / size.height;
  
  int fullColumns = floorf(cols);
  int fullRows = floorf(rows);
  
  CGFloat remainderWidth = [image size].width - 
  (fullColumns * size.width);
  CGFloat remainderHeight = [image size].height - 
  (fullRows * size.height);
  
  
  if (cols > fullColumns) fullColumns++;
  if (rows > fullRows) fullRows++;
  
  CGImageRef fullImage = [image CGImage];
  CFRetain(fullImage);
  
  for (int y = 0; y < fullRows; ++y) {
    
    for (int x = 0; x < fullColumns; ++x) {

      @autoreleasepool {
        
        NSString *path = [NSString stringWithFormat:@"%@/%@%d_%d.jpg",
                          directoryPath, prefix, x, y];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
          
          //
          //  Short-circuit -- the file already exists. The tile's already
          //  been computed.
          //
          
          continue;
        }
        CGSize tileSize = size;
        if (x + 1 == fullColumns && remainderWidth > 0) {
          // Last column
          tileSize.width = remainderWidth;
        }
        if (y + 1 == fullRows && remainderHeight > 0) {
          // Last row
          tileSize.height = remainderHeight;
        }
        
        CGImageRef tileImage = CGImageCreateWithImageInRect(fullImage,
                                                            (CGRect){{x*size.width, y*size.height},
                                                              tileSize});
        if (tileImage != NULL) {
          
          NSData *imageData = UIImageJPEGRepresentation([UIImage imageWithCGImage:tileImage], 0.8);
          [imageData writeToFile:path atomically:YES];
          CFRelease(tileImage);
        }
      }
    }
  } 
  CFRelease(fullImage);
}

////////////////////////////////////////////////////////////////////////////////
//
//  Computes the tile prefix for a given tile size.
//

- (NSString *)tileDirectoryForTileSize:(CGSize)tileSize andScale:(CGFloat)currentScale {
  
  NSString *tileDirectory = [NSString stringWithFormat:@"%@_jpg_%d_%d",
                             [[self.filename lastPathComponent] stringByDeletingPathExtension],
                             (int)tileSize.width,
                             (int)(1000 * currentScale)];
  return [tileDirectory asPathInCachesFolder];
}

////////////////////////////////////////////////////////////////////////////////
//
//  The default tile size.
//

- (CGSize)defaultTileSize {
  
  return CGSizeMake(768, 768);
}

////////////////////////////////////////////////////////////////////////////////
//
//  How many levels of detail should we have for this, when retiling? Each
//  level will have half the resolution of the previous level.
//

- (size_t)levelsOfDetail {

  //
  //  TODO -- with tiling currently out, we actually never have any more levels of
  //  detail. If tiling comes back, remove this.
  //
  
  return 1;
  
  //
  //  THE FOLLOWING IS DEAD CODE.
  //
  
  CGFloat longEdge = MAX(self.imageSize.width, self.imageSize.height);
  if (longEdge == 0) {
    
    //
    //  We never figured out the imageSize. Alas, we need to load the image
    //  and recalculate.
    //
    
    [self image];
    longEdge = MAX(self.imageSize.width, self.imageSize.height);
    NSAssert(longEdge != 0, @"Should not have zero edge dimension");
    
    //
    //  Save the portfolio that contains this image, so the newly calcuated
    //  imageSize gets saved.
    //
    
    IPPortfolio *portfolio = self.parent.parent.parent;
    [portfolio savePortfolioToPath:[IPPortfolio defaultPortfolioPath]];
    DDLogVerbose(@"%s -- just saved portfolio to persist image size", __PRETTY_FUNCTION__);
  }
  CGFloat minScale = kImageLongEdgeMinRescaleSize / longEdge;
  CGFloat log = ceilf(log2f(minScale));
  if (log >= 1) {
    
    //
    //  The image is too small to have any levels of detail. Special case this
    //  as one level.
    //
    
    DDLogVerbose(@"%s -- image too small; reporting one level of detail", 
               __PRETTY_FUNCTION__);
    return 1;
  }
  size_t detail = -1.0 * log + 1;
  DDLogVerbose(@"%s -- (%f x %f) minScale = %f, log = %f, detail = %ld",
             __PRETTY_FUNCTION__,
             self.imageSize.width,
             self.imageSize.height,
             minScale,
             log,
             detail);
  return detail;
}

////////////////////////////////////////////////////////////////////////////////
//
//  What's the smallest scale level we expect when displaying this photo in a
//  tile? This is the scale level that keeps the longest edge from being 
//  smaller than |kImageLongEdgeMinRescaleSize|.
//

- (CGFloat)minimumTileScale {
  
  CGFloat longEdge = MAX(self.imageSize.width, self.imageSize.height);
  CGFloat minScale = kImageLongEdgeMinRescaleSize / longEdge;
  CGFloat log = ceilf(log2f(minScale));
  CGFloat scale = powf(2.0, log);
  NSAssert(longEdge * scale >= kImageLongEdgeMinRescaleSize, 
                @"Scale should keep long edge less than %d, but it is %f",
                kImageLongEdgeMinRescaleSize,
                longEdge * scale);
  return scale;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Create all of the tiles we'll need for the current image.
//

- (void)saveTilesForAllScales {
  
  CGFloat currentScale = 1.0;
  CGFloat longEdge = MAX(self.image.size.height, self.image.size.width);
  
  do {
    
    [self saveTilesForScale:currentScale];
    longEdge /= 2;
    currentScale /= 2;
  } while (longEdge > 768);
}

////////////////////////////////////////////////////////////////////////////////
//
//  Save all the tiles we need for the image at a specific scale.
//

- (void)saveTilesForScale:(CGFloat)scale {
  
  UIImage *scaledImage;
  
  if (scale < 1.0) {
    
    //
    //  Only do this if we're really rescaling.
    //
    
    CGSize scaledSize = CGSizeMake(self.imageSize.width * scale, self.imageSize.height * scale);
    scaledImage = [self.image resizedImage:scaledSize interpolationQuality:kCGInterpolationHigh];
    
  } else {
    
    //
    //  scale == 1, skip the rescale.
    //  Note this logic will prevent me from scaling up.
    //
    
    scaledImage = self.image;
  }
  
  CGSize tileSize = [self defaultTileSize];
  NSString *tileDirectory = [self tileDirectoryForTileSize:tileSize andScale:scale];
  [[NSFileManager defaultManager] createDirectoryAtPath:tileDirectory 
                            withIntermediateDirectories:YES 
                                             attributes:nil 
                                                  error:NULL];
  [self saveTilesOfSize:tileSize 
               forImage:scaledImage 
            toDirectory:tileDirectory 
            usingPrefix:@"tile_"];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Do we have all of the tiles we need for a particular scale level?
//

- (BOOL)tilesExistForScale:(CGFloat)scale {
  
  CGSize tileSize = [self defaultTileSize];
  NSString *tileDirectory = [self tileDirectoryForTileSize:tileSize andScale:scale];
  NSArray *tiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tileDirectory error:NULL];
  
  CGSize scaledSize = CGSizeMake(self.imageSize.width * scale, self.imageSize.height * scale);
  NSUInteger expectedTileCount = ceilf(scaledSize.width / tileSize.width) *
                                 ceilf(scaledSize.height / tileSize.height);
  
  DDLogVerbose(@"%s -- expected %d tiles, found %d",
             __PRETTY_FUNCTION__,
             expectedTileCount,
             [tiles count]);
  return [tiles count] == expectedTileCount;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Get a tile.
//

- (UIImage *)tileForScale:(CGFloat)scale row:(NSUInteger)row column:(NSUInteger)column {
  
  //
  //  Round scale to the nearest power of two.
  //
  
  scale = powf(2.0, roundf(log2f(scale)));

  CGSize tileSize = [self defaultTileSize];
  NSString *tileDirectory = [self tileDirectoryForTileSize:tileSize andScale:scale];
  NSString *tileName = [NSString stringWithFormat:@"tile_%d_%d.jpg",
                        column,
                        row];
  UIImage *tile = [UIImage imageWithContentsOfFile:[tileDirectory stringByAppendingPathComponent:tileName]];
  return tile;
}

@end
