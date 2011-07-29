//
//  IPAlert.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 4/11/11.
//  Copyright 2011 Brian Dewey. All rights reserved.
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

#import <UIKit/UIKit.h>
#import "IPAlert.h"

static IPAlert *defaultAlert;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface IPAlert ()

@property (nonatomic, copy) IPAlertAction currentAction;

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPAlert

@synthesize currentAction = currentAction_;

////////////////////////////////////////////////////////////////////////////////

- (void)dealloc {
  
  [currentAction_ release];
  [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////

+ (IPAlert *)defaultAlert {
  if (defaultAlert == nil) {
    defaultAlert = [[IPAlert alloc] retain];
  }
  return defaultAlert;
}

////////////////////////////////////////////////////////////////////////////////

- (void)showErrorMessage:(NSString *)errorMessage {
  
  UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:kProductName 
                                                   message:errorMessage 
                                                  delegate:nil 
                                         cancelButtonTitle:@"OK" 
                                         otherButtonTitles:nil] autorelease];
  [alert show];
}

////////////////////////////////////////////////////////////////////////////////

- (void)confirmWithDescription:(NSString *)description 
                andButtonTitle:(NSString *)buttonTitle 
                      fromRect:(CGRect)rect 
                        inView:(UIView *)view 
                 performAction:(IPAlertAction)action {
  
  self.currentAction = action;
  UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:description 
                                                            delegate:self 
                                                   cancelButtonTitle:nil 
                                              destructiveButtonTitle:buttonTitle 
                                                   otherButtonTitles:nil] autorelease];
  [actionSheet showFromRect:rect inView:view animated:YES];
}

////////////////////////////////////////////////////////////////////////////////

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  
  _GTMDevLog(@"%s -- clicked button index = %d", __PRETTY_FUNCTION__, buttonIndex);
  if ((buttonIndex != -1) && 
      (self.currentAction != nil)) {
    
    self.currentAction();
  }
  self.currentAction = nil;
}

////////////////////////////////////////////////////////////////////////////////

- (void)actionSheetCancel:(UIActionSheet *)actionSheet {
  
  self.currentAction = nil;
}

@end
