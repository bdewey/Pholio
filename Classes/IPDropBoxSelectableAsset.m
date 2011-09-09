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

@implementation IPDropBoxSelectableAsset

@synthesize metadata = metadata_;
@synthesize selected = selected_;

////////////////////////////////////////////////////////////////////////////////

- (id)init {

  self = [super init];
  if (self) {
    // Initialization code here.
  }
  
  return self;
}

////////////////////////////////////////////////////////////////////////////////

- (void)dealloc {
  
  [metadata_ release], metadata_ = nil;
  [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////

- (void)thumbnailAsyncWithCompletion:(void(^)(UIImage *thumbnail))completion {
  
}

////////////////////////////////////////////////////////////////////////////////

- (void)imageAsyncWithCompletion:(void(^)(NSString *filename, NSString *uti))completion {
  
}

////////////////////////////////////////////////////////////////////////////////

- (NSString *)title {
  
  return nil;
}

@end
