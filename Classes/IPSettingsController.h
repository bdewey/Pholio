//
//  IPSettingsController.h
//  ipad-portfolio
//
//  Created by Brian Dewey on 5/9/11.
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
#import "BDFontPickerController.h"
#import "BDColorPicker.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@protocol IPSettingsControllerDelegate;
@class IPUserDefaults;
@interface IPSettingsController : UITableViewController<
  BDFontPickerControllerDelegate,
  BDColorPickerDelegate
> { }

@property (nonatomic, retain) IPUserDefaults *userDefaults;

//
//  Delegate.
//

@property (nonatomic, assign) id <IPSettingsControllerDelegate> delegate;

//
//  Designated initializer.
//

- (id)init;

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@protocol IPSettingsControllerDelegate <NSObject>

//
//  Email the developer (me!).
//

- (void)ipSettingsMailDeveloper;

//
//  Show the user guide.
//

- (void)ipSettingsShowUserGuide;

//
//  Get the background image name.
//

- (NSString *)ipSettingsBackgroundImageName;

//
//  Set the background image name.
//

- (void)ipSettingsSetBackgroundImageName:(NSString *)backgroundImageName;

//
//  Gets the current text color in grid views.
//

- (UIColor *)ipSettingsGridTextColor;

//
//  Set the text color to use in grid views.
//

- (void)ipSettingsSetGridTextColor:(UIColor *)gridTextColor;

//
//  Gets the current navigation bar color.
//

- (UIColor *)ipSettingsNavigationColor;

//
//  Sets the navigation color.
//

- (void)ipSettingsSetNavigationColor:(UIColor *)navigationColor;

//
//  What is the title font?
//

- (NSString *)ipSettingsTitleFontFamily;

//
//  Title font changed.
//

- (void)ipSettingsDidSetTitleFontFamily:(NSString *)fontFamily;

- (NSString *)ipSettingsTextFontFamily;

- (void)ipSettingsDidSetTextFontFamily:(NSString *)fontFamily;

//
//  Should we allow "mail current photo"?
//

- (BOOL)ipSettingsShouldMailCurrentPhoto;

//
//  Mail the current photo.
//

- (void)ipSettingsMailCurrentPhoto;

@end