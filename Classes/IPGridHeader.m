//
//  IPGridHeader.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 7/24/11.
//  Copyright 2011 Brian's Brain. All rights reserved.
//

#import "IPGridHeader.h"
#import "UIImage+ColorMask.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPGridHeader

@synthesize label = label_;
@synthesize settingsButton = settingsButton_;
@synthesize delegate = delegate_;
@synthesize foregroundColor = foregroundColor_;

////////////////////////////////////////////////////////////////////////////////

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {

  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {

  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////

- (void)dealloc {
  
  [label_ release];
  [settingsButton_ release];
  [foregroundColor_ release];
  [super dealloc];
}

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
  // Do any additional setup after loading the view from its nib.
}

////////////////////////////////////////////////////////////////////////////////

- (void)viewDidUnload {

  [super viewDidUnload];
  self.label = nil;
  self.settingsButton = nil;
}

////////////////////////////////////////////////////////////////////////////////

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Properties

////////////////////////////////////////////////////////////////////////////////

- (void)setForegroundColor:(UIColor *)foregroundColor {
  
  if (foregroundColor == foregroundColor_) {
    
    return;
  }
  [foregroundColor_ release];
  foregroundColor_ = [foregroundColor retain];
  
  self.label.textColor = foregroundColor;
  self.settingsButton.imageView.image = [[UIImage imageNamed:@"19-gear.png"] imageAsMaskOnColor:foregroundColor];
}

#pragma mark - Handle events

////////////////////////////////////////////////////////////////////////////////

- (IBAction)didTapSettings:(id)sender {
  
  [self.delegate gridHeaderDidTapSettings:self];
}

@end
