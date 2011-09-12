//
//  BDAssetsSourceCell.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 9/10/11.
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

#import "BDAssetsSourceCell.h"
#import "BDAssetsSource.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation BDAssetsSourceCell

@synthesize assetsSource = assetsSource_;

////////////////////////////////////////////////////////////////////////////////

- (id)initWithCellIdentifier:(NSString *)cellIdentifier {
  
  self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
  if (self != nil) {
    
    self.textLabel.text = [self.assetsSource title];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////

- (void)dealloc {
  
  [assetsSource_ release], assetsSource_ = nil;
  [super dealloc];
}

#pragma mark - Properties

////////////////////////////////////////////////////////////////////////////////

- (void)setAssetsSource:(id<BDAssetsSource>)assetsSource {
  
  if (assetsSource == assetsSource_) {
    
    return;
  }
  [assetsSource_ release];
  assetsSource_ = [assetsSource retain];
  self.textLabel.text = [self.assetsSource title];
  if ([self.assetsSource respondsToSelector:@selector(asyncThumbnail:)]) {
    
    [self.assetsSource asyncThumbnail:^(UIImage *thumbnail) {
      
      self.imageView.image = thumbnail;
      [self setNeedsLayout];
    }];
  }
}

@end
