//
//  BDAssetRowCell.m
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
#import "BDAssetRowCell.h"
#import "BDSelectableAsset.h"
#import "BDSelectableImageThumbnail.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface BDAssetRowCell ()

@property (nonatomic, retain) NSMutableArray *assetViews;

- (void)createAssetViews;

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation BDAssetRowCell

@synthesize assets = assets_;
@synthesize assetViews = assetViews_;

////////////////////////////////////////////////////////////////////////////////
//
//  Initializer.
//

- (id)initWithCellIdentifier:(NSString *)cellIdentifier {
  
  self = [super initWithCellIdentifier:cellIdentifier];
  if (self != nil) {
    
    self.assetViews = [NSMutableArray arrayWithCapacity:kAssetsPerRow];
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release all retained properties.
//

- (void)dealloc {
  
  [assets_ release];
  [assetViews_ release];
  [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Sets the assets... need to create a UIImageView per asset.
//

- (void)setAssets:(NSArray *)assets {
  
  [assets_ autorelease];
  assets_ = [assets retain];
  
  for (UIView *subview in self.assetViews) {
    
    [subview removeFromSuperview];
  }
  [self.assetViews removeAllObjects];
  [self createAssetViews];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Creates the asset views for |assets|.
//

- (void)createAssetViews {
  
  for (id<BDSelectableAsset> selectableAsset in self.assets) {
    
    BDSelectableImageThumbnail *imageView = [[[BDSelectableImageThumbnail alloc] initWithFrame:CGRectMake(0, 0, 75, 75)] autorelease];
    imageView.delegate = selectableAsset;
    [self.assetViews addObject:imageView];
    [self addSubview:imageView];
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  Draw our subcells.
//

- (void)layoutSubviews {

  CGRect initialFrame = CGRectMake(4, 2, 75, 75);
  for (UIImageView *imageView in self.assetViews) {

    imageView.frame = initialFrame;
    initialFrame = CGRectOffset(initialFrame, 4 + initialFrame.size.width, 0);
  }
}

@end
