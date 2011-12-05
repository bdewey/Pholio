//
//  BDOverlayViewController-test.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 11/25/11.
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
#import "BDOverlayViewController.h"
#import "GTMNSObject+UnitTesting.h"
#import "GTMUIKit+UnitTesting.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface BDOverlayViewController_test : GTMTestCase<BDOverlayViewControllerDelegate>

@property (nonatomic, assign) UISwipeGestureRecognizerDirection direction;
@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation BDOverlayViewController_test

@synthesize direction = direction_;

////////////////////////////////////////////////////////////////////////////////

- (void)testOutlets {
  
  BDOverlayViewController *controller = [[[BDOverlayViewController alloc] initWithDelegate:self] autorelease];
  
  [controller view];
  STAssertNotNil([controller performSelector:@selector(overlayTitleLabel)], nil);
  STAssertNotNil([controller performSelector:@selector(descriptionLabel)], nil);
  STAssertEquals(self, controller.delegate, nil);
}

////////////////////////////////////////////////////////////////////////////////

- (void)testDrawing {
  
  BDOverlayViewController *controller = [[[BDOverlayViewController alloc] initWithDelegate:self] autorelease];
  controller.overlayTitleText = @"testDrawing";
  controller.descriptionText = @"This is a short description.";
  GTMAssertObjectImageEqualToImageNamed([controller view], @"BDOverlayViewController_testDrawing", nil);
}

////////////////////////////////////////////////////////////////////////////////

- (void)testDrawingMultiLine {
  
  BDOverlayViewController *controller = [[[BDOverlayViewController alloc] initWithDelegate:self] autorelease];
  controller.overlayTitleText = @"Multiple description lines";
  controller.descriptionText  = @"This is a much longer description. The plan is to have many lines.\r\nCan I put line breaks in? No. Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Nam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Typi non habent claritatem insitam; est usus legentis in iis qui facit eorum claritatem. Investigationes demonstraverunt lectores legere me lius quod ii legunt saepius. Claritas est etiam processus dynamicus, qui sequitur mutationem consuetudium lectorum. Mirum est notare quam littera gothica, quam nunc putamus parum claram, anteposuerit litterarum formas humanitatis per seacula quarta decima et quinta decima. Eodem modo typi, qui nunc nobis videntur parum clari, fiant sollemnes in futurum.";
  GTMAssertObjectImageEqualToImageNamed([controller view], @"BDOverlayViewController_testDrawingMultiLine", nil);
}

////////////////////////////////////////////////////////////////////////////////

- (void)testSwipe {
  
  BDOverlayViewController *controller = [[[BDOverlayViewController alloc] initWithDelegate:self] autorelease];
  NSArray *recognizers = controller.view.gestureRecognizers;
  STAssertGreaterThanOrEqual([recognizers count], (NSUInteger)4, 
                             @"Must at least recognize 4 swipe directions. Number of recognizers: %d", 
                             [recognizers count]);
  NSUInteger expectedDirections = UISwipeGestureRecognizerDirectionUp |
                                  UISwipeGestureRecognizerDirectionDown |
                                  UISwipeGestureRecognizerDirectionLeft |
                                  UISwipeGestureRecognizerDirectionRight;
  for (UIGestureRecognizer *recognizer in recognizers) {
    
    if (![recognizer isKindOfClass:[UISwipeGestureRecognizer class]]) {
      
      continue;
    }
    UISwipeGestureRecognizer *swipe = (UISwipeGestureRecognizer *)recognizer;
    [controller performSelector:@selector(handleSwipe:) withObject:recognizer];
    STAssertEquals(direction_, [swipe direction],
                   @"Expected direction %d but saw direction %d",
                   [swipe direction],
                   direction_);
    expectedDirections ^= direction_;
  }
  STAssertEquals((NSUInteger)0, expectedDirections, @"Should cover all directions");
}

#pragma mark - BDOverlayViewControllerDelegate

////////////////////////////////////////////////////////////////////////////////

- (void)overlayViewController:(BDOverlayViewController *)controller didFinishWithSwipeDirection:(UISwipeGestureRecognizerDirection)direction {

  self.direction = direction;
}

////////////////////////////////////////////////////////////////////////////////

- (void)overlayViewControllerDidSkip:(BDOverlayViewController *)controller {
  
  //
  //  NOTHING
  //
}

@end
