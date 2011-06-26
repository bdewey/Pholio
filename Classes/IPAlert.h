//
//  IPAlert.h
//  ipad-portfolio
//
//  This is a simple class that is responsible for alerting the user that an
//  error has happened.
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

#import <Foundation/Foundation.h>

typedef void (^IPAlertAction)(void);

@interface IPAlert : NSObject<UIActionSheetDelegate> {
    
}

//
//  Gets the default alert manager.
//

+ (IPAlert *)defaultAlert;

//
//  Shows an error alert.
//

- (void)showErrorMessage:(NSString *)errorMessage;

- (void)confirmWithDescription:(NSString *)description 
                andButtonTitle:(NSString *)buttonTitle
                      fromRect:(CGRect)rect
                        inView:(UIView *)view
                 performAction:(IPAlertAction)action;


@end
