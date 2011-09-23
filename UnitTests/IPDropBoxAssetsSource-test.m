//
//  IPDropBoxAssetsSource-test.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 9/23/11.
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
#import <OCMock/OCMock.h>
#import "BDSelectableAsset.h"
#import "IPDropBoxAssetsSource.h"
#import "IPDropBoxSelectableAsset.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface IPDropBoxAssetsSource_test : GTMTestCase<BDSelectableAssetDelegate>

- (NSDictionary *)propertiesForImageNamed:(NSString *)name;
- (NSDictionary *)propertiesForFolderNamed:(NSString *)folder withContents:(NSArray *)contents;
- (DBMetadata *)metadataForImageNamed:(NSString *)name;
- (DBMetadata *)metadataForFolderNamed:(NSString *)folder withContents:(NSArray *)contents;

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPDropBoxAssetsSource_test

////////////////////////////////////////////////////////////////////////////////

- (void)testFillArray {

  IPDropBoxAssetsSource *source = [[[IPDropBoxAssetsSource alloc] init] autorelease];
  id mockRestClient = [OCMockObject mockForClass:[DBRestClient class]];
  source.restClient = mockRestClient;
  source.path = @"/";
  NSMutableArray *children = [NSMutableArray arrayWithCapacity:1];
  NSMutableArray *assets = [NSMutableArray arrayWithCapacity:1];
  
  //
  //  When we ask for assets, the source should turn around and try to get 
  //  metadata from DropBox.
  //
  
  [[mockRestClient expect] loadMetadata:source.path];
  [source asyncFillArrayWithChildren:children 
                           andAssets:assets 
         withSelectableAssetDelegate:self 
                          completion:^(void) {
    
    STFail(@"Completion routine should not be called", nil);
  }];
  STAssertNoThrow([mockRestClient verify], nil);
}

////////////////////////////////////////////////////////////////////////////////
//
//  This tests different permutations of DropBox metadata getting returned to
//  the assets source.
//

- (void)testDidLoadMetadata {

  IPDropBoxAssetsSource *source = [[[IPDropBoxAssetsSource alloc] init] autorelease];
  source.path = @"/";
  id mockRestClient = [OCMockObject mockForClass:[DBRestClient class]];
  source.restClient = mockRestClient;
  NSMutableArray *assets = [NSMutableArray arrayWithCapacity:1];
  NSMutableArray *children = [NSMutableArray arrayWithCapacity:1];
  NSArray *expectedAssetNames = [NSArray arrayWithObjects:@"foo.jpg", @"bar.png", nil];
  NSArray *expectedChildNames = [NSArray arrayWithObjects:@"A", @"B", @"C", nil];
  NSMutableArray *contents = [NSMutableArray arrayWithCapacity:5];
  for (NSString *name in expectedAssetNames) {
    
    [contents addObject:[self propertiesForImageNamed:name]];
  }
  for (NSString *name in expectedChildNames) {
    
    [contents addObject:[self propertiesForFolderNamed:name withContents:nil]];
  }
  DBMetadata *metadata = [self metadataForFolderNamed:source.path withContents:contents];
  __block BOOL completionCalled = NO;
  
  [[mockRestClient expect] loadMetadata:source.path];
  [source asyncFillArrayWithChildren:children 
                           andAssets:assets 
         withSelectableAssetDelegate:self 
                          completion:
   ^(void) {
     completionCalled = YES;
     
     //
     //  Validate that we found the right assets and children.
     //
     
     STAssertEquals([expectedChildNames count], [children count], nil);
     STAssertEquals([expectedAssetNames count], [assets count], nil);
     
     for (IPDropBoxSelectableAsset *asset in assets) {
       
       STAssertTrue([expectedAssetNames containsObject:asset.metadata.path], 
                    @"Unexpected asset path %@",
                    asset.metadata.path);
       STAssertEquals(asset.delegate, self, nil);
     }
     for (IPDropBoxAssetsSource *child in children) {
       
       STAssertTrue([expectedChildNames containsObject:child.path],
                    @"Unexpected child path: %@",
                    child.path);
     }
   }];
  STAssertNoThrow([mockRestClient verify], nil);
  
  //
  //  At this point, the completion routine should not be called and we should
  //  have found neither assets nor children.
  //
  
  STAssertFalse(completionCalled, nil);
  STAssertEquals((NSUInteger)0, [children count], @"Should have 0 children but found %d", [children count]);
  STAssertEquals((NSUInteger)0, [assets count], @"Should have 0 assets but found %d", [assets count]);
  
  //
  //  Now, tell the source that we loaded the metadata. This should call the
  //  completion routine and fill in the assets/children arrays.
  //
  
  [source restClient:mockRestClient loadedMetadata:metadata];
  STAssertTrue(completionCalled, nil);
}

#pragma mark - Test helpers

////////////////////////////////////////////////////////////////////////////////

- (NSDictionary *)propertiesForImageNamed:(NSString *)name {
  
  NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:name, @"path", 
                              [NSNumber numberWithBool:YES], @"thumb_exists",
                              nil];
  return properties;
}

////////////////////////////////////////////////////////////////////////////////

- (NSDictionary *)propertiesForFolderNamed:(NSString *)folder withContents:(NSArray *)contents {
  
  NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:folder, @"path", 
                              [NSNumber numberWithBool:YES], @"is_dir",
                              contents, @"contents",
                              nil];
  return properties;
}

////////////////////////////////////////////////////////////////////////////////

- (DBMetadata *)metadataForImageNamed:(NSString *)name {
  
  NSDictionary *properties = [self propertiesForImageNamed:name];
  return [[[DBMetadata alloc] initWithDictionary:properties] autorelease];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Creates a |DBMetadata| object for a folder. |contents| must be an NSArray
//  of property |NSDictionary| objects for the children of the folder.
//  |contents| may be nil if you want to create metadata for an empty folder.
//

- (DBMetadata *)metadataForFolderNamed:(NSString *)folder withContents:(NSArray *)contents {
  
  NSDictionary *properties = [self propertiesForFolderNamed:folder withContents:contents];
  DBMetadata *metadata = [[[DBMetadata alloc] initWithDictionary:properties] autorelease];
  return metadata;
}

#pragma mark - BDSelectableAssetDelegate

////////////////////////////////////////////////////////////////////////////////

- (void)selectableAssetDidSelect:(id<BDSelectableAsset>)selectableAsset {

  //
  //  NOTHING
  //
}

////////////////////////////////////////////////////////////////////////////////

- (void)selectableAssetDidUnselect:(id<BDSelectableAsset>)selectableAsset {

  //
  //  NOTHING
  //
}

@end
