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

@synthesize delegate = delegate_;
@synthesize workSynchronouslyForDebugging = workSynchronouslyForDebugging_;
@synthesize optimizationQueue = optimizationQueue_;
@synthesize activeOptimizations = activeOptimizations_;

////////////////////////////////////////////////////////////////////////////////
//
//  Initialization.
//

- (id)init {

    self = [super init];
    if (self) {
      
      optimizationQueue_ = [[NSOperationQueue alloc] init];
      [self.optimizationQueue setMaxConcurrentOperationCount:1];
      self.workSynchronouslyForDebugging = NO;
      self.activeOptimizations = 0;
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release retained properties.
//

- (void)dealloc {
  
  [optimizationQueue_ release];
  [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Singleton object.
//

+ (IPPhotoOptimizationManager *)sharedManager {
  
  static IPPhotoOptimizationManager *sharedManager_ = nil;
  if (sharedManager_ == nil) {
    
    sharedManager_ = [[IPPhotoOptimizationManager alloc] init];
  }
  return sharedManager_;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Do the optimization.
//

- (void)asyncOptimizePhoto:(IPPhoto *)photo withCompletion:(IPPhotoOptimizationCompletion)completion {

  completion = [completion copy];
  self.activeOptimizations++;
  [self.delegate optimizationManager:self 
            didHaveOptimizationCount:self.activeOptimizations];
  NSBlockOperation *optimizationOperation = [NSBlockOperation blockOperationWithBlock:^(void) {
    
    [photo optimize];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void) {

      if (completion != nil) {
        
        completion();
        [completion release];
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
  
  completion = [completion copy];
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
        [completion release];
      }
      self.activeOptimizations--;
      [self.delegate optimizationManager:self 
                didHaveOptimizationCount:self.activeOptimizations];
    }];
  }];
}

@end
