//
//  IPPhotoTilingManager.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 6/24/11.
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

#import "IPPhotoTilingManager.h"
#import "IPPhoto.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
//  Simple |NSOperation| to allow cancellable async saving of photo tiles.
//

@interface IPTilingOperation: NSOperation { }

@property (nonatomic, retain) IPPhoto *photo;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, copy) IPPhotoTilingCompletion completion;

@end

@implementation IPTilingOperation 

@synthesize photo = photo_;
@synthesize scale = scale_;
@synthesize completion = completion_;

- (id)initForPhoto:(IPPhoto *)photo anScale:(CGFloat)scale completion:(IPPhotoTilingCompletion)completion {
  
  self = [super init];
  if (self != nil) {
    
    self.photo = photo;
    self.scale = scale;
    self.completion = completion;
  }
  return self;
}

- (void)dealloc {
  
  [photo_ release];
  [completion_ release];
  [super dealloc];
}

- (void)main {
  
  if (![self.photo tilesExistForScale:self.scale]) {
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self.photo saveTilesForScale:self.scale];
    [pool drain];
  }
  
  if (self.completion != nil) {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void) {
      
      self.completion(self.scale);
    }];
  }
}

@end

@interface IPPhotoTilingManager ()

@property (nonatomic, retain) NSOperationQueue *tilingQueue;
@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPPhotoTilingManager

@synthesize tilingQueue = tilingQueue_;

////////////////////////////////////////////////////////////////////////////////
//
//  Initialization.
//

- (id)init {

    self = [super init];
    if (self) {
      
      tilingQueue_ = [[NSOperationQueue alloc] init];
      [self.tilingQueue setMaxConcurrentOperationCount:1];
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release retained properties.
//

- (void)dealloc {
  
  [tilingQueue_ release];
  [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Singleton object.
//

+ (IPPhotoTilingManager *)sharedManager {
  
  static IPPhotoTilingManager *sharedManager_ = nil;
  if (sharedManager_ == nil) {
    
    sharedManager_ = [[IPPhotoTilingManager alloc] init];
  }
  return sharedManager_;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Tiles a photo. Calls the completion routine each time a full scale level
//  gets tiled.
//

- (void)asyncTilePhoto:(IPPhoto *)photo withCompletion:(IPPhotoTilingCompletion)completion {
  
  size_t levelsOfDetail = [photo levelsOfDetail];
  CGFloat minScale = 1.0;
  for (int i = 1; i < levelsOfDetail; i++) {
    
    minScale /= 2;
  }
  
  if (minScale == 1.0) {
    
    //
    //  This photo does not need tiling.
    //
    
    _GTMDevLog(@"%s -- photo does not need tiling",
               __PRETTY_FUNCTION__);
    return;
  }
  
  //
  //  We've now computed the minimum scale factor we need for tiling. We will
  //  build up from that minimum scale. The first tiling operation will be 
  //  high priority; all else will be low priority.
  //
  
  NSOperationQueuePriority queuePriority = NSOperationQueuePriorityVeryHigh;
  while (minScale <= 1.0) {
    
    if ([photo tilesExistForScale:minScale]) {
      
      //
      //  The tiles exist. No need to queue an operation.
      //
      
      if (completion != nil) {
        
        completion(minScale);
      }
      
    } else {
      
      IPTilingOperation *operation = [[[IPTilingOperation alloc] initForPhoto:photo 
                                                                      anScale:minScale 
                                                                   completion:completion] autorelease];
      [operation setQueuePriority:queuePriority];
      [self.tilingQueue addOperation:operation];
    }
    
    queuePriority = NSOperationQueuePriorityNormal;
    minScale *= 2;
  }
}

@end
