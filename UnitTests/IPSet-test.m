//
//  IPSet-test.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 4/6/11.
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
#import "IPSet.h"
#import "NSString+TestHelper.h"
#import "IPPhoto+TestHelpers.h"
#import "IPPage+TestHelpers.h"
#import "IPSet+TestHelpers.h"
#import "NSObject+DeallocUnitTests.h"


@interface IPSet_test : GTMTestCase {
  @private
  
  //
  //  Used to count how many times we've observed the thumbnail filename changing.
  //
  
  NSUInteger thumbnailUpdateCount_;
}


@end


@implementation IPSet_test

//
//  Tests loading & saving an IPSet object.
//

- (void)testRoundTrip {

  NSString *filename = [@"IPSet-testRoundTrip.dat" asPathInDocumentsFolder];
  NSFileManager *defaultManager = [NSFileManager defaultManager];
  [defaultManager removeItemAtPath:filename error:NULL];
  BOOL exists = [defaultManager fileExistsAtPath:filename];
  STAssertFalse(exists, @"File should not exist");
  
  IPSet *set = [[[IPSet alloc] init] autorelease];
  NSUInteger photosPerPage[] = { 1, 1, 2, 3, 5 };
  int pageCount = sizeof(photosPerPage) / sizeof(NSUInteger);
  for (int i = 0; i < pageCount; i++) {
    [set insertObject:[IPPage pageWithPhotoCount:photosPerPage[i]] inPagesAtIndex:i];
  }
  STAssertEquals((NSUInteger)pageCount, [set countOfPages], @"Should have the expected page count");
  NSMutableString *title = [NSMutableString stringWithString:@"Title"];
  set.title = title;
  
  //
  //  Check that the string properties have copy semantics.
  //
  
  [title appendString:@" has been modified"];
  STAssertEqualStrings(@"Title", set.title, @"set.title should not be modified.");
  
  [NSKeyedArchiver archiveRootObject:set toFile:filename];
  exists = [defaultManager fileExistsAtPath:filename];
  STAssertTrue(exists, @"File should be written");
  
  IPSet *newSet = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
  STAssertEquals((NSUInteger)pageCount, [newSet countOfPages],
                 @"Should load all pages");
  STAssertEqualStrings(set.title, newSet.title, @"Titles should load");
  IPPage *newFirstPage = [newSet objectInPagesAtIndex:0];
  STAssertEquals(newSet, newFirstPage.parent, @"parent pointer should be set");
}

//
//  Test that IPSet objects get deep-copied.
//

- (void)testCopy {
  
  IPSet *set = [[[IPSet alloc] init] autorelease];
  NSUInteger photosPerPage[] = { 1, 1, 2, 3, 5 };
  int pageCount = sizeof(photosPerPage) / sizeof(NSUInteger);
  for (int i = 0; i < pageCount; i++) {
    [set insertObject:[IPPage pageWithPhotoCount:photosPerPage[i]] inPagesAtIndex:i];
  }
  STAssertEquals((NSUInteger)pageCount, [set countOfPages], @"Should have the expected page count");
  
  IPSet *newSet = [[set copy] autorelease];
  STAssertEquals([set countOfPages], [newSet countOfPages],
                 @"All pages should copy");
  [set insertObject:[IPPage pageWithPhotoCount:8] inPagesAtIndex:[set countOfPages]];
  STAssertEquals([set countOfPages] - 1,
                 [newSet countOfPages],
                 @"Adding a page to set should not change newSet");
  IPPage *firstPage = [set objectInPagesAtIndex:0];
  IPPage *newFirstPage = [newSet objectInPagesAtIndex:0];
  [firstPage insertObject:[IPPhoto photoWithCaption:@"foo"] inPhotosAtIndex:0];
  STAssertEquals([firstPage countOfPhotos] - 1,
                 [newFirstPage countOfPhotos],
                 @"Changing one set's page should not affect the other page");
  
  //
  //  Check the new parent pointer
  //
  
  STAssertEquals(newSet, newFirstPage.parent, 
                 @"Parent pointer should be properly set");
}

//
//  Tests object hierarchy properties.
//

- (void)testHierarchy {
  
  IPSet *set = [[IPSet alloc] init];
  NSUInteger photosPerPage[] = { 1, 1, 2, 3, 5 };
  int pageCount = sizeof(photosPerPage) / sizeof(NSUInteger);
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  for (int i = 0; i < pageCount; i++) {
    IPPage *page = [IPPage pageWithPhotoCount:photosPerPage[i]];
    [set insertObject:page inPagesAtIndex:i];
  }
  [pool drain];
  
  STAssertEquals((NSUInteger)pageCount, [set countOfPages], 
                 @"Should have the expected page count");
  
  IPPage *firstPage = [[set objectInPagesAtIndex:0] retain];
  STAssertEquals(set, firstPage.parent, @"Parent pointer should be set");
  
  [set removeObjectFromPagesAtIndex:0];
  STAssertNil(firstPage.parent, 
              @"Removing a page from the hierarchy should clear parent pointer");
  [firstPage release];
  
  NSUInteger count = [set countOfObjectsInHierarchy];
  STAssertEquals((NSUInteger)16, count, @"Should be 16 objects in hierarchy");
  [NSObject clearDeallocCallCounter];
  [set release];
  STAssertEquals(count, [NSObject deallocCallCounter], 
                 @"Set should get dealloc message");
}

