//
//  IPPhoto-test.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 2/21/11.
//  Copyright 2011 Brian Dewey. 
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

#import "GTMSenTestCase.h"
#import <UIKit/UIKit.h>
#import "IPPhoto.h"
#import "NSString+TestHelper.h"
#import "GTMUnitTestDevLog.h"

#define kIPPhotoTestKey     @"kIPPhotoTestKey"
#define kTestMediumImage    @"AlexGrass_20110604.jpg"

//
//  Private methods I know exist on IPPhoto.
//

@interface IPPhoto (Private)

- (void)saveTilesOfSize:(CGSize)size 
               forImage:(UIImage*)image 
            toDirectory:(NSString*)directoryPath 
            usingPrefix:(NSString*)prefix;
@end

@interface IPPhoto_test : GTMTestCase {
  
}

@end


@implementation IPPhoto_test

//
//  Helper routine: Saves a photo to a path.
//

- (void)savePhoto:(IPPhoto *)photo toPath:(NSString *)outputPath  {
  
  //
  //  Save the object.
  //
  
  NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
  NSKeyedArchiver *keyedArchiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
  [keyedArchiver encodeObject:photo forKey:kIPPhotoTestKey];
  [keyedArchiver finishEncoding];
  [data writeToFile:outputPath atomically:YES];
}

//
//  Helper method: Load a photo from a file.
//

- (IPPhoto *)loadPhotoFromFile:(NSString *)outputPath  {
  
  //
  //  Load the object.
  //
  
  NSMutableData *data = [[[NSMutableData alloc] initWithContentsOfFile:outputPath] autorelease];
  NSKeyedUnarchiver *unarchiver = [[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
  IPPhoto *photo2 = [unarchiver decodeObjectForKey:kIPPhotoTestKey];
  [unarchiver finishDecoding];
  return photo2;
}

//
//  Helper function: Stuff some properties into a photo.
//

- (void)initializePhoto:(IPPhoto *)photo  {

  //
  //  Set the persistent properties.
  //
  
  photo.filename          = @"simpleRoundTrip";
  photo.title             = @"Title";
  photo.caption           = @"Caption";
}

//
//  Helper function: Validate properties are as expected.
//

- (void)validatePhoto:(IPPhoto *)photo2 {
  
  STAssertEqualStrings(@"simpleRoundTrip", photo2.filename, @"Should load filename");
  STAssertEqualStrings(@"Title", photo2.title, @"Should load title");
  STAssertEqualStrings(@"Caption", photo2.caption, @"Should load caption");
}

//
//  Validate that I can save & load an |IPPhoto|.
//

- (void)testSimpleRoundTrip {
  
  IPPhoto *photo = [[[IPPhoto alloc] init] autorelease];
  [self initializePhoto: photo];

  NSString *outputPath = [@"SimpleRoundTrip" asPathInDocumentsFolder];
  [self savePhoto:photo toPath:outputPath];

  
  STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:outputPath],
               @"File should be saved");
  
  IPPhoto *photo2 = [self loadPhotoFromFile: outputPath];


  STAssertNotNil(photo2, @"Should get a valid photo");
  [self validatePhoto:photo2];
}

//
//  Validate that copy works.
//

- (void)testCopy {

  IPPhoto *photo = [[[IPPhoto alloc] init] autorelease];
  [self initializePhoto:photo];
  
  IPPhoto *photo2 = [[photo copy] autorelease];
  [self validatePhoto:photo2];
}

//
//  So trivial I'm afraid to write it.
//

- (void)testGetFilename {
  
  NSString *file1 = [IPPhoto newPhotoFilename];
  NSString *file2 = [IPPhoto newPhotoFilename];
  
  //
  //  Subsequent calls should always return different, random file names.
  //
  
  STAssertNotEquals(file1, file2, nil);
  
  STAssertEqualStrings(@"jpg", [file1 pathExtension], 
                       @"Unexpected path extension: %@",
                       [file1 pathExtension]);

  STAssertEqualStrings([@"" asPathInDocumentsFolder],   
                       [file1 stringByDeletingLastPathComponent], nil);
}

//
//  Helper routine. Validates that a string property was copied into the object
//  and not just retained. This means I should be able to change the string
//  object that I passed in to the |IPPhoto| and the property will not
//  change.
//

