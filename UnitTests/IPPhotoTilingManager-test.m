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
#import "IPPhotoTilingManager.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface IPPhotoTilingManager_test : GTMTestCase { }

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPPhotoTilingManager_test

////////////////////////////////////////////////////////////////////////////////
//
//  Test singleton. It should really be a singleton.
//

- (void)testSingleton {
  
  IPPhotoTilingManager *m1 = [IPPhotoTilingManager sharedManager];
  IPPhotoTilingManager *m2 = [IPPhotoTilingManager sharedManager];
  
  STAssertEquals(m1, m2, @"Singleton should return the same object");
  STAssertNotNil(m1, nil);
}

@end
