//
//  BDGridCell.m
//
//  Created by Brian Dewey on 4/20/11.
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

#import <QuartzCore/QuartzCore.h>
#import "IPColors.h"
#import "BDGridCell.h"

#define kDefaultCaptionHeight                 (21)

////////////////////////////////////////////////////////////////////////////////
//  Private methods & properties

@interface BDGridCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIView *labelView;

@end


@implementation BDGridCell

@dynamic image;
@synthesize style = style_;
@dynamic caption;
@dynamic fontColor;
@synthesize labelBackgroundColor = labelBackgroundColor_;
@dynamic font;
@synthesize index = index_;
@synthesize contentInset = contentInset_;
@synthesize captionHeight = captionHeight_;
@synthesize imageView = imageView_;
@synthesize label = label_;
@synthesize labelView = labelView_;
@synthesize selected = selected_;

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)configureWithStyle:(BDGridCellStyle)style {

  style_ = style;
  captionHeight_ = kDefaultCaptionHeight;
  self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
  self.labelBackgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
  
  //
  //  Construct a view for holding our label.
  //
  
  self.labelView = [[UIView alloc] initWithFrame:CGRectZero];
  self.labelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
  
  
  self.label = [[UILabel alloc] init];
  self.label.textAlignment = UITextAlignmentCenter;
  self.label.textColor = [UIColor whiteColor];
  self.label.backgroundColor = [UIColor clearColor];
  self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.labelView addSubview:self.label];
  
  self.imageView = [[UIImageView alloc] init];
  self.imageView.clipsToBounds = YES;
  self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
  UIViewAutoresizingFlexibleHeight |
  UIViewAutoresizingFlexibleBottomMargin;
  [self addSubview:self.imageView];
  [self addSubview:self.labelView];
  [self repositionImageAndLabel];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Reposition image & label as a result of a layout change.
//

- (void)layoutSubviews {
  
  [self repositionImageAndLabel];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Repositions |self.image| and |self.label| after a change to |contentInset|
//  or |captionHeight| (or anything else in the future that may result in a 
//  change to how the subviews fit).
//
//  The basic layout is that |imageView| and |label| take the full width of the
//  view. |imageView| is on top of |label|, with |label| having height 
//  |captionHeight|.
//

- (void)repositionImageAndLabel {
  
  //
  //  Compute the image rectangle
  //
  
  CGRect contentRect = UIEdgeInsetsInsetRect(self.bounds, self.contentInset);
  contentRect = CGRectStandardize(contentRect);
  CGRect imageFrame, labelFrame;
  
  //
  //  Image size depends on the cell style.
  //
  
  switch (self.style) {
    case BDGridCellStyleDefault:
      imageFrame = CGRectMake(contentRect.origin.x, 
                              contentRect.origin.y,
                              contentRect.size.width, 
                              contentRect.size.height - self.captionHeight);
      break;
      
    case BDGridCellStyleTile:
      imageFrame = contentRect;
      break;
  }
  
  //
  //  No matter what, the label goes at the bottom of |contentRect|.
  //
  
  labelFrame = CGRectMake(contentRect.origin.x,
                          contentRect.origin.y + (contentRect.size.height - self.captionHeight),
                          contentRect.size.width,
                          self.captionHeight);
  self.imageView.frame = imageFrame;
  self.labelView.frame = labelFrame;
}

#pragma mark -
#pragma mark Properties

////////////////////////////////////////////////////////////////////////////////
//
//  Sets the caption height.
//

- (void)setCaptionHeight:(CGFloat)captionHeight {
  captionHeight_ = captionHeight;
  [self repositionImageAndLabel];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Sets the content inset.
//

- (void)setContentInset:(UIEdgeInsets)contentInset {
  
  contentInset_ = contentInset;
  [self repositionImageAndLabel];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Gets |image| by retrieving it |imageView_|.
//

- (UIImage *)image {
  
  return self.imageView.image;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Sets |image| by storing it in |imageView_|.
//

- (void)setImage:(UIImage *)image {
  
  self.imageView.image = image;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Gets |caption| from |self.label.text|.
//

- (NSString *)caption {
  
  return self.label.text;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Sets |caption| by storing it in |self.label.text|.
//

- (void)setCaption:(NSString *)caption {
  
  self.label.text = caption;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Gets |fontColor| from |self.label|.
//

- (UIColor *)fontColor {
  
  return self.label.textColor;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Sets |fontColor| on |self.label|.
//

- (void)setFontColor:(UIColor *)fontColor {
  
  if (self.style == BDGridCellStyleTile) {
    
    //
    //  If we're a tile, then the font color should always be white.
    //
    
    return;
  }
  self.label.textColor = fontColor;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Gets |font| from |self.label|.
//

- (UIFont *)font {
  
  return self.label.font;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Sets |font| on |self.label|.
//

- (void)setFont:(UIFont *)font {
  
  self.label.font = font;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Sets the selected state. When selected, draw a simple border around 
//  the cell.
//

- (void)setSelected:(BOOL)selected {
  
  selected_ = selected;
  if (selected_) {
    
    self.layer.borderWidth = 2.0;
    self.layer.borderColor = [[[IPColors defaultColors] highlightColor] CGColor];
    
  } else {
    
    self.layer.borderWidth = 0.0;
  }
}

////////////////////////////////////////////////////////////////////////////////

- (void)setStyle:(BDGridCellStyle)style {
  
  style_ = style;
  [self configureWithStyle:style_];
  switch (self.style) {
    case BDGridCellStyleTile:
      self.imageView.contentMode = UIViewContentModeScaleAspectFill;
      self.labelView.backgroundColor = self.labelBackgroundColor;
      break;

    case BDGridCellStyleDefault:
    default:
      self.imageView.contentMode = UIViewContentModeScaleAspectFit;
      self.labelView.backgroundColor = nil;
      break;
      
  }
}

////////////////////////////////////////////////////////////////////////////////

- (void)setLabelBackgroundColor:(UIColor *)labelBackgroundColor {
  
  if (labelBackgroundColor == labelBackgroundColor_) {
    
    return;
  }
  labelBackgroundColor_ = [labelBackgroundColor colorWithAlphaComponent:0.5];
  
  if (self.style == BDGridCellStyleTile) {
    
    self.labelView.backgroundColor = labelBackgroundColor_;
  }
}

@end
