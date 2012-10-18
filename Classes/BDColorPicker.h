//
//  BDColorPicker.h
//  ipad-portfolio
//
//  Created by Brian Dewey on 5/24/11.
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

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@protocol BDColorPickerDelegate;
@interface BDColorPicker : UIViewController<UITextFieldDelegate> { }


//
//  Delegate that receives notifications when the color changes.
//

@property (nonatomic, weak) id<BDColorPickerDelegate> delegate;

//
//  The color we're working with.
//

@property (nonatomic, strong) UIColor *currentColor;

//
//  Interface builder outlets
//

@property (nonatomic, strong) IBOutlet UITextField *hexCode;
@property (nonatomic, strong) IBOutlet UISlider *redSlider;
@property (nonatomic, strong) IBOutlet UISlider *greenSlider;
@property (nonatomic, strong) IBOutlet UISlider *blueSlider;
@property (nonatomic, strong) IBOutlet UITextField *redValue;
@property (nonatomic, strong) IBOutlet UITextField *greenValue;
@property (nonatomic, strong) IBOutlet UITextField *blueValue;
@property (nonatomic, strong) IBOutlet UIButton *colorSwatch;
@property (nonatomic, strong) IBOutlet UISlider *transparencySlider;

//
//  Designated initializer.
//

- (id)init;

//
//  Update based upon a slider value changing.
//

- (IBAction)sliderChanged:(id)sender;

@end

@protocol BDColorPickerDelegate <NSObject>

//
//  The color picker picked a new color. This is called continuously as the
//  user does things like play with sliders.
//

- (void)colorPicker:(BDColorPicker *)colorPicker didPickColor:(UIColor *)color;

@end
