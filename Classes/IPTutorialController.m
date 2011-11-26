//
//  IPTutorialController.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 11/13/11.
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

#import "IPTutorialController.h"

@implementation IPTutorialController
@synthesize delegate = delegate_;
@synthesize background;
@synthesize learnMore;
@synthesize startNow;

- (id)initWithDelegate:(id<IPTutorialControllerDelegate>)delegate {
  
  self = [super initWithNibName:nil bundle:nil];
  if (self) {
    
    self.delegate = delegate;
  }
  return self;
}

- (void)dealloc {
  [background release];
  [learnMore release];
  [startNow release];
  [super dealloc];
}


- (void)didReceiveMemoryWarning {
  
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
  
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload {
  
  [self setBackground:nil];
  [self setLearnMore:nil];
  [self setStartNow:nil];
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  return YES;
}

#pragma mark - Actions

- (IBAction)didStartLearnMore:(id)sender {
  
  [self.delegate tutorialControllerDidSelectLearnMore:self];
}

- (IBAction)didStartUsingNow:(id)sender {
  
  [self.delegate tutorialControllerDidDismiss:self];
}
@end