//
//  HELPER: Watches changes to |thumbnailFilename| properties of the set.
//

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  thumbnailUpdateCount_++;
}

//
//  HELPER: Asserts that |thumbnailUpdateCount_| is an expected value,
//  and then resets the counter.
//

- (void)validateAndResetUpdateCounter:(NSUInteger)expected {
  STAssertEquals(expected, thumbnailUpdateCount_, 
                 @"thumbnailUpdateCount_ should be %d", expected);
  thumbnailUpdateCount_ = 0;
}

//
//  Tests that the thumbnailFilename property for the set is properly maintained.
//

- (void)testThumbnailFilename {
  
  //
  //  Start with an array of pages with different thumbnail filenames.
  //
  
  NSArray *testPages = [NSArray arrayWithObjects:[IPPage pageWithImage:[UIImage imageNamed:@"background.jpg"]],
                        [IPPage pageWithImage:[UIImage imageNamed:@"smoke.jpg"]],
                        [IPPage pageWithImage:[UIImage imageNamed:@"zoo.jpg"]],
                        nil];
  IPSet *set = [[[IPSet alloc] init] autorelease];
  thumbnailUpdateCount_ = 0;
  [set addObserver:self forKeyPath:kIPSetThumbnailFilename options:0 context:NULL];
  STAssertNil(set.thumbnailFilename, @"Should start with nil thumbnailFilename");
  
  //
  //  Insert objects in sequential order. At the end, the thumbnail filename
  //  for the set should equal what was inserted first (which is at index 0).
  //
  
  for (IPPage *page in testPages) {

    //
    //  Note KVO works only if I use this method. FRAGILE!
    //  (Can't use [set.pages addObject:])
    //
    
    [set insertObject:page inPagesAtIndex:[set countOfPages]];
  }

  STAssertEqualStrings([[testPages objectAtIndex:0] valueForKeyPath:kIPPhotoThumbnailFilename forPhoto:0],
                       set.thumbnailFilename,
                       @"Thumbnail filename should be the one inserted at the first position");
  [self validateAndResetUpdateCounter:1];
  
  //
  //  Now, remove successive objects from the front of the set. Verify that
  //  the set's |thumbnailFilename| is updated at each step.
  //
  
  while ([set countOfPages] > 0) {
    NSString *originalFilename = [[[set thumbnailFilename] retain] autorelease];
    [set removeObjectFromPagesAtIndex:0];
    if ([set countOfPages] > 0) {
      STAssertNotEqualStrings(originalFilename, [set thumbnailFilename], 
                              @"thumbnailFilename should change");
      STAssertEqualStrings([[set objectInPagesAtIndex:0] valueForKeyPath:kIPSetThumbnailFilename forPhoto:0],
                           [set thumbnailFilename],
                           @"thumbnailFilename should match the first photo");
    } else {
      STAssertNil([set thumbnailFilename], 
                  @"Should have nil filename after last page deleted");
    }
  }
  [self validateAndResetUpdateCounter:[testPages count]];
  
  //
  //  Finally, insert successive objects at the front of the set.
  //  The thumbnailFilename should change at each step.
  //
  
  for (IPPage *page in testPages) {

    [set insertObject:page inPagesAtIndex:0];
    
    STAssertEqualStrings([page valueForKeyPath:kIPPhotoThumbnailFilename forPhoto:0],
                         [set thumbnailFilename],
                         @"thumbnailFilename should update after each insert");
  }
  [self validateAndResetUpdateCounter:[testPages count]];
  
  //
  //  Another interesting case: Change the image associated with the first
  //  photo in the set. That should update the set thumbnailFilename.
  //
  
  UIImage *image = [UIImage imageNamed:@"test-medium.jpg"];
  STAssertNotNil(image, @"Should be able to load image from bundle");
  IPPage *firstPage = [set objectInPagesAtIndex:0];
  IPPhoto *firstPhoto = [firstPage objectInPhotosAtIndex:0];
  NSString *originalThumbnailFilename = [[[set thumbnailFilename] retain] autorelease];
  firstPhoto.image = image;
  STAssertNotEqualStrings(originalThumbnailFilename, [set thumbnailFilename], 
                          @"thumbnailFilename should change");
  [self validateAndResetUpdateCounter:1];
  
  //
  //  If we change an image on some other page, we shouldn't get notified.
  //
  
  IPPage *secondPage = [set objectInPagesAtIndex:1];
  firstPhoto = [secondPage objectInPhotosAtIndex:0];
  firstPhoto.image = image;
  [self validateAndResetUpdateCounter:0];
  
  //
  //  Remember to do this LAST.
  //
  
  [set removeObserver:self forKeyPath:kIPSetThumbnailFilename];
}

@end
