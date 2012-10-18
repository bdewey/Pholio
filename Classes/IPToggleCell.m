//
//  IPToggleCell.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 7/27/11.
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

#import "IPToggleCell.h"

@interface IPToggleCell ()

@property (nonatomic, strong) UISwitch *visibleSwitch;

- (void)didToggle;
@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPToggleCell

@synthesize delegate = delegate_;
@dynamic text;
@dynamic on;
@synthesize visibleSwitch = visibleSwitch_;

////////////////////////////////////////////////////////////////////////////////

- (id)initWithCellIdentifier:(NSString *)cellIdentifier {
  
  self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
  if (self != nil) {
    
    visibleSwitch_ = [[UISwitch alloc] initWithFrame:CGRectZero];
    [self addSubview:visibleSwitch_];
    [visibleSwitch_ addTarget:self action:@selector(didToggle) forControlEvents:UIControlEventValueChanged];
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////

- (void)layoutSubviews {
  
  [super layoutSubviews];
  CGFloat rightMargin = 40;
  CGFloat x = self.bounds.size.width - self.visibleSwitch.frame.size.width - rightMargin;
  CGFloat y = (self.bounds.size.height - self.visibleSwitch.frame.size.height) / 2;
  self.visibleSwitch.frame = CGRectMake(x, y, self.visibleSwitch.frame.size.width, self.visibleSwitch.frame.size.height);
}

#pragma mark - Properties

////////////////////////////////////////////////////////////////////////////////

- (NSString *)text {
  
  return self.textLabel.text;
}

////////////////////////////////////////////////////////////////////////////////

- (void)setText:(NSString *)text {
  
  self.textLabel.text = text;
}

////////////////////////////////////////////////////////////////////////////////

- (BOOL)isOn {
  
  return [self.visibleSwitch isOn];
}

////////////////////////////////////////////////////////////////////////////////

- (void)setOn:(BOOL)on {
  
  [self.visibleSwitch setOn:on];
}

#pragma mark - Actions

////////////////////////////////////////////////////////////////////////////////

- (void)didToggle {
  
  [self.delegate toggleCell:self didSetOn:self.on];
}

@end
