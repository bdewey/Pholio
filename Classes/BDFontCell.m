//
//  BDFontCell.m
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

#import "BDFontCell.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation BDFontCell

@synthesize fontFamilyName = fontFamilyName_;

////////////////////////////////////////////////////////////////////////////////
//
//  Initializer.
//

- (id)initWithCellIdentifier:(NSString *)cellIdentifier {
  
  self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
  return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release retained properties.
//

- (void)dealloc {
  
  [fontFamilyName_ release];
  [super dealloc];
}

#pragma mark - Properties

////////////////////////////////////////////////////////////////////////////////
//
//  Set the font family name. This also updates the styling of the text label.
//

- (void)setFontFamilyName:(NSString *)fontFamilyName {
  
  [fontFamilyName_ autorelease];
  fontFamilyName_ = [fontFamilyName copy];
  
  self.textLabel.text = fontFamilyName;
  self.textLabel.font = [UIFont fontWithName:fontFamilyName size:[UIFont buttonFontSize]];
}
@end
