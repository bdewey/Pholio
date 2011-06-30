//
//  IPPortfolioGridViewController-test.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 4/23/11.
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
#import <OCMock/OCMock.h>
#import "IPPortfolioGridViewController.h"
#import "IPPortfolio+TestHelpers.h"
#import "IPAlertConfirmTest.h"
#import "IPPhotoOptimizationManager.h"

#define kNibName        @"IPPortfolioGridViewController"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface IPPortfolioGridViewController_test : GTMTestCase {
  
}

//
//  This is the controller we are testing.
//

@property (nonatomic, retain) IPPortfolioGridViewController *controller;

//
//  The portfolio that we loaded into the controller.
//

@property (nonatomic, retain) IPPortfolio *portfolio;

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPPortfolioGridViewController_test

@synthesize controller = controller_;
@synthesize portfolio = portfolio_;

////////////////////////////////////////////////////////////////////////////////
//
//  Create a controller worthy of testing.
//

- (void)setUp {

  [[IPPhotoOptimizationManager sharedManager] setWorkSynchronouslyForDebugging:YES];
  self.controller = [[[IPPortfolioGridViewController alloc] initWithNibName:kNibName bundle:nil] autorelease];
  
  //
  //  Force the view to load.
  //
  
//  [self.controller view];
  
  //
  //  Create a portfolio and assign it to the controller.
  //
  
  UIImage *smoke = [UIImage imageNamed:@"smoke.jpg"];
  UIImage *zoo   = [UIImage imageNamed:@"zoo.jpg"];
  
  IPSet *set1 = [IPSet setWithPages:
                 [IPPage pageWithImage:smoke andTitle:@"Set 1 smoke"],
                 [IPPage pageWithImage:zoo andTitle:@"Set 1 zoo"],
                 nil];
  IPSet *set2 = [IPSet setWithPages:
                 [IPPage pageWithImage:smoke andTitle:@"Set 2 smoke"],
                 [IPPage pageWithImage:zoo andTitle:@"Set 2 zoo"],
                 nil];
  
  self.portfolio = [IPPortfolio portfolioWithSets:set1, set2, nil];
  
  //
  //  Make sure that the thumbnail files are generated for each photo
  //  in the portfolio.
  //
  
  for (IPSet *theSet in self.portfolio.sets) {
    
    for (IPPage *thePage in theSet.pages) {
      
      for (IPPhoto *thePhoto in thePage.photos) {
        
        [thePhoto thumbnail];
        STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:thePhoto.thumbnailFilename],
                     nil);
      }
    }
  }
  
  STAssertEquals((NSUInteger)2, [self.portfolio countOfSets], nil);
  self.controller.portfolio = self.portfolio;
  [self.controller.gridView reloadData];
  
  //
  //  Make sure the pasteboard has nothing of interest.
  //
  
  UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
  STAssertNotNil(pasteboard, nil);
  pasteboard.color = [UIColor blackColor];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release the retained properties.
//