- (void)validateCopyPropertyGetter:(SEL)getter 
                         andSetter:(SEL)setter {

  IPPhoto *photo = [[[IPPhoto alloc] init] autorelease];
  NSMutableString *string = [NSMutableString stringWithString:@"original"];
  NSString *original = [NSString stringWithString:string];

  [photo performSelector:setter withObject:string];
  STAssertEqualStrings(string, [photo performSelector:getter], 
                       @"Property should assign");
  [string appendString:@" -- modified"];
  STAssertEqualStrings(original, [photo performSelector:getter], 
                       @"Property should should not be modified");
}

//
//  Test that string properties are copy assigned.
//

- (void)testCopyAssignProperties {

  [self validateCopyPropertyGetter:@selector(filename) 
                         andSetter:@selector(setFilename:)];
  [self validateCopyPropertyGetter:@selector(title) 
                         andSetter:@selector(setTitle:)];
  [self validateCopyPropertyGetter:@selector(caption) 
                         andSetter:@selector(setCaption:)];
}

//
//  Test that, when I assign an image to an |IPPhoto|, it gets saved to a file.
//

- (void)testImageAssign {
  
  //
  //  Start this test with a non-existent "thumbnails" directory.
  //
  
  BOOL isDirectory;
  NSString *thumbnailPath = [kThumbnailPathComponent asPathInDocumentsFolder];
  
  [[NSFileManager defaultManager] removeItemAtPath:thumbnailPath
                                             error:NULL];
  STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:thumbnailPath
                                                     isDirectory:&isDirectory],
                @"Thumbnail directory should not exist");
  
  UIImage *image = [UIImage imageNamed:kTestMediumImage];
  STAssertNotNil(image, @"Internal validation: Should load test image");
  IPPhoto *photo = [[[IPPhoto alloc] init] autorelease];
  STAssertNil(photo.image, @"Photo does not start with an image");
  STAssertNil(photo.filename, @"Photo does not start with a file name");
  STAssertNil(photo.thumbnail, @"Photo does not start with a thumbnail");
  photo.image = image;
  
  //
  //  Assigning an image to a photo causes:
  //
  //    (1) The image to get saved to disk, with the |filename| stored;
  //    (2) A thumbnail image stored in |thumbnail|
  //    (3) The thumbnail file to get saved in |thumbnailFile|
  //
  
  STAssertNotNil(photo.filename, @"Photo should have a filename");
  STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:photo.filename],
               @"File should be saved");

  [photo optimize];
  STAssertNotNil(photo.thumbnail, @"Photo should have a thumbnail");

  CGFloat maxSize = MAX(photo.thumbnail.size.width,
                        photo.thumbnail.size.height);
  STAssertEqualsWithAccuracy((CGFloat)kThumbnailSize,
                             maxSize,
                             (CGFloat)1.0,
                             @"Thumbnail should have proper dimensions. Expected %f, got %f",
                             (CGFloat)kThumbnailSize + 2 * kThumbnailBorderSize,
                             maxSize);
  STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:photo.thumbnailFilename],
               @"Thumbnail should be saved");
  
  //
  //  Make sure I can delete the corresponding photo files.
  //
  
  [photo deletePhotoFiles];
  STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:photo.filename],
               @"File should be deleted");
  STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:photo.thumbnailFilename],
               @"Thumbnail should be deleted");
  
  //
  //  It should be safe to assign the same image back to the photo.
  //
  
  photo.image = image;
  STAssertNotNil(photo.filename, @"Photo should have a filename");
  STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:photo.filename],
               @"File should be saved");
  
  //
  //  Note you now have to access the thumbnail to force its generation.
  //
  
  [photo optimize];
  STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:photo.thumbnailFilename],
               @"Thumbnail should be saved");
  
  //
  //  In this case, assign a "new" image to the photo property. This should
  //  delete the image files associated with the photo and create new ones.
  //
  
  NSString *originalFileName  = [photo.filename copy];
  NSString *originalThumbnail = [photo.thumbnailFilename copy];
  photo.image = image;
  [photo optimize];
  STAssertNotEqualStrings(originalFileName, photo.filename,
                          @"Setting a new image should save to a new file");
  STAssertNotEqualStrings(originalThumbnail, photo.thumbnailFilename,
                          @"Setting a new image should create a new thumbnail");
  STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:photo.filename],
               @"File should be saved");
  STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:photo.thumbnailFilename],
               @"Thumbnail should be saved");
  STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:originalFileName],
                @"File should be deleted");
  STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:originalThumbnail],
                @"Thumbnail should be deleted");
}

//
//  Test image tiling
//

