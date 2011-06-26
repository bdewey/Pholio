//
//  BDAssetRowCell.h
//
//  This displays 4 images of an asset group in a single table cell row.
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

#import <Foundation/Foundation.h>
#import "BDSmartTableViewCell.h"

#define kAssetsPerRow             4
#define kAssetRowHeight           79

@class ALAssetsGroup;
@interface BDAssetRowCell : BDSmartTableViewCell { }

//
//  The assets we should display in this row. This is an array of
//  |BDSelectableAsset| objects.
//

@property (nonatomic, retain) NSArray *assets;

@end
