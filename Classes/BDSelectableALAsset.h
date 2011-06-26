//
//  BDSelectableALAsset.h
//
//  Class that selects ALAsset objects.
//
//  Created by Brian Dewey on 5/19/11.
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

#import <Foundation/Foundation.h>
#import "BDSelectableAsset.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@class ALAsset;
@protocol BDSelectableAssetDelegate;
@interface BDSelectableALAsset : NSObject<BDSelectableAsset> { }

//
//  the asset.
//

@property (nonatomic, retain) ALAsset *asset;

//
//  Its selection state.
//

@property (nonatomic, assign, getter = isSelected) BOOL selected;

//
//  Delegate.
//

@property (nonatomic, assign) id<BDSelectableAssetDelegate> delegate;

//
//  Designated initializer.
//

- (id)initWithAsset:(ALAsset *)asset;

//
// Convenience constructor.
//

+ (BDSelectableALAsset *)selectableAssetWithAsset:(ALAsset *)asset;

@end

