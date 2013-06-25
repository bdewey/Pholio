//
//  IPPhotoTilingManager.h
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

#import <Foundation/Foundation.h>

//
//  This is a callback that gets called each time a scale level is tiled
//  for a photo.
//

typedef void (^IPPhotoOptimizationCompletion)(void);

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@class IPPhoto;
@class IPPage;
@class IPSet;
@protocol IPPhotoOptimizationManagerDelegate;

@interface IPPhotoOptimizationManager : NSObject

//
//  The shared manager.
//

+ (IPPhotoOptimizationManager *)sharedManager;

//
//  Asynchronously optimizes the photo. Calls the completion routine on the main
//  thread when optimization is complete.
//

- (void)asyncOptimizePhoto:(IPPhoto *)photo withCompletion:(IPPhotoOptimizationCompletion)completion;

//
//  Optimize a set of photos, then call the completion when all are done.
//

- (void)asyncOptimizePhotos:(NSArray *)photos withCompletion:(IPPhotoOptimizationCompletion)completion;


//
//  Asynchronously optimize a page.
//

- (void)asyncOptimizePage:(IPPage *)page withCompletion:(IPPhotoOptimizationCompletion)completion;

//
//  Delegate, gets to show UI.
//

@property (nonatomic, weak) id<IPPhotoOptimizationManagerDelegate> delegate;

//
//  The queue on which we work. This is a good place to put all resource-intensive
//  background tasks.
//

@property (nonatomic, strong) NSOperationQueue *optimizationQueue;

//
//  Flag for debugging. 
//

@property (nonatomic, assign) BOOL workSynchronouslyForDebugging;

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
//  The optimization manager delegate gets to display UI when optimization
//  happens.
//

@protocol IPPhotoOptimizationManagerDelegate <NSObject>

- (void)optimizationManager:(IPPhotoOptimizationManager *)optimizationManager 
   didHaveOptimizationCount:(NSUInteger)optimizationCount;

@end
