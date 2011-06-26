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
#import "IPPortfolio.h"
#import "IPSetGridViewController.h"
#import "IPSet+TestHelpers.h"
#import "IPAlertConfirmTest.h"

#define kNibName        @"IPSetGridViewController"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface IPSetGridViewController_test : GTMTestCase {
  
}

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPSetGridViewController_test

////////////////////////////////////////////////////////////////////////////////
//
//  Helper: Validates that all of the photo files for a page exist.
//

- (void)assertFilesExistForPage:(IPPage *)page {
  
  NSFileManager *defaultManager = [NSFileManager defaultManager];
  for (IPPhoto *photo in page.photos) {
    
    STAssertTrue([defaultManager fileExistsAtPath:photo.filename], 
                 @"Expected to find file %@, but not there",
                 photo.filename);
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  Helper: Validates that all photo files for a page DO NOT exist.
//

- (void)assertFilesDoNotExistForPage:(IPPage *)page {
  
  NSFileManager *defaultManager = [NSFileManager defaultManager];
  for (IPPhoto *photo in page.photos) {
    
    STAssertFalse([defaultManager fileExistsAtPath:photo.filename], 
                  @"Expected no file at %@, but one exists",
                  photo.filename);
  }
}



////////////////////////////////////////////////////////////////////////////////
//
//  Test loading the controller.
//

- (void)testBindings {
  
  IPSetGridViewController *controller = [[[IPSetGridViewController alloc] initWithNibName:kNibName bundle:nil] autorelease];
  
  STAssertNotNil(controller, nil);
  
  //
  //  Force the view to load.
  //
  
  [controller view];
  STAssertNotNil(controller.view, nil);
  STAssertNotNil(controller.gridView, nil);
  STAssertEquals(controller.gridView.gridViewDelegate, controller, nil);
  STAssertNotNil(controller.backgroundImage, nil);
  STAssertNotNil(controller.activityIndicator, nil);
}

////////////////////////////////////////////////////////////////////////////////
//
//  Test setting |currentSet|. Should reload the grid.
//

- (void)testSetCurrentSet {
  
  IPSetGridViewController *controller = [[[IPSetGridViewController alloc] initWithNibName:kNibName bundle:nil] autorelease];
  IPSet *set = [IPSet setWithPageCount:5];
  id mockGrid = [OCMockObject mockForClass:[BDGridView class]];
  controller.gridView = mockGrid;
  
  [[mockGrid expect] reloadData];
  controller.currentSet = set;
  STAssertNoThrow([mockGrid verify], nil);
}

////////////////////////////////////////////////////////////////////////////////
//
//  HELPER: Get a |IPSetGridViewController| that's connected to a set with two
//  pages and a mock portfolio.
//

- (IPSetGridViewController *)controllerForTesting {
  
  IPSetGridViewController *controller = [[[IPSetGridViewController alloc] initWithNibName:kNibName bundle:nil] autorelease];
  [controller view];
  IPSet *set = [IPSet setWithPages:[IPPage pageWithImage:[UIImage imageNamed:@"smoke.jpg"]],
                [IPPage pageWithImage:[UIImage imageNamed:@"zoo.jpg"]],
                nil];
  STAssertEquals((NSUInteger)2, [set countOfPages], nil);
  controller.currentSet = set;
  id mockPortfolio = [OCMockObject mockForClass:[IPPortfolio class]];
  set.parent = mockPortfolio;
  
  //
  //  Make sure we have a pasteboard.
  //
  
  STAssertNotNil([UIPasteboard generalPasteboard], nil);

  //
  //  This makes sure that we don't have anything meaningful on the pasteboard
  //  when starting tests.
  //
  
  [[UIPasteboard generalPasteboard] setColor:[UIColor blackColor]];

  return controller;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Tests cutting a page out of a set.
//

- (void)testCut {
  
  IPSetGridViewController *controller = [self controllerForTesting];
  id mockPortfolio = controller.currentSet.parent;
  IPSet *set = controller.currentSet;
  
  //
  //  We're going to cut the object at index 0.
  //
  
  NSSet *victims = [NSSet setWithObject:[NSNumber numberWithUnsignedInteger:0]];
  IPPage *victim = [[[set objectInPagesAtIndex:0] retain] autorelease];
  [victim setValue:@"This is the victim" forKeyPath:kIPPhotoTitle forPhoto:0];
  [self assertFilesExistForPage:victim];
  [[mockPortfolio expect] savePortfolioToPath:[IPPortfolio defaultPortfolioPath]];
  [controller gridView:controller.gridView didCut:victims];
  
  //
  //  Verify that the portfolio was saved after the cut.
  //
  
  STAssertNoThrow([mockPortfolio verify], nil);
  
  //
  //  We should be left with one page.
  //
  
  STAssertEquals((NSUInteger)1, [set countOfPages], nil);
  
  //
  //  And we should have something we know how to paste.
  //
  
  STAssertTrue([controller gridViewCanPaste:controller.gridView], nil);
  
  //
  //  And the files for the page should not be there.
  //
  
  [self assertFilesDoNotExistForPage:victim];
  
  //
  //  Just for grins, make sure we can actually paste.
  //
  
  [[mockPortfolio expect] savePortfolioToPath:[IPPortfolio defaultPortfolioPath]];
  [controller gridView:controller.gridView didPasteAtPoint:1];
  STAssertNoThrow([mockPortfolio verify], nil);
  STAssertEquals((NSUInteger)2, [set countOfPages], nil);
  IPPage *pasted = [set objectInPagesAtIndex:1];
  STAssertEqualStrings([victim valueForKeyPath:kIPPhotoTitle forPhoto:0],
                          [pasted valueForKeyPath:kIPPhotoTitle forPhoto:0],
                          nil);
  STAssertNotEqualStrings([victim valueForKeyPath:kIPPhotoFilename forPhoto:0],
                          [pasted valueForKeyPath:kIPPhotoFilename forPhoto:0],
                          nil);
}

////////////////////////////////////////////////////////////////////////////////
//
//  Test delete.
//

- (void)testDelete {
  
  IPSetGridViewController *controller = [self controllerForTesting];
  IPAlertConfirmTest *confirmTester = [[[IPAlertConfirmTest alloc] init] autorelease];
  controller.alertManager = confirmTester;
  IPSet *set = controller.currentSet;
  id mockPortfolio = set.parent;
  IPPage *page1 = [[[set objectInPagesAtIndex:0] retain] autorelease];
  IPPage *page2 = [[[set objectInPagesAtIndex:1] retain] autorelease];

  STAssertEquals((NSUInteger)2, [set countOfPages], nil);
  [self assertFilesExistForPage:page1];
  [self assertFilesExistForPage:page2];
  
  NSSet *victims = [NSSet setWithObject:[NSNumber numberWithUnsignedInteger:0]];
  [[mockPortfolio expect] savePortfolioToPath:[IPPortfolio defaultPortfolioPath]];
  [controller gridView:controller.gridView didDelete:victims];
  STAssertTrue(confirmTester.confirmCalled, nil);
  
  STAssertEquals((NSUInteger)1, [set countOfPages], nil);
  STAssertNoThrow([mockPortfolio verify], nil);
  [self assertFilesDoNotExistForPage:page1];
  [self assertFilesExistForPage:page2];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Test copy.
//

- (void)testCopy {
  
  IPSetGridViewController *controller = [self controllerForTesting];
  NSSet *victims = [NSSet setWithObject:[NSNumber numberWithUnsignedInteger:0]];
  [controller gridView:controller.gridView didCopy:victims];
  
  //
  //  I should have something I can paste.
  //
  
  STAssertTrue([controller gridViewCanPaste:controller.gridView], nil);
  
  //
  //  ...yet still have two pages.
  //
  
  NSUInteger expectedPages = 2;
  STAssertEquals(expectedPages, [controller.currentSet countOfPages], nil);
  
  //
  //  Ensure I can paste.
  //
  
  id mockPortfolio = controller.currentSet.parent;
  [[mockPortfolio expect] savePortfolioToPath:[IPPortfolio defaultPortfolioPath]];
  [controller gridView:controller.gridView didPasteAtPoint:0];
  expectedPages = 3;
  STAssertEquals(expectedPages, [controller.currentSet countOfPages], nil);
  STAssertNoThrow([mockPortfolio verify], nil);
}

////////////////////////////////////////////////////////////////////////////////
//
//  Test pasting a set into a set. It should append all pictures.
//

- (void)testPasteSet {
  
  IPSetGridViewController *controller = [self controllerForTesting];
  id mockPortfolio = controller.currentSet.parent;
  
  //
  //  Mock up a set and shove it on the pasteboard.
  //
  
  IPSet *pasteSet = [IPSet setWithPages:
                     [IPPage pageWithImage:[UIImage imageNamed:@"smoke.jpg"] andTitle:@"smoke"],
                     [IPPage pageWithImage:[UIImage imageNamed:@"zoo.jpg"] andTitle:@"zoo"],
                     nil];
  IPPasteboardObject *pasteboardObject = [[[IPPasteboardObject alloc] init] autorelease];
  pasteboardObject.modelObject = pasteSet;
  NSData *pasteData = [NSKeyedArchiver archivedDataWithRootObject:pasteboardObject];
  [[UIPasteboard generalPasteboard] setData:pasteData forPasteboardType:kIPPasteboardObjectUTI];
  
  STAssertTrue([controller gridViewCanPaste:controller.gridView], nil);
  [[mockPortfolio expect] savePortfolioToPath:[IPPortfolio defaultPortfolioPath]];
  [controller gridView:controller.gridView didPasteAtPoint:1];
  STAssertNoThrow([mockPortfolio verify], nil);
  STAssertEquals((NSUInteger)4, [controller.currentSet countOfPages], nil);
}

////////////////////////////////////////////////////////////////////////////////
//
//  Test pasting an image.
//

- (void)testPasteImage {
  
  IPSetGridViewController *controller = [self controllerForTesting];
  id mockPortfolio = controller.currentSet.parent;
  
  UIImage *image = [UIImage imageNamed:@"smoke.jpg"];
  UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
  pasteboard.image = image;
  
  STAssertTrue([controller gridViewCanPaste:controller.gridView], nil);
  [[mockPortfolio expect] savePortfolioToPath:[IPPortfolio defaultPortfolioPath]];
  [controller gridView:controller.gridView didPasteAtPoint:1];
  STAssertNoThrow([mockPortfolio verify], nil);
  STAssertEquals((NSUInteger)3, [controller.currentSet countOfPages], nil);
  IPPage *page = [controller.currentSet objectInPagesAtIndex:1];
  STAssertEqualStrings([page valueForKeyPath:kIPPhotoTitle forPhoto:0],
                       nil,
                       nil);
}

@end
