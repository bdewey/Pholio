//
//  BDSelectableImageThumbnail.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 5/6/11.
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

#import "BDSelectableImageThumbnail.h"
#import "BDSelectableAsset.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface BDSelectableImageThumbnail ()

//
//  The main image
//

@property (nonatomic, strong) UIImageView *mainImage;

//
//  Contains our overlay image
//

@property (nonatomic, strong) UIImageView *overlay;

//
//  Activity indicator; spins until we have an image.
//

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation BDSelectableImageThumbnail

@dynamic image;
@dynamic selected;
@synthesize delegate = delegate_;
@synthesize mainImage = mainImage_;
@synthesize overlay = overlay_;
@synthesize activityIndicator = activityIndicator_;

////////////////////////////////////////////////////////////////////////////////
//
//  Init.
//

- (id)initWithFrame:(CGRect)frame {

  self = [super initWithFrame:frame];
  if (self) {

    self.mainImage = [[UIImageView alloc] initWithFrame:self.bounds];
    self.mainImage.contentMode = UIViewContentModeScaleAspectFill;
    self.mainImage.clipsToBounds = YES;
    self.overlay   = [[UIImageView alloc] initWithFrame:self.bounds];
    self.overlay.image = [UIImage imageNamed:@"Overlay.png"];
    self.selected  = NO;
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator.center = self.center;
    [self.activityIndicator startAnimating];
    
    [self addSubview:self.mainImage];
    [self addSubview:self.overlay];
    [self addSubview:self.activityIndicator];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleSelection)];
    [self addGestureRecognizer:tap];
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
//  Sets the image on |mainImage|.
//

- (void)setImage:(UIImage *)image {
  
  self.mainImage.image = image;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Gets the image from |mainImages|.
//

- (UIImage *)image {
  
  return self.mainImage.image;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Sets the delegate and updates the selection state.
//

- (void)setDelegate:(id<BDSelectableAsset>)delegate {
  
  delegate_ = delegate;
  self.selected = [self.delegate isSelected];
  [self.delegate thumbnailAsyncWithCompletion:^(UIImage *thumbnail) {
    self.image = thumbnail;
    [self.activityIndicator stopAnimating];
  }];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Selection state is determined by whether the overlay is visible.
//

- (BOOL)selected {
  
  return [self.delegate isSelected];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Sets the selection state by controlling the visibility of the overlay.
//  Selected == overlay visible == overlay not hidden.
//

- (void)setSelected:(BOOL)selected {
  
  [self.delegate setSelected:selected];
  self.overlay.hidden = !selected;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Toggle the selection state.
//

- (void)toggleSelection {
  
  self.selected = !self.selected;
}

@end
