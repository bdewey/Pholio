//
//  BDSplashScreen.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 4/16/11.
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

#import "BDSplashScreen.h"


@implementation BDSplashScreen

#pragma mark Properties

@synthesize splashImage = splashImage_;
@synthesize showsStatusBarOnDismissal = showsStatusBarOnDismissal_;
@synthesize delegate = delegate_;

//
//  Lazy initializer for |splashImage|. If no image was set, uses "Default.png"
//  from the application bundle.
//

- (UIImage *)splashImage {
  
  if (splashImage_ == nil) {
    splashImage_ = [UIImage imageNamed:@"Default.png"];
  }
  return splashImage_;
}

//
//  Constructs the view... which is just a UIImageView.
//

- (void)loadView {
  
  UIImageView *iv = [[[UIImageView alloc] initWithImage:self.splashImage] autorelease];
  iv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  iv.contentMode = UIViewContentModeCenter;
  self.view = iv;
}

//
//  Support all orientations.
//

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {

  return YES;
}

//
//  When we're about to appear, let the delegate know.
//  Also, immediately go away.
//

- (void)viewDidAppear:(BOOL)animated {
  
  [super viewDidAppear:animated];
  if ([self.delegate respondsToSelector:@selector(splashScreenDidAppear:)]) {
    [self.delegate splashScreenDidAppear:self];
  }
  [self hide];
}

//
//  We're going away. Let the delegate know.
//

- (void)viewWillDisappear:(BOOL)animated {
  
  [super viewWillDisappear:animated];
  if ([self.delegate respondsToSelector:@selector(splashScreenWillDisappear:)]) {
    [self.delegate splashScreenWillDisappear:self];
  }
}

//
//  We went away. Let the delegate know.
//

- (void)viewDidDisappear:(BOOL)animated {
  
  [super viewDidDisappear:animated];
  if ([self.delegate respondsToSelector:@selector(splashScreenDidDisappear:)]) {
    [self.delegate splashScreenDidDisappear:self];
  }
}

//
//  Dismisses the splash screen.
//

- (void)hide {
  if (self.showsStatusBarOnDismissal) {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
  }
  [self dismissModalViewControllerAnimated:YES];
}

//
//  Dispose of the object.
//

- (void)dealloc {
  
  [splashImage_ release];
  [super dealloc];
}

@end
