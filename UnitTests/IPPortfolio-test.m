//
//  IPPortfolio-test.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 4/7/11.
//  Copyright 2011 Brian's Brain. All rights reserved.
//

#import "GTMSenTestCase.h"
#import "GTMUnitTestDevLog.h"
#import <UIKit/UIKit.h>
#import <OCMock/OCMock.h>
#import "IPPortfolio.h"
#import "IPSet+TestHelpers.h"
#import "IPPage+TestHelpers.h"
#import "IPPortfolio+TestHelpers.h"
#import "NSObject+DeallocUnitTests.h"
#import "NSString+TestHelper.h"
#import "NSObject+NullAwareProperties.h"


@interface IPPortfolio_test : GTMTestCase {
  
}

@end


@implementation IPPortfolio_test

- (void)testRoundTrip {
  
  IPPortfolio *portfolio = [IPPortfolio portfolioWithSetCount:3];
  NSMutableString *title = [NSMutableString stringWithString:@"title"];
  NSMutableString *backgroundImageName = [NSMutableString stringWithString:@"background"];
  
  //
  //  Initialize the key properties.
  //
  
  portfolio.title = title;
  portfolio.backgroundImageName = backgroundImageName;
  portfolio.fontColor = [UIColor greenColor];
  
  //
  //  We should have some random bits at the top of the version.
  //
  
  STAssertNotEquals((NSInteger)0, portfolio.version, nil);
  
  //
  //  Make sure that the default save file doesn't exist.
  //
  
  NSFileManager *defaultManager = [NSFileManager defaultManager];
  [defaultManager removeItemAtPath:[IPPortfolio defaultPortfolioPath] 
                             error:NULL];
  BOOL exists = [defaultManager fileExistsAtPath:[IPPortfolio defaultPortfolioPath]];
  STAssertFalse(exists, @"Portfolio file should not exist");
  
  //
  //  Save the portfolio.
  //
  
  NSInteger oldVersion = portfolio.version;
  [portfolio savePortfolioToPath:[IPPortfolio defaultPortfolioPath]];
  exists = [defaultManager fileExistsAtPath:[IPPortfolio defaultPortfolioPath]];
  STAssertTrue(exists, @"File should be saved");
  
  //
  //  Load the portfolio and verify key properties.
  //
  
  IPPortfolio *newPortfolio = [IPPortfolio loadPortfolioFromPath:[IPPortfolio defaultPortfolioPath]];
  STAssertEqualStrings(portfolio.title,
                       newPortfolio.title,
                       @"Titles should match");
  STAssertEqualStrings(portfolio.backgroundImageName,
                       newPortfolio.backgroundImageName,
                       @"Background images should match.");
  STAssertEqualObjects(portfolio.fontColor, newPortfolio.fontColor, 
                       @"Font colors should match.");
  STAssertEquals(portfolio.version,
                 newPortfolio.version,
                 @"Version numbers should match");
  STAssertEquals(oldVersion + 1, portfolio.version, @"Version should be incremented");
  
  //
  //  Slipping a test in... String properties should have copy semantics.
  //
  
  [title appendString:@" has been modified"];
  [backgroundImageName appendString:@" has been modified"];
  STAssertEqualStrings(@"title", portfolio.title, @"title should have copy semantics");
  STAssertEqualStrings(@"background", portfolio.backgroundImageName,
                       @"backgroundImageName should have copy semantics");
  
  //
  //  Cleanup (unnecessary)
  //
  
  NSError *error;
  if (![defaultManager removeItemAtPath:[IPPortfolio defaultPortfolioPath] error:&error]) {
    STFail(@"Unexpected error removing %@: %@",
           [IPPortfolio defaultPortfolioPath],
           error);
  }
}

//
//  Tests portfolio copying.
//

- (void)testCopy {
  
  IPPortfolio *portfolio = [IPPortfolio portfolioWithSetCount:8];
  portfolio.title = @"testCopy";
  portfolio.backgroundImageName = @"bkgrnd";
  portfolio.fontColor = [UIColor blueColor];
  
  IPPortfolio *newPortfolio = [[portfolio copy] autorelease];
  STAssertEqualStrings(portfolio.title, newPortfolio.title, nil);
  STAssertEqualStrings(portfolio.backgroundImageName, newPortfolio.backgroundImageName, nil);
  STAssertEqualObjects(portfolio.fontColor, newPortfolio.fontColor, nil);
  STAssertEquals([portfolio countOfSets], [newPortfolio countOfSets], nil);
  
  //
  //  Test deep copy semantics.
  //
  
  [portfolio insertObject:[IPSet setWithPageCount:3] inSetsAtIndex:[portfolio countOfSets]];
  STAssertEquals([portfolio countOfSets] - 1,
                 [newPortfolio countOfSets],
                 nil);
  IPSet *firstSet = [portfolio objectInSetsAtIndex:0];
  [firstSet insertObject:[IPPage pageWithPhotoCount:8] inPagesAtIndex:0];
  STAssertEquals([firstSet countOfPages] - 1,
                 [[newPortfolio objectInSetsAtIndex:0] countOfPages],
                 nil);
}

