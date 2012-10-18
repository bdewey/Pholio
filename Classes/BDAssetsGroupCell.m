//
//  BDAssetGroupCell.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 5/6/11.
//  Copyright 2011 Brian's Brain. All rights reserved.
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

#import <AssetsLibrary/AssetsLibrary.h>
#import "BDAssetsGroupCell.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation BDAssetsGroupCell

@synthesize assetsGroup = assetsGroup_;

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
//  Release any retained properties.
//


////////////////////////////////////////////////////////////////////////////////
//
//  Sets the ALAssetsGroup
//

- (void)setAssetsGroup:(ALAssetsGroup *)assetsGroup {
  
  assetsGroup_ = assetsGroup;
  
  [self.assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
  self.textLabel.text = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
  NSLog(@"%s -- assets = %d", __PRETTY_FUNCTION__, [self.assetsGroup numberOfAssets]);
  self.detailTextLabel.text = [NSString stringWithFormat:@"(%d)",
                               [self.assetsGroup numberOfAssets]
                               ];
  self.imageView.image = [UIImage imageWithCGImage:[self.assetsGroup posterImage]];
  [self setNeedsLayout];
}

@end
