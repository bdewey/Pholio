//
//  IPColorCell.m
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

#import "IPColorCell.h"
#import <QuartzCore/QuartzCore.h>

@interface IPColorCell ()

//
//  Color swatch.
//

@property (nonatomic, retain) UIView *swatch;

@end
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPColorCell

@dynamic title;
@synthesize color = color_;
@synthesize swatch = swatch_;

////////////////////////////////////////////////////////////////////////////////
//
//  Initializer.
//

- (id)initWithCellIdentifier:(NSString *)cellIdentifier {
  
  self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
  if (self != nil) {
    
    self.swatch = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    [[self.swatch layer] setCornerRadius:5.0];
    [[self.swatch layer] setMasksToBounds:YES];
    [[self.swatch layer] setBorderWidth:1.0];
    [self addSubview:self.swatch];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release retained properties.
//

- (void)dealloc {
  
  [color_ release];
  [swatch_ release];
  [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Position the swatch in the cell.
//

- (void)layoutSubviews {
  
  [super layoutSubviews];
  
  //
  //  Position the swatch.
  //
  
  CGFloat swatchSize = 35;
  CGFloat rightMargin = 40;
  CGFloat x = self.bounds.size.width - swatchSize - rightMargin;
  CGFloat y = (self.bounds.size.height - swatchSize) / 2;
  CGRect swatchFrame = CGRectMake(x, y, swatchSize, swatchSize);
  self.swatch.frame = swatchFrame;
}

#pragma mark - Properties

////////////////////////////////////////////////////////////////////////////////
//
//  Sets the color, and updates the swatch w/ the color.
//

- (void)setColor:(UIColor *)color {
  
  [color_ autorelease];
  color_ = [color retain];
  
  self.swatch.backgroundColor = color;
  [self setNeedsLayout];
}

////////////////////////////////////////////////////////////////////////////////

- (NSString *)title {
  
  return self.textLabel.text;
}

////////////////////////////////////////////////////////////////////////////////

- (void)setTitle:(NSString *)title {
  
  self.textLabel.text = title;
}

@end
