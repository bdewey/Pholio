//
//  BDCustomAlert.h
//
//  Inspired by IOS Recipes, this is a block-oriented convenience class for
//  displaying alerts.
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

#import <Foundation/Foundation.h>

//
//  Our action block type.
//

typedef void (^BDCustomAlertAction)(void);

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface BDCustomAlert : UIAlertView<UIAlertViewDelegate> { }

+ (void)showWithTitle:(NSString *)title 
              message:(NSString *)message 
          cancelTitle:(NSString *)cancelTitle 
          cancelBlock:(BDCustomAlertAction)cancelBlock 
           otherTitle:(NSString *)otherTitle 
           otherBlock:(BDCustomAlertAction)otherBlock;
@end
