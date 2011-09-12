//
//  IPDropBoxAssetsSource.m
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

#import "IPDropBoxAssetsSource.h"
#import "BDSelectableAsset.h"
#import "IPDropBoxSelectableAsset.h"
#import "DropboxSDK.h"

@interface IPDropBoxAssetsSource ()

@property (nonatomic, copy) void (^completion)();
@property (nonatomic, retain) id<BDSelectableAssetDelegate> assetDelegate;
@property (nonatomic, retain) NSMutableArray *children;
@property (nonatomic, retain) NSMutableArray *assets;
@property (nonatomic, retain) DBRestClient *restClient;

@end

@implementation IPDropBoxAssetsSource

@synthesize path = path_;
@synthesize completion = completion_;
@synthesize assetDelegate = assetDelegate_;
@synthesize children = children_;
@synthesize assets = assets_;
@synthesize restClient = restClient_;

////////////////////////////////////////////////////////////////////////////////

- (id)init {

  self = [super init];
  if (self) {

    restClient_ = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    restClient_.delegate = self;
  }
  
  return self;
}

////////////////////////////////////////////////////////////////////////////////

- (void)dealloc {
  
  [path_ release], path_ = nil;
  [completion_ release], completion_ = nil;
  [assetDelegate_ release], assetDelegate_ = nil;
  [children_ release], children_ = nil;
  [assets_ release], assets_ = nil;
  [restClient_ release], restClient_ = nil;
  [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////

- (NSString *)title {
  
  return path_;
}

#pragma mark - BDAssetsSource

////////////////////////////////////////////////////////////////////////////////

- (void)asyncFillArrayWithChildren:(NSMutableArray *)children 
                         andAssets:(NSMutableArray *)assets 
       withSelectableAssetDelegate:(id<BDSelectableAssetDelegate>)delegate 
                        completion:(void (^)())completion {
  
  self.assetDelegate = delegate;
  self.completion = completion;
  self.children = children;
  self.assets = assets;
  [self.restClient loadMetadata:self.path];
}

#pragma mark - DBRestClientDelegate

////////////////////////////////////////////////////////////////////////////////

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
  
  for (DBMetadata *child in metadata.contents) {
    
    if (child.isDirectory) {
      
      IPDropBoxAssetsSource *childSource = [[[IPDropBoxAssetsSource alloc] init] autorelease];
      childSource.path = child.path;
      [self.children addObject:childSource];
    }
    if (child.thumbnailExists) {
      
      IPDropBoxSelectableAsset *asset = [[[IPDropBoxSelectableAsset alloc] init] autorelease];
      asset.metadata = child;
      asset.delegate = self.assetDelegate;
      [self.assets addObject:asset];
    }
  }
  self.completion();
}

////////////////////////////////////////////////////////////////////////////////

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
  
  self.completion();
}

@end
