//
//  BDAssetsGroupController.h
//
//  Shows the contents of an assets group.
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

#import <UIKit/UIKit.h>
#import "BDSelectableAsset.h"
#import "BDImagePickerControllerDelegate.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@class ALAssetsGroup;
@protocol BDAssetsSource;

@interface BDAssetsGroupController : UITableViewController<BDSelectableAssetDelegate> {
  
}

//
//  The source of the assets that we show and pick.
//

@property (nonatomic, retain) id<BDAssetsSource> assetsSource;

//
//  Delegate -- gets informed if the user selects some assets.
//

@property (nonatomic, assign) id<BDImagePickerControllerDelegate> delegate;

@end