- (void)testTiling {
  
  IPPhoto *photo = [[[IPPhoto alloc] init] autorelease];
  UIImage *image = [UIImage imageNamed:kTestMediumImage];
  CGSize tileSize = [photo defaultTileSize];
  
  //
  //  Ensure the cache directory is empty.
  //
  
  [[NSFileManager defaultManager] removeItemAtPath:[NSString cachesFolder] 
                                             error:NULL];
  [[NSFileManager defaultManager] createDirectoryAtPath:[NSString cachesFolder] 
                            withIntermediateDirectories:YES 
                                             attributes:nil 
                                                  error:NULL];
  
  _GTMDevLog(@"%s -- image size is %f by %f",
             __PRETTY_FUNCTION__,
             image.size.width,
             image.size.height);
  [photo saveTilesOfSize:tileSize
                forImage:image
             toDirectory:[NSString cachesFolder]
             usingPrefix:@"testTiling"];
  
  //
  //  |image| is 3000x4000 pixels. That's 4x6 = 24 tiles.
  //
  
  NSArray *cacheContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString cachesFolder] 
                                                                               error:NULL];
  STAssertEquals((NSUInteger)24, [cacheContents count], nil);
  
  //
  //  Now, assign |image| to |photo| and make sure all tiles get created.
  //
  
  CGSize originalSize = image.size;
  photo.image = image;
  STAssertEquals(originalSize, photo.image.size, nil);
  [photo saveTilesForAllScales];
  
  //
  //  Validate scale arithmetic. For a photo with the long edge of 4000 pixels,
  //  there will be 3 levels of detail and a minimum scale of 0.25.
  //
  
  STAssertEquals((size_t)3, [photo levelsOfDetail], nil);
  STAssertEquals((CGFloat)0.25, [photo minimumTileScale], nil);
  
  CGFloat currentScale = 1.0;
  CGFloat longEdge     = MAX(originalSize.width, originalSize.height);
  while (longEdge > 768) {
    
    NSString *tileDirectory = [photo tileDirectoryForTileSize:[photo defaultTileSize] andScale:currentScale];
    _GTMDevLog(@"%s -- looking for tiles in %@", __PRETTY_FUNCTION__, tileDirectory);
    cacheContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tileDirectory error:NULL];
    NSUInteger matchingCount = [cacheContents count];

    _GTMDevLog(@"%s -- for scale %f, found %d tiles",
               __PRETTY_FUNCTION__,
               currentScale,
               matchingCount);
    
    //
    //  Figure out the expected number of tiles.
    //
    
    NSUInteger expectedTileCount = ceilf(originalSize.width / tileSize.width) *
                                   ceilf(originalSize.height / tileSize.height);
    
    STAssertEquals(expectedTileCount, matchingCount, 
                   @"Scale %f: Found %d tiles, expected %d", 
                   currentScale,
                   matchingCount,
                   expectedTileCount);
    STAssertTrue([photo tilesExistForScale:currentScale], nil);
    
    //
    //  Now, make sure I can get some tiles.
    //
    
    NSUInteger interestingRows[] = { 0, ceilf(originalSize.height / tileSize.height) - 1 };
    NSUInteger interestingCols[] = { 0, ceilf(originalSize.width / tileSize.width) - 1 };
    
    for (int rowOffset = 0; rowOffset < sizeof(interestingRows) / sizeof(NSUInteger); rowOffset++) {
      
      for (int colOffset = 0; colOffset < sizeof(interestingCols) / sizeof(NSUInteger); colOffset++) {
        
        UIImage *tile = [photo tileForScale:currentScale 
                                        row:interestingRows[rowOffset] 
                                     column:interestingCols[colOffset]];
        STAssertNotNil(tile, 
                       @"Scale %f: Should get tile for row = %d, col = %d",
                       currentScale,
                       interestingRows[rowOffset],
                       interestingCols[colOffset]);
      }
    }
    
    currentScale /= 2;
    longEdge /= 2;
    originalSize = CGSizeMake(originalSize.width / 2, originalSize.height / 2);
  }
  
  //
  //  Removing photo files should also remove the tiles. The only files we should
  //  have left are the 192 created when we called |saveTiles...|.
  //
  
  [photo deletePhotoFiles];
  cacheContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString cachesFolder] 
                                                                      error:NULL];
  STAssertEquals((NSUInteger)24, [cacheContents count], 
                 @"Expected 24 files, but found %d (%@)", 
                 [cacheContents count],
                 [cacheContents description]);
}

@end
