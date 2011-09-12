//
//  IPDropBoxSelectableAsset.m
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

#import "IPDropBoxSelectableAsset.h"
#import "DropboxSDK.h"
#import "NSString+TestHelper.h"
#import "IPPhoto.h"

@interface IPDropBoxSelectableAsset()

@property (nonatomic, copy) void (^thumbnailCompletion)(UIImage *thumbnail);
@property (nonatomic, copy) void (^imageCompletion)(NSString *filename, NSString *uti);

@end

@implementation IPDropBoxSelectableAsset

@synthesize metadata = metadata_;
@synthesize selected = selected_;
@synthesize delegate = delegate_;
@synthesize restClient = restClient_;
@synthesize thumbnailCompletion = thumbnailCompletion_;
@synthesize imageCompletion = imageCompletion_;

////////////////////////////////////////////////////////////////////////////////

- (id)init {

  self = [super init];
  if (self) {

    //
    //  No custom initialization needed yet.
    //
  }
  
  return self;
}

////////////////////////////////////////////////////////////////////////////////

- (void)dealloc {
  
  [metadata_ release], metadata_ = nil;
  [thumbnailCompletion_ release], thumbnailCompletion_ = nil;
  [imageCompletion_ release], imageCompletion_ = nil;
  [restClient_ release], restClient_ = nil;
  [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////

- (void)thumbnailAsyncWithCompletion:(void(^)(UIImage *thumbnail))completion {
  
  self.thumbnailCompletion = completion;
  NSString *localPath = [[self.metadata.path lastPathComponent] asPathInCachesFolder];
  _GTMDevLog(@"Loading thumbnail into %@", localPath);
  [self.restClient loadThumbnail:self.metadata.path ofSize:@"large" intoPath:localPath];
}

////////////////////////////////////////////////////////////////////////////////

- (void)imageAsyncWithCompletion:(void(^)(NSString *filename, NSString *uti))completion {
  
  self.imageCompletion = completion;
  NSString *localPath = [IPPhoto filenameForNewPhoto];
  _GTMDevLog(@"Loading image into %@", localPath);
  [self.restClient loadFile:self.metadata.path intoPath:localPath];
}

#pragma mark - Properties

////////////////////////////////////////////////////////////////////////////////

- (NSString *)title {
  
  return nil;
}

////////////////////////////////////////////////////////////////////////////////

- (void)setSelected:(BOOL)selected {
  
  selected_ = selected;
  if (selected_) {
    
    [self.delegate selectableAssetDidSelect:self];
    
  } else {
    
    [self.delegate selectableAssetDidUnselect:self];
  }
}

////////////////////////////////////////////////////////////////////////////////

- (DBRestClient *)restClient {
  
  if (restClient_ != nil) {
    
    return restClient_;
  }
  restClient_ = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
  restClient_.delegate = self;
  return restClient_;
}

#pragma mark - DBRestClientDelegate

////////////////////////////////////////////////////////////////////////////////

- (void)restClient:(DBRestClient *)client loadedThumbnail:(NSString *)destPath {
  
  _GTMDevLog(@"Loaded thumbnail into %@", destPath);
  UIImage *thumbnail = [UIImage imageWithContentsOfFile:destPath];
  self.thumbnailCompletion(thumbnail);
}

////////////////////////////////////////////////////////////////////////////////

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)destPath contentType:(NSString *)contentType {
  
  _GTMDevLog(@"%s -- loaded file from DropBox (%@, %@)", __PRETTY_FUNCTION__, destPath, contentType);
  self.imageCompletion(destPath, contentType);
}

////////////////////////////////////////////////////////////////////////////////

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error {
  
  _GTMDevLog(@"%s -- load file failed: %@", __PRETTY_FUNCTION__, error);
}

@end
