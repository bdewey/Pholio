//
//  IPFontPickerCell.m
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

#import "IPFontPickerCell.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPFontPickerCell

@dynamic title;
@synthesize selectedFont = selectedFont_;

////////////////////////////////////////////////////////////////////////////////
//
//  Initializer.
//

- (id)initWithCellIdentifier:(NSString *)cellIdentifier {
  
  self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
  if (self != nil) {
    
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release retained properties.
//


#pragma mark - Properties

////////////////////////////////////////////////////////////////////////////////
//
//  Get the title from textLabel.
//

- (NSString *)title {
  
  return self.textLabel.text;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Sets the title on |textLabel|.
//

- (void)setTitle:(NSString *)title {
  
  self.textLabel.text = title;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Sets the selected font... this updates the detail text label, too.
//

- (void)setSelectedFont:(UIFont *)selectedFont {
  
  selectedFont_ = selectedFont;
  
  self.detailTextLabel.text = [self.selectedFont familyName];
}

@end
