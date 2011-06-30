//
//  IPPhoto.h
//  ipad-portfolio
//
//  This class represents a single photo in a portfolio.
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

#import <Foundation/Foundation.h>

#define kIPPhotoFilename            @"filename"
#define kIPPhotoThumbnailFilename   @"thumbnailFilename"
#define kIPPhotoTitle               @"title"
#define kIPPhotoCaption             @"caption"
#define kIPPhotoImageSize           @"imageSize"
#define kThumbnailSize              250
#define kThumbnailBorderSize        10
#define kThumbnailCornerRadius      0
#define kThumbnailPathComponent     @"thumbnails_v2.0"

//
//  When we rescale this image for tiling, we don't need to worry about
//  image scales that make the long edge shorter than this value.
//

#define kImageLongEdgeMinRescaleSize  768

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@class IPPage;
@interface IPPhoto : NSObject <NSCoding, NSCopying> { }

@property (nonatomic, copy) NSString *filename;
@property (nonatomic, readonly) NSString *thumbnailFilename;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *caption;
@property (nonatomic, copy) UIImage  *image;
@property (nonatomic, assign) CGSize imageSize;

//
//  The thumbnail is generated on demand. Note this can be expensive, so there's
//  an async getter as well.
//

@property (nonatomic, readonly) UIImage *thumbnail;
@property (nonatomic, assign) IPPage *parent;

//
//  Gets a filename suitable for a new photo file.
//

+ (NSString *)filenameForNewPhoto;

//
//  Optimize the current photo. This should be called prior to inserting a 
//  photo into the model. This is an expensive call, both in time and memory.
//  Therefore, don't call it on the UI thread, yet also control how many
//  operations can happen at the same time.
//

- (void)optimize;

- (BOOL)isOptimized;

//
//  Synchronously saves tiles for all needed display scales.
//

- (void)saveTilesForAllScales;

//
//  Synchronously save the tiles for a given scale.
//

- (void)saveTilesForScale:(CGFloat)scale;

//
//  Test if all tiles have been written for a given scale.
//

- (BOOL)tilesExistForScale:(CGFloat)scale;

//
//  The prefix of the filenames of our tile.
//

- (NSString *)tileDirectoryForTileSize:(CGSize)tileSize andScale:(CGFloat)currentScale;

//
//  The default tile size.
//

- (CGSize)defaultTileSize;

//
//  How many levels of detail should we have for this photo?
//

- (size_t)levelsOfDetail;

//
//  The minimum scale level we expect when displaying this photo in a tiled view.
//

- (CGFloat)minimumTileScale;

//
//  Gets a tile.
//

- (UIImage *)tileForScale:(CGFloat)scale row:(NSUInteger)row column:(NSUInteger)column;

//
//  The location where we store thumbnails.
//

+ (NSString *)thumbnailDirectory;

//
//  Create the thumbnail directory.
//

+ (void)createThumbnailDirectory;

//
//  Creates a photo with an image.
//

+ (IPPhoto *)photoWithImage:(UIImage *)image;

//
//  Creates a photo with an image and a title.
//

+ (IPPhoto *)photoWithImage:(UIImage *)image andTitle:(NSString *)title;

//
//  Creates a photo with a filename and a title.
//

+ (IPPhoto *)photoWithFilename:(NSString *)filename andTitle:(NSString *)title;

//
//  Deletes all of the files associated with this photo.
//

- (void)deletePhotoFiles;

@end
