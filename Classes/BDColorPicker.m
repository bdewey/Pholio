//
//  BDColorPicker.m
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

#import "BDColorPicker.h"
#import "UIColor-Expanded.h"
#import <QuartzCore/QuartzCore.h>

@interface BDColorPicker ()

//
//  Configures all sliders, etc. based upon |currentColor|.
//

- (void)configurePicker;

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation BDColorPicker
@synthesize delegate = delegate_;
@synthesize currentColor = currentColor_;
@synthesize hexCode;
@synthesize redSlider;
@synthesize greenSlider;
@synthesize blueSlider;
@synthesize redValue;
@synthesize greenValue;
@synthesize blueValue;
@synthesize colorSwatch;
@synthesize transparencySlider;

////////////////////////////////////////////////////////////////////////////////
//
//  Designated initializer.
//

- (id)init {

  self = [super initWithNibName:nil bundle:nil];
  if (self) {
    // Custom initialization
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release retained properties.
//


////////////////////////////////////////////////////////////////////////////////
//
//  Release any cached data.
//

- (void)didReceiveMemoryWarning {

  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

////////////////////////////////////////////////////////////////////////////////
//
//  View loaded... do any additional initialization.
//

- (void)viewDidLoad {

  [super viewDidLoad];
  
  //
  //  From: http://www.cimgf.com/2010/01/28/fun-with-uibuttons-and-core-animation-layers/
  //
  
  [[colorSwatch layer] setCornerRadius:8.0];
  [[colorSwatch layer] setMasksToBounds:YES];
  [[colorSwatch layer] setBorderWidth:1.0];
  [self configurePicker];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release IBOutlets.
//

- (void)viewDidUnload {

  [self setHexCode:nil];
  [self setRedSlider:nil];
  [self setGreenSlider:nil];
  [self setBlueSlider:nil];
  [self setRedValue:nil];
  [self setGreenValue:nil];
  [self setBlueValue:nil];
  [self setColorSwatch:nil];
  [self setTransparencySlider:nil];
  [super viewDidUnload];
}

////////////////////////////////////////////////////////////////////////////////
//
//  We do all orientations.
//

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

  return YES;
}

#pragma mark - Properties

////////////////////////////////////////////////////////////////////////////////
//
//  Lazy initializer for |currentColor|.
//

- (UIColor *)currentColor {
  
  if (currentColor_ == nil) {
    
    currentColor_ = [UIColor blackColor];
  }
  return currentColor_;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Notify the delegate when the color changes.
//

- (void)setCurrentColor:(UIColor *)currentColor {
  
  currentColor_ = currentColor;
  
  [self.delegate colorPicker:self didPickColor:self.currentColor];
}

#pragma mark - Updating the view

////////////////////////////////////////////////////////////////////////////////
//
//  Configures all of the sliders, etc. based upon the value of |currentColor|.
//

- (void)configurePicker {
  
  //
  //  The easiest control to update?
  //
  
  self.colorSwatch.backgroundColor = self.currentColor;
  self.hexCode.text = [self.currentColor hexStringFromColor];
  
  self.redSlider.value   = [self.currentColor red];
  self.greenSlider.value = [self.currentColor green];
  self.blueSlider.value  = [self.currentColor blue];
  self.transparencySlider.value = [self.currentColor alpha];
  
  self.redValue.text     = [NSString stringWithFormat:@"%d", (int)round([self.currentColor red] * 255.0)];
  self.greenValue.text   = [NSString stringWithFormat:@"%d", (int)round([self.currentColor green] * 255.0)];
  self.blueValue.text    = [NSString stringWithFormat:@"%d", (int)round([self.currentColor blue] * 255.0)];
}

////////////////////////////////////////////////////////////////////////////////
//
//  One of the RGB sliders changed.
//

- (IBAction)sliderChanged:(id)sender {
  
  CGFloat red, blue, green, alpha;
  
  //
  //  Get the RGBA components of the current color.
  //
  
  [self.currentColor red:&red green:&green blue:&blue alpha:&alpha];
  
  //
  //  Update one of the components based on the slider value.
  //
  
  if (sender == self.blueSlider) {
    
    blue = self.blueSlider.value;
    
  } else if (sender == self.greenSlider) {
    
    green = self.greenSlider.value;
    
  } else if (sender == self.redSlider) {
    
    red = self.redSlider.value;
    
  } else if (sender == self.transparencySlider) {
    
    alpha = self.transparencySlider.value;
  }
  
  self.currentColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
  [self configurePicker];
}

#pragma mark - UITextFieldDelegate

////////////////////////////////////////////////////////////////////////////////
//
//  User starts editing. For convenience, select all text.
//

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  
  [textField selectAll:nil];
}

////////////////////////////////////////////////////////////////////////////////
//
//  User hit return. Treat this as an end to editing.
//

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  
  [textField resignFirstResponder];
  return NO;
}

////////////////////////////////////////////////////////////////////////////////
//
//  User finished editing. Update colors.
//

- (void)textFieldDidEndEditing:(UITextField *)textField {
  
  _GTMDevLog(@"%s", __PRETTY_FUNCTION__);
  if (textField == self.hexCode) {
    
    //
    //  User entered something in the hex code field. Let's see if I can decode
    //  it.
    //
    
    UIColor *newColor = [UIColor colorWithHexString:textField.text];
    if (newColor != nil) {
      
      //
      //  Only do this if newColor is non-nil...
      //
      
      self.currentColor = newColor;
    }
    
  } else {
    
    CGFloat red, green, blue, alpha;
    [self.currentColor red:&red green:&green blue:&blue alpha:&alpha];
    CGFloat newComponent = [textField.text integerValue] / (CGFloat)255.0;
    
    if (textField == self.redValue) {
      
      red = newComponent;
      
    } else if (textField == self.greenValue) {
      
      green = newComponent;
      
    } else if (textField == self.blueValue) {
      
      blue = newComponent;
    }
    self.currentColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
  }
  
  [self configurePicker];
}

@end
