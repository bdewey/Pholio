//
//  IPDropBoxSelectableAsset.h
//  ipad-portfolio
//
//  Created by Brian Dewey on 9/7/11.
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
#import "DropboxSDK.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@class DBMetadata;
@interface IPDropBoxSelectableAsset : NSObject<
  BDSelectableAsset,
  DBRestClientDelegate>

//
//  The metadata object that identifies the file to download from DropBox.
//

@property (nonatomic, retain) DBMetadata *metadata;

//
//  Whether or not this image is selected for download.
//

@property (nonatomic, assign, getter = isSelected) BOOL selected;

//
//  Gets notified when selection state changes.
//

@property (nonatomic, assign) id<BDSelectableAssetDelegate> delegate;

//
//  For debugging only.
//

@property (nonatomic, retain) DBRestClient *restClient;

//
//  Gets the thumbnail for the asset.
//

- (void)thumbnailAsyncWithCompletion:(void(^)(UIImage *thumbnail))completion;

//
//  Gets the image for the asset.
//

- (void)imageAsyncWithCompletion:(void(^)(NSString *filename, NSString *uti))completion;

//
//  Gets the title of the asset.
//

- (NSString *)title;

@end