//
//  Tests various hierarchy properties.
//

- (void)testHierarchy {
  IPPortfolio *portfolio = [[IPPortfolio alloc] init];
  
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  for (int i = 0; i < 5; i++) {
    [portfolio insertObject:[IPSet setWithPageCount:5] inSetsAtIndex:i];
  }
  [pool drain];
  
  IPSet *firstSet = [[[portfolio.sets objectAtIndex:0] retain] autorelease];
  STAssertEquals(portfolio, firstSet.parent,
                 @"Parent pointer should be updated");
  [portfolio removeObjectFromSetsAtIndex:0];
  STAssertNil(firstSet.parent, 
              @"Parent pointer should get set to nil on removal");
  
  
  NSUInteger count = [portfolio countOfObjectsInHierarchy];
  STAssertEquals((NSUInteger)45, count, @"Should count objects in hierarchy");
  [NSObject clearDeallocCallCounter];
  [portfolio release];
  STAssertEquals(count, [NSObject deallocCallCounter], 
                 @"Hierarchy should all be dealloc'd");
}

//
//  See if I can load a version 1 portfolio.
//

- (void)testLoadVersion1 {
  
  IPPortfolio *portfolio;
  NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"version1-portfolio.dat"];
  BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path];
  STAssertTrue(exists, @"Test file should be there.");
  portfolio = [IPPortfolio loadPortfolioFromPath:path];
  
  STAssertNotNil(portfolio, nil);
  STAssertEquals((NSUInteger)5, [portfolio countOfSets], nil);
  NSArray *setTitles = [NSArray arrayWithObjects:@"Family",
                        @"Landscapes",
                        @"Nature",
                        @"Places",
                        @"Seattle",
                        nil];
  for (int i = 0; i < [portfolio countOfSets]; i++) {
    IPSet *set = [portfolio objectInSetsAtIndex:i];
    STAssertEqualStrings([setTitles objectAtIndex:i],
                         set.title,
                         @"Should properly decode set title");
  }
}

//
//  HELPER: Obliterates everything in the documents directory, then copies
//  every image from the main bundle to the documents directory.
//
//  Returns the count of copied images.
//

- (NSUInteger)resetTestImages {
  
  NSUInteger count = 0;
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *docPath = [paths objectAtIndex:0];
  NSError *error = nil;
  NSArray *homeContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:docPath error:&error];
  STAssertNil(error, @"Unexpected error enumerating document directory: %@", error);
  for (NSString *file in homeContents) {
    
    if (![[NSFileManager defaultManager] removeItemAtPath:[docPath stringByAppendingPathComponent:file] error:&error]) {
      STFail(@"Unexpected error removing file %@: %@", 
             [docPath stringByAppendingPathComponent:file], 
             error);
    }
  }
  
  NSArray *bundleContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[NSBundle mainBundle] bundlePath] 
                                                                                error:NULL];
  NSArray *imageExtensions = [NSArray arrayWithObjects:@"jpg", @"jpeg", @"png", nil];
  for (NSString *file in bundleContents) {
    if ([imageExtensions indexOfObject:[file pathExtension]] != NSNotFound) {
      
      //
      //  This is an image. Copy it.
      //
      
      [[NSFileManager defaultManager] copyItemAtPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:file] 
                                              toPath:[docPath stringByAppendingPathComponent:file] 
                                               error:&error];
      STAssertNil(error, @"Unexpected error copying %@: %@", file, error);
      count++;
    }
  }
  return count;
}

//
//  Tests the photo filename fixup.
//

