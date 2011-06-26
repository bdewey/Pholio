//
//  BDCustomAlert.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 6/6/11.
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

#import "BDCustomAlert.h"

@interface BDCustomAlert ()

@property (nonatomic, copy) NSString *cancelTitle;
@property (nonatomic, copy) BDCustomAlertAction cancelBlock;
@property (nonatomic, copy) NSString *otherTitle;
@property (nonatomic, copy) BDCustomAlertAction otherBlock;

- (id)initWithTitle:(NSString *)title 
            message:(NSString *)message 
        cancelTitle:(NSString *)cancelTitle 
        cancelBlock:(BDCustomAlertAction)cancelBlock 
         otherTitle:(NSString *)otherTitle 
         otherBlock:(BDCustomAlertAction)otherBlock;

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation BDCustomAlert

@synthesize cancelTitle = cancelTitle_;
@synthesize cancelBlock = cancelBlock_;
@synthesize otherTitle = otherTitle_;
@synthesize otherBlock = otherBlock_;

////////////////////////////////////////////////////////////////////////////////
//
//  Initialize.
//

- (id)initWithTitle:(NSString *)title 
            message:(NSString *)message 
        cancelTitle:(NSString *)cancelTitle 
        cancelBlock:(BDCustomAlertAction)cancelBlock 
         otherTitle:(NSString *)otherTitle 
         otherBlock:(BDCustomAlertAction)otherBlock {
  
  self = [super initWithTitle:title 
                      message:message 
                     delegate:self 
            cancelButtonTitle:cancelTitle 
            otherButtonTitles:otherTitle, nil];
  if (self != nil) {
    
    self.cancelTitle = cancelTitle;
    self.cancelBlock = cancelBlock;
    self.otherTitle = otherTitle;
    self.otherBlock = otherBlock;
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release retained properties.
//

- (void)dealloc {
  
  [cancelTitle_ release];
  [cancelBlock_ release];
  [otherTitle_ release];
  [otherBlock_ release];
  [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Convenience constructor.
//

+ (void)showWithTitle:(NSString *)title 
              message:(NSString *)message 
          cancelTitle:(NSString *)cancelTitle 
          cancelBlock:(BDCustomAlertAction)cancelBlock 
           otherTitle:(NSString *)otherTitle 
           otherBlock:(BDCustomAlertAction)otherBlock {
  
  BDCustomAlert *alert = [[[BDCustomAlert alloc] initWithTitle:title 
                                                       message:message 
                                                   cancelTitle:cancelTitle 
                                                   cancelBlock:cancelBlock 
                                                    otherTitle:otherTitle 
                                                    otherBlock:otherBlock] autorelease];
  [alert show];
}

#pragma mark - UIAlertViewDelegate

////////////////////////////////////////////////////////////////////////////////
//
//  Invoke blocks as needed.
//

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
  
  NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
  if ([buttonTitle isEqualToString:self.cancelTitle]) {
    
    if (self.cancelBlock != nil) {
      
      self.cancelBlock();
    }
    
  } else if ([buttonTitle isEqualToString:self.otherTitle]) {
    
    if (self.otherBlock != nil) {
      
      self.otherBlock();
    }
  }
}

@end
