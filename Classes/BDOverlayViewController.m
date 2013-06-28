//
//  BDOverlayViewController.m
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

#import <QuartzCore/QuartzCore.h>
#import "BDOverlayViewController.h"

@interface BDOverlayViewController()

//
//  Interface builder properties.
//

@property (strong, nonatomic) IBOutlet UILabel *overlayTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *skipButton;

//
//  The default size of the description label. Comes from the XIB, remembered
//  on |viewDidLoad|.
//

@property (nonatomic, assign) CGSize defaultDescriptionSize;

//
//  Swipe gesture recognizers. We have one per direction so we know which
//  direction the user swiped and can report that to our delegate.
//

@property (nonatomic, strong) UISwipeGestureRecognizer *upRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *downRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *leftRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *rightRecognizer;
- (void)handleSwipe:(UIGestureRecognizer *)gestureRecognizer;

- (IBAction)didTapCancelButton:(id)sender;
- (IBAction)didTapSkipButton:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation BDOverlayViewController

@synthesize overlayTitleText       = overlayTitleText_;
@synthesize descriptionText        = descriptionText_;
@synthesize overlayTitleLabel      = overlayTitleLabel_;
@synthesize descriptionLabel       = descriptionLabel_;
@synthesize cancelButton;
@synthesize skipButton;
@synthesize defaultDescriptionSize = defaultDescriptionSize_;
@synthesize delegate               = delegate_;
@synthesize upRecognizer           = upRecognizer_;
@synthesize downRecognizer         = downRecognizer_;
@synthesize leftRecognizer         = leftRecognizer_;
@synthesize rightRecognizer        = rightRecognizer_;

////////////////////////////////////////////////////////////////////////////////

- (id)initWithDelegate:(id<BDOverlayViewControllerDelegate>)delegate {
  
  self = [super initWithNibName:nil bundle:nil];
  if (self) {
    
    self.delegate = delegate;
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////

- (void)didReceiveMemoryWarning {
  
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

////////////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad {
  
  [super viewDidLoad];

  self.view.layer.cornerRadius = 8.0;
  self.defaultDescriptionSize = self.descriptionLabel.frame.size;
  self.overlayTitleLabel.text = self.overlayTitleText;
  self.descriptionLabel.text  = self.descriptionText;
  [self layoutLabels];
  
  //
  //  Set up the swipe gesture recognizers.
  //
  
  upRecognizer_ = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
  upRecognizer_.direction = UISwipeGestureRecognizerDirectionUp;
  [self.view addGestureRecognizer:upRecognizer_];
  
  downRecognizer_ = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
  downRecognizer_.direction = UISwipeGestureRecognizerDirectionDown;
  [self.view addGestureRecognizer:downRecognizer_];
  
  leftRecognizer_ = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
  leftRecognizer_.direction = UISwipeGestureRecognizerDirectionLeft;
  [self.view addGestureRecognizer:leftRecognizer_];
  
  rightRecognizer_ = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
  rightRecognizer_.direction = UISwipeGestureRecognizerDirectionRight;
  [self.view addGestureRecognizer:rightRecognizer_];
  
  //
  //  Set up the button handlers.
  //
  
  [self.cancelButton addTarget:self action:@selector(didTapCancelButton:) forControlEvents:UIControlEventTouchUpInside];
  [self.skipButton   addTarget:self action:@selector(didTapSkipButton:)   forControlEvents:UIControlEventTouchUpInside];
}

////////////////////////////////////////////////////////////////////////////////

- (void)viewDidUnload {
  
  [self setOverlayTitleLabel:nil];
  [self setDescriptionLabel:nil];
  [self setCancelButton:nil];
  [self setSkipButton:nil];
  [super viewDidUnload];
}

////////////////////////////////////////////////////////////////////////////////

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  
  // Return YES for supported orientations
  return YES;
}

#pragma mark - Properties

////////////////////////////////////////////////////////////////////////////////

- (void)setOverlayTitleText:(NSString *)overlayTitleText {
  
  overlayTitleText_ = [overlayTitleText copy];
  self.overlayTitleLabel.text = self.overlayTitleText;
}

////////////////////////////////////////////////////////////////////////////////

- (void)setDescriptionText:(NSString *)descriptionText {
  
  descriptionText_ = [descriptionText copy];
  self.descriptionLabel.text = self.descriptionText;
}

#pragma mark - Layout

////////////////////////////////////////////////////////////////////////////////

- (void)layoutLabels {
  
  NSAssert([self isViewLoaded], @"The view needs to be loaded to perform the layout.");
  CGSize newSize = [self.descriptionText sizeWithFont:self.descriptionLabel.font 
                                    constrainedToSize:self.defaultDescriptionSize];
  DDLogVerbose(@"%s -- computed new description label size: (%f, %f). Original = (%f, %f)",
             __PRETTY_FUNCTION__,
             newSize.width,
             newSize.height,
             self.defaultDescriptionSize.width,
             self.defaultDescriptionSize.height);
  CGRect frame = self.descriptionLabel.frame;
  self.descriptionLabel.frame = CGRectMake(frame.origin.x, 
                                           frame.origin.y, 
                                           frame.size.width, 
                                           newSize.height);

  frame = self.cancelButton.frame;
  CGFloat targetY = CGRectGetMaxY(self.descriptionLabel.frame) + 8;
  self.cancelButton.frame = CGRectOffset(frame, 0, targetY - frame.origin.y);
  if (self.skipButton.hidden) {
    
    //
    //  If the skip button is hidden, move cancelButton over to center it in the 
    //  frame.
    //
    
    DDLogVerbose(@"%s -- skip button is hidden. Self = %@, cancel = %@",
               __PRETTY_FUNCTION__,
               self.view,
               self.cancelButton);
    self.cancelButton.frame = CGRectOffset(self.cancelButton.frame, 
                                           CGRectGetMidX(self.view.bounds) - CGRectGetMidX(self.cancelButton.frame),
                                           0);
    NSAssert(CGRectGetMidX(self.view.bounds) == CGRectGetMidX(self.cancelButton.frame), 
                  @"Button should be centered");
  }
  
  frame = self.skipButton.frame;
  self.skipButton.frame   = CGRectOffset(frame, 0, targetY - frame.origin.y);
  
  frame = self.view.frame;
  self.view.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, CGRectGetMaxY(self.cancelButton.frame)+20);
}

