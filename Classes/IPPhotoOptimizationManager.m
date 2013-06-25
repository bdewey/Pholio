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

#import "IPPhoto.h"
#import "IPPage.h"
#import "IPSet.h"
#import "IPPhotoOptimizationManager.h"

@interface IPPhotoOptimizationManager ()

@property (nonatomic, assign) NSUInteger activeOptimizations;
@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPPhotoOptimizationManager

////////////////////////////////////////////////////////////////////////////////
//
//  Initialization.
//

- (id)init {

    self = [super init];
    if (self) {
      
      _optimizationQueue = [[NSOperationQueue alloc] init];
      [_optimizationQueue setMaxConcurrentOperationCount:1];
      _workSynchronouslyForDebugging = NO;
      _activeOptimizations = 0;
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Singleton object.
//

+ (IPPhotoOptimizationManager *)sharedManager {
  
  static IPPhotoOptimizationManager *sharedManager = nil;
  if (sharedManager == nil) {
    
    sharedManager = [[IPPhotoOptimizationManager alloc] init];
  }
  return sharedManager;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Do the optimization.
//

- (void)asyncOptimizePhoto:(IPPhoto *)photo withCompletion:(IPPhotoOptimizationCompletion)completion {

  self.activeOptimizations++;
  [self.delegate optimizationManager:self 
            didHaveOptimizationCount:self.activeOptimizations];
  NSBlockOperation *optimizationOperation = [NSBlockOperation blockOperationWithBlock:^(void) {
    
    [photo optimize];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void) {

      if (completion != nil) {
        
        completion();
      }
      self.activeOptimizations--;
      [self.delegate optimizationManager:self 
                didHaveOptimizationCount:self.activeOptimizations];
    }];
  }];
  
  [self.optimizationQueue addOperation:optimizationOperation];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Optimize an array of photos and call the completion routine when all are done.
//

- (void)asyncOptimizePhotos:(NSArray *)photos withCompletion:(IPPhotoOptimizationCompletion)completion {
  
  self.activeOptimizations += [photos count];
  [self.delegate optimizationManager:self 
            didHaveOptimizationCount:self.activeOptimizations];
  NSBlockOperation *optimizationOperation = [NSBlockOperation blockOperationWithBlock:^(void) {
    
    for (IPPhoto *photo in photos) {
      [photo optimize];
    }
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void) {
      
      if (completion != nil) {
        
        completion();
      }
      self.activeOptimizations -= [photos count];
      [self.delegate optimizationManager:self 
                didHaveOptimizationCount:self.activeOptimizations];
    }];
  }];
  
  [self.optimizationQueue addOperation:optimizationOperation];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Optimize a page.
//

- (void)asyncOptimizePage:(IPPage *)page withCompletion:(IPPhotoOptimizationCompletion)completion {
  
  if (self.workSynchronouslyForDebugging) {
    
    for (IPPhoto *photo in page.photos) {
      
      [photo optimize];
    }
    if (completion != nil) {
      
      completion();
    }
    return;
  }
  
  self.activeOptimizations++;
  [self.delegate optimizationManager:self 
            didHaveOptimizationCount:self.activeOptimizations];
  [self.optimizationQueue addOperationWithBlock:^(void) {
    
    for (IPPhoto *photo in page.photos) {
      
      [photo optimize];
    }
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void) {
      
      if (completion != nil) {
        
        completion();
      }
      self.activeOptimizations--;
      [self.delegate optimizationManager:self 
                didHaveOptimizationCount:self.activeOptimizations];
    }];
  }];
}

@end
