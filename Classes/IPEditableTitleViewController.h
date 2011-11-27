//
//  IPEditableTitleViewController.h
//
//  You are supposed to subclass this view controller.
//  What it provides is a |UITextField| as the |navigationItem.titleView|.
//  The view controller is set up as the delegate of the view. When you
//  subclass this view, set |navigationItem.titleView.text| instead of
//  |navigationItem.title| when you want to set the title text. To take
//  action when the user is done editing, override |textFieldDidEndEditing:|.
//
//  Created by Brian Dewey on 4/29/11.
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
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "IPSettingsController.h"
#import "BDGridView.h"
#import "BDOverlayViewController.h"


typedef void (^IPSetGridControllerDidPickImageBlock)(UIImage *image, NSDictionary *options);

@class IPAlert;
@class IPUserDefaults;
@class IPPortfolio;
@class IPTutorialManager;
@class IPTutorialController;
@interface IPEditableTitleViewController : UIViewController<
  UITextFieldDelegate,
  UIImagePickerControllerDelegate,
  UINavigationControllerDelegate,
  UIPopoverControllerDelegate,
  IPSettingsControllerDelegate,
  MFMailComposeViewControllerDelegate,
  BDOverlayViewControllerDelegate,
  BDGridViewDelegate
>{
    
}

//
//  This is the portfolio that's being displayed. This base class uses
//  the portfolio to pick things like fonts.
//

@property (nonatomic, retain) IPPortfolio *portfolio;

//
//  We put our title in a text field so it can be editable.
//

@property (nonatomic, retain) UITextField *titleTextField;

//
//  Image picker.
//

@property (nonatomic, retain) UIImagePickerController *defaultPicker;

//
//  Currently active popover controller.
//

@property (nonatomic, retain) UIPopoverController *popoverController;

//
//  |IPAlert| object for communicating with the user. Setting this object
//  is completely optional; primarily done for unit testing.
//

@property (nonatomic, retain) IPAlert *alertManager;

//
//  Access the user defaults.
//

@property (nonatomic, retain) IPUserDefaults *userDefaults;

//
//  The background view.
//

@property (nonatomic, retain) IBOutlet UIImageView *backgroundImage;

//
//  The name of the background image. You can set this property and change
//  |backgroundImage|.
//

@property (nonatomic, copy) NSString *backgroundImageName;

//
//  Pointer to the tutorial manager... this maintains where the user is
//  in the tutorial.
//

@property (nonatomic, retain) IPTutorialManager *tutorialManager;

//
//  If we're showing a tutorial, this is the controller.
//

@property (nonatomic, retain) IPTutorialController *tutorialController;

//
//  Overlay. You can have at most one, but it can be used for many things.
//

@property (nonatomic, retain) BDOverlayViewController *overlayController;

//
//  Dismisses our popover controller.
//

- (void)dismissPopover;

//
//  Gets a popover controller all set up to show the settings picker.
//

- (UIPopoverController *)settingsPopover;

//
//  Presents a UIImagePickerController and executes |block| if the user
//  selects an image.
//

- (void)presentImagePickerFromRect:(CGRect)rect
                            inView:(UIView *)view
                   andPerformBlock:(IPSetGridControllerDidPickImageBlock)block;

//
//  Sets the background image to a specific name.
//

- (void)setBackgroundImageName:(NSString *)backgroundImageName;

//
//  Starts running the tutorial.
//

- (void)startTutorial;


@end
