//
//  IPTutorialController.h
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

#import <UIKit/UIKit.h>

@protocol IPTutorialControllerDelegate;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface IPTutorialController : UIViewController

@property (assign, nonatomic) id<IPTutorialControllerDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIView *background;
@property (retain, nonatomic) IBOutlet UIButton *learnMore;
@property (retain, nonatomic) IBOutlet UIButton *startNow;

- (id)initWithDelegate:(id<IPTutorialControllerDelegate>)delegate;
- (IBAction)didStartLearnMore:(id)sender;
- (IBAction)didStartUsingNow:(id)sender;

@end


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@protocol IPTutorialControllerDelegate <NSObject>

- (void)tutorialControllerDidSelectLearnMore:(IPTutorialController *)controller;
- (void)tutorialControllerDidDismiss:(IPTutorialController *)controller;

@end