#pragma mark - Swiping

////////////////////////////////////////////////////////////////////////////////

- (void)handleSwipe:(UIGestureRecognizer *)gestureRecognizer {
  
  if (gestureRecognizer == self.upRecognizer) {
    
    [self.delegate overlayViewController:self didFinishWithSwipeDirection:UISwipeGestureRecognizerDirectionUp];
    
  } else if (gestureRecognizer == self.downRecognizer) {
    
    [self.delegate overlayViewController:self didFinishWithSwipeDirection:UISwipeGestureRecognizerDirectionDown];
    
  } else if (gestureRecognizer == self.leftRecognizer) {
    
    [self.delegate overlayViewController:self didFinishWithSwipeDirection:UISwipeGestureRecognizerDirectionLeft];
    
  } else if (gestureRecognizer == self.rightRecognizer) {
    
    [self.delegate overlayViewController:self didFinishWithSwipeDirection:UISwipeGestureRecognizerDirectionRight];
    
  } else {
    
    NSAssert(NO, @"Unrecognized swipe gesture recognizer: %@", gestureRecognizer);
  }
}

#pragma mark - Actions

////////////////////////////////////////////////////////////////////////////////

- (void)setSkipDisabled:(BOOL)disabled {
  
  NSAssert([self isViewLoaded], @"View must be loaded to hide skip button");
  self.skipButton.hidden = disabled;
  [self layoutLabels];
}

////////////////////////////////////////////////////////////////////////////////

- (IBAction)didTapCancelButton:(id)sender {
  
  NSAssert(self.delegate != nil, nil);
  [self.delegate overlayViewController:self didFinishWithSwipeDirection:UISwipeGestureRecognizerDirectionDown];
}

////////////////////////////////////////////////////////////////////////////////

- (IBAction)didTapSkipButton:(id)sender {

  NSAssert(self.delegate != nil, nil);
  [self.delegate overlayViewControllerDidSkip:self];
}

@end