- (void)tearDown {
  
  self.controller = nil;
  self.portfolio = nil;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Verifies the internal consistency of our portfolio. All photo files should
//  exist, and there should be no duplicate file names.
//

- (void)verifyPortfolio {
  
  NSMutableSet *filenames = [NSMutableSet setWithCapacity:15];
  NSFileManager *defaultManager = [NSFileManager defaultManager];
  for (IPSet *set in self.portfolio.sets) {
    
    for (IPPage *page in set.pages) {
      
      for (IPPhoto *photo in page.photos) {
        
        STAssertFalse([filenames containsObject:photo.filename],
                      @"Unexpected duplicate filename: %@",
                      photo.filename);
        [filenames addObject:photo.filename];
        STAssertTrue([defaultManager fileExistsAtPath:photo.filename], 
                     @"Expected to find file for photo %@: %@",
                     photo.title,
                     photo.filename);
      }
    }
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  Ensure that every file referenced in a set does not exist.
//

- (void)verifySetDeleted:(IPSet *)set {

  NSFileManager *defaultManager = [NSFileManager defaultManager];
  for (IPPage *page in set.pages) {
    
    for (IPPhoto *photo in page.photos) {
      
      STAssertFalse([defaultManager fileExistsAtPath:photo.filename],
                    @"File %@ should not exist!",
                    photo.filename);
      STAssertFalse([defaultManager fileExistsAtPath:photo.thumbnailFilename],
                    @"Thumbnail file %@ should not exist!",
                    photo.thumbnailFilename);
    }
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  Test loading the controller.
//

- (void)testBindings {
  
  STAssertNoThrow([self.controller view], nil);
  STAssertNotNil(self.controller.view, nil);
  STAssertNotNil(self.controller.gridView, nil);
  STAssertNotNil(self.controller.backgroundImage, nil);
  STAssertEquals(self.controller.gridView.gridViewDelegate, self.controller, nil);
}

////////////////////////////////////////////////////////////////////////////////
//
//  Test copying.
//

- (void)testCopy {
  
  NSSet *victim = [NSSet setWithObject:[NSNumber numberWithUnsignedInteger:0]];
  [self.controller gridView:self.controller.gridView didCopy:victim];
  
  //
  //  We should have something we know how to paste.
  //
  
  STAssertTrue([self.controller gridViewCanPaste:self.controller.gridView], nil);
  
  //
  //  Do the paste.
  //
  
  [self.controller gridView:self.controller.gridView didPasteAtPoint:0];
  
  //
  //  We should now have three sets.
  //
  
  STAssertEquals((NSUInteger)3,
                 [self.portfolio countOfSets],
                 nil);
  [self verifyPortfolio];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Test cut.
//

- (void)testCut {
  
  NSSet *victim = [NSSet setWithObject:[NSNumber numberWithUnsignedInteger:0]];
  IPSet *set = [[[self.portfolio objectInSetsAtIndex:0] retain] autorelease];
  
  [self.controller gridView:self.controller.gridView didCut:victim];
  STAssertEquals((NSUInteger)1, [self.portfolio countOfSets], nil);
  
  //
  //  The files in |set| should no longer exist.
  //
  
  [self verifySetDeleted:set];
  [self verifyPortfolio];
  
  //
  //  I should know how to paste what's on the pasteboard.
  //
  
  STAssertTrue([self.controller gridViewCanPaste:self.controller.gridView], nil);
  [self.controller gridView:self.controller.gridView didPasteAtPoint:1];
  STAssertEquals((NSUInteger)2, [self.portfolio countOfSets], nil);
  [self verifyPortfolio];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Test delete.
//

- (void)testDelete {

  IPAlertConfirmTest *confirmTester = [[[IPAlertConfirmTest alloc] init] autorelease];
  self.controller.alertManager = confirmTester;
  NSSet *victim = [NSSet setWithObject:[NSNumber numberWithUnsignedInteger:0]];
  IPSet *set = [[[self.portfolio objectInSetsAtIndex:0] retain] autorelease];
  [self.controller gridView:self.controller.gridView didDelete:victim];
  
  STAssertTrue(confirmTester.confirmCalled, nil);
  
  //
  //  We put nothing interesting on the pasteboard.
  //
  
  STAssertFalse([self.controller gridViewCanPaste:self.controller.gridView], nil);
  [self verifySetDeleted:set];
  [self verifyPortfolio];
  STAssertEquals((NSUInteger)1, [self.portfolio countOfSets], nil);
}

////////////////////////////////////////////////////////////////////////////////
//
//  Test pasting a single page.
//

- (void)testPastePage {
  
  IPPage *page = [IPPage pageWithImage:[UIImage imageNamed:@"smoke.jpg"] andTitle:@"Paste guy"];
  IPPasteboardObject *pasteboardObject = [[[IPPasteboardObject alloc] init] autorelease];
  pasteboardObject.modelObject = page;
  NSData *pasteData = [NSKeyedArchiver archivedDataWithRootObject:pasteboardObject];
  [[UIPasteboard generalPasteboard] setData:pasteData forPasteboardType:kIPPasteboardObjectUTI];
  
  STAssertTrue([self.controller gridViewCanPaste:self.controller.gridView], nil);
  [self.controller gridView:self.controller.gridView didPasteAtPoint:1];
  [self verifyPortfolio];
  
  IPSet *newSet = [self.portfolio objectInSetsAtIndex:1];
  STAssertEqualStrings(kNewGalleryName, newSet.title, nil);
}

////////////////////////////////////////////////////////////////////////////////
//
//  Test pasting an image.
//

- (void)testPasteImage {
  
  UIImage *smoke = [UIImage imageNamed:@"smoke.jpg"];
  UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
  pasteboard.image = smoke;
  
  STAssertTrue([self.controller gridViewCanPaste:self.controller.gridView], nil);
  [self.controller gridView:self.controller.gridView didPasteAtPoint:1];
  STAssertEquals((NSUInteger)3,
                 [self.portfolio countOfSets],
                 nil);
  IPSet *set = [self.portfolio objectInSetsAtIndex:1];
  STAssertEqualStrings(kNewGalleryName, set.title, nil);
  IPPage *page = [set objectInPagesAtIndex:0];
  STAssertEqualStrings([page valueForKeyPath:kIPPhotoTitle forPhoto:0],
                       nil,
                       nil);
}

@end