- (void)testFixupFileNames {
  
  NSUInteger countOfImages = [self resetTestImages];
  STAssertEquals((NSUInteger)22, countOfImages, nil);
  
  //
  //  My test cases are maintained in two parallel arrays.
  //
  
  NSArray *testCaseTitles = [NSArray arrayWithObjects:@"Existing image, nil thumbnail", 
                             @"Existing image and thumbnail",
                             @"Existing image, non existant thumbnail in wrong directory",
                             @"Existing image, thumbnail in wrong directory",
                             @"Nil image, existing thumbnail",
                             @"Nil image and thumbnail",
                             nil];
  
  NSArray *testCaseFilenames = [NSArray arrayWithObjects:[@"test-medium.jpg" asPathInDocumentsFolder],
                                [@"test-medium.jpg" asPathInDocumentsFolder],
                                [@"smoke.jpg" asPathInDocumentsFolder],
                                [@"zoo.jpg" asPathInDocumentsFolder],
                                [NSNull null],
                                [NSNull null],
                                nil];
  
  //
  //  Build up my test portfolio.
  //
  
  IPPortfolio *portfolio = [[[IPPortfolio alloc] init] autorelease];
  IPSet *set = [[[IPSet alloc] init] autorelease];
  set.title = @"Bunch of test cases";
  [portfolio insertObject:set inSetsAtIndex:0];
  for (int i = 0; i < [testCaseTitles count]; i++) {
    IPPhoto *photo = [[[IPPhoto alloc] init] autorelease];
    [photo nullAwareSetValue:[testCaseFilenames objectAtIndex:i] forKeyPath:@"filename"];
    photo.caption = [testCaseTitles objectAtIndex:i];
    IPPage *page = [[[IPPage alloc] init] autorelease];
    [page insertObject:photo inPhotosAtIndex:0];
    [set insertObject:page inPagesAtIndex:[set countOfPages]];
  }
  
  //
  //  Only the third image gets optimized, thus only the third one will have
  //  a thumbnail.
  //
  
  [[[set objectInPagesAtIndex:2] objectInPhotosAtIndex:0] optimize];
  
  STAssertNoThrow([portfolio performSelector:@selector(fixPhotoFileNames)], nil);
  
  STAssertEquals((NSUInteger)4, [set countOfPages], nil);
  STAssertEquals((NSUInteger)NSNotFound, [portfolio imageOptimizationVersion], nil);
  STAssertEquals((NSUInteger)NSNotFound, 
                 [[[set objectInPagesAtIndex:0] objectInPhotosAtIndex:0] optimizedVersion],
                 nil);
  
  
  //
  //  Look for valid photos.
  //
  
  for (IPPage *testPage in set.pages) {
    IPPhoto *testPhoto = [testPage objectInPhotosAtIndex:0];
    STAssertNotNil(testPhoto.filename, @"Case '%@': Filename should not be nil",
                   testPhoto.caption);
    STAssertNotNil(testPhoto.thumbnailFilename, 
                   @"Thumbnail filename should not be nil");
    
    //
    //  Note there is no longer a guarantee that the thumbnail file exists. If
    //  it's not there, it will get created on demand. But it should at least
    //  be in the right place.
    //
    
    NSString *actualThumbnailDirectory = [testPhoto.thumbnailFilename stringByDeletingLastPathComponent];
    STAssertEqualStrings([IPPhoto thumbnailDirectory],
                         actualThumbnailDirectory,
                         @"Expected thumbnail to be in %@ but was in %@",
                         [IPPhoto thumbnailDirectory],
                         actualThumbnailDirectory);
  }
}

//
//  Tests the search for new photos.
//

- (void)testLookForNewPhotos {
  
  NSUInteger photoCount = [self resetTestImages];
  
  //
  //  One of the photos is "branding.png". That shouldn't be found.
  //  One of the photos is "background.jpg". That shouldn't be found.
  //
  
  photoCount -= 2;
  IPPortfolio *portfolio = [[[IPPortfolio alloc] init] autorelease];
  
  IPSet *set = [portfolio setWithFoundPictures];
  STAssertEquals((NSUInteger)0, [portfolio countOfSets], nil);
  STAssertEqualStrings(kFoundPicturesGalleryName, set.title, nil);
  STAssertEquals(photoCount, [set countOfPages],
                 @"Expected %d pages, found %d",
                 photoCount,
                 [set countOfPages]);
  
  for (IPPage *page in set.pages) {
    STAssertEquals((NSUInteger)1, [page countOfPhotos], nil);
    IPPhoto *photo = [page objectInPhotosAtIndex:0];
    STAssertNotNil(photo.image, nil);
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  Test that new portfolios get a random, non-zero version.
//

- (void)testNewPortfolioVersion {
  
  IPPortfolio *portfolio1 = [[[IPPortfolio alloc] init] autorelease];
  IPPortfolio *portfolio2 = [[[IPPortfolio alloc] init] autorelease];
  
  STAssertNotEquals(0, portfolio1.version, nil);
  STAssertNotEquals(0, portfolio2.version, nil);
  STAssertNotEquals(portfolio1.version, portfolio2.version, nil);
}

@end
