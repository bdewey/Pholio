//
//  BDAssetGroupController.h
//
//  Table view controller that shows all of the asset groups in the asset library.
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
#import "BDAssetsGroupController.h"
#import "BDImagePickerControllerDelegate.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface BDAssetsLibraryController : UITableViewController<BDImagePickerControllerDelegate> {
    
}

//
//  The asset groups that we are showing in this controller.
//

@property (nonatomic, retain) NSMutableArray *groups;

@property (nonatomic, retain) id<BDImagePickerControllerDelegate> delegate;

@end

