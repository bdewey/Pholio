//
//  IPOptimizingPhotoNotification.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 6/24/11.
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
#import "IPOptimizingPhotoNotification.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPOptimizingPhotoNotification

@synthesize mainLabel = mainLabel_;
@synthesize activeOptimizations = activeOptimizations_;

////////////////////////////////////////////////////////////////////////////////
//
//  Designated initializer.
//

- (id)init {
  
  self = [super initWithNibName:nil bundle:nil];
  if (self) {
    // Custom initialization
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release retained properties.
//

- (void)didReceiveMemoryWarning {
  
  [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

////////////////////////////////////////////////////////////////////////////////
//
//  Initialize after loading from the nib.
//

- (void)viewDidLoad {
  
  [super viewDidLoad];
  CALayer *layer = [self.view layer];
  layer.cornerRadius = 10.0;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release any IBOutlet properties.
//

- (void)viewDidUnload {
  
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  
  self.mainLabel = nil;
}

////////////////////////////////////////////////////////////////////////////////
//
//  We support all interface orientations.
//

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  
  // Return YES for supported orientations
  return YES;
}

#pragma mark - Properties

////////////////////////////////////////////////////////////////////////////////
//
//  Set indicator of how many optimizations are ongoing.
//

- (void)setActiveOptimizations:(NSUInteger)activeOptimizations {
  
  activeOptimizations_ = activeOptimizations;
  
  NSString *text;
  
  if (activeOptimizations == 1) {
    
    text = kOptimizationProgressSingular;
    
  } else {
    
    text = [NSString stringWithFormat:kOptimizationProgressPlural, activeOptimizations];
  }
  self.mainLabel.text = text;
}
@end
