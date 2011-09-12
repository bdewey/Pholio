//
//  IPDropBoxSelectableAsset-test.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 9/12/11.
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
#import <OCMock/OCMock.h>
#import <UIKit/UIKit.h>
#import "IPDropBoxSelectableAsset.h"

@interface IPDropBoxSelectableAsset_test : GTMTestCase

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPDropBoxSelectableAsset_test

////////////////////////////////////////////////////////////////////////////////

- (void)testBasicRestClient {
  
  IPDropBoxSelectableAsset *asset = [[[IPDropBoxSelectableAsset alloc] init] autorelease];
  STAssertNotNil(asset.restClient, nil);
}

////////////////////////////////////////////////////////////////////////////////

- (void)testThumbnail {
  
  NSString *path = @"thumbnail-path";
  IPDropBoxSelectableAsset *asset = [[[IPDropBoxSelectableAsset alloc] init] autorelease];
  id mockClient = [OCMockObject mockForClass:[DBRestClient class]];
  asset.restClient = mockClient;
  DBMetadata *metadata = [[[DBMetadata alloc] initWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:path, @"path", nil]] autorelease];
  asset.metadata = metadata;
  [[mockClient expect] loadThumbnail:path ofSize:@"large" intoPath:OCMOCK_ANY];
  [asset thumbnailAsyncWithCompletion:^(UIImage *thumbnail) {
    STFail(@"Completion should not get called");
  }];
  STAssertNoThrow([mockClient verify], nil);
}

////////////////////////////////////////////////////////////////////////////////

- (void)testImage {
  
  NSString *path = @"image-path";
  IPDropBoxSelectableAsset *asset = [[[IPDropBoxSelectableAsset alloc] init] autorelease];
  id mockClient = [OCMockObject mockForClass:[DBRestClient class]];
  asset.restClient = mockClient;
  DBMetadata *metadata = [[[DBMetadata alloc] initWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:path, @"path", nil]] autorelease];
  asset.metadata = metadata;
  [[mockClient expect] loadFile:path intoPath:OCMOCK_ANY];
  [asset imageAsyncWithCompletion:^(NSString *filename, NSString *uti) {
    
    STFail(@"Completion routine should not get called");
  }];
  STAssertNoThrow([mockClient verify], nil);
}
@end
