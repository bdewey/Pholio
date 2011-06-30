//
//  IPPhotoTilingManager-test.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 6/24/11.
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

#import "GTMSenTestCase.h"
#import <UIKit/UIKit.h>
#import "IPPhotoOptimizationManager.h"
#import "IPPhoto.h"
#import "IPPage.h"
#import "NSString+TestHelper.h"

#define kTestMediumImage    @"AlexGrass_20110604.jpg"


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface IPPhotoOptimizationManager_test : GTMTestCase { }

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPPhotoOptimizationManager_test

////////////////////////////////////////////////////////////////////////////////
//
//  Test singleton. It should really be a singleton.
//

- (void)testSingleton {
  
  IPPhotoOptimizationManager *m1 = [IPPhotoOptimizationManager sharedManager];
  IPPhotoOptimizationManager *m2 = [IPPhotoOptimizationManager sharedManager];
  
  STAssertEquals(m1, m2, @"Singleton should return the same object");
  STAssertNotNil(m1, nil);
}

////////////////////////////////////////////////////////////////////////////////
//
//  Test simple photo and page optimization.
//

- (void)testOptimization {
  
  IPPhoto *photo = [[[IPPhoto alloc] init] autorelease];
  photo.image = [UIImage imageNamed:kTestMediumImage];
  
  STAssertFalse([photo isOptimized], nil);
  [photo image];
  __block CGFloat longEdge = MAX(photo.imageSize.width, photo.imageSize.height);
  STAssertGreaterThan(longEdge, (CGFloat)1500, nil);
  
  [[IPPhotoOptimizationManager sharedManager] setWorkSynchronouslyForDebugging:NO];
  [[IPPhotoOptimizationManager sharedManager] asyncOptimizePhoto:photo withCompletion:^(void) {
    
    STAssertTrue([photo isOptimized], nil);
    longEdge = MAX(photo.imageSize.width, photo.imageSize.height);
    STAssertLessThanOrEqual(longEdge, (CGFloat)1500, nil);
  }];
   
  //
  //  The above call is async. We should not be optimized yet.
  //
  
  STAssertFalse([photo isOptimized], nil);
}

@end
