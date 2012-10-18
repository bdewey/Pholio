//
//  BDOverlayViewController.h
//
//  Manages a view that has a translucent, rounded rectangle background,
//  a title label, and a description label.
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

#import <UIKit/UIKit.h>

@protocol BDOverlayViewControllerDelegate;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface BDOverlayViewController : UIViewController

@property (nonatomic, weak) id<BDOverlayViewControllerDelegate> delegate;
@property (nonatomic, copy) NSString *overlayTitleText;
@property (nonatomic, copy) NSString *descriptionText;

- (id)initWithDelegate:(id<BDOverlayViewControllerDelegate>)delegate;
- (void)layoutLabels;
- (void)setSkipDisabled:(BOOL)disabled;

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@protocol BDOverlayViewControllerDelegate <NSObject>

- (void)overlayViewController:(BDOverlayViewController *)controller didFinishWithSwipeDirection:(UISwipeGestureRecognizerDirection)direction;
- (void)overlayViewControllerDidSkip:(BDOverlayViewController *)controller;

@end
