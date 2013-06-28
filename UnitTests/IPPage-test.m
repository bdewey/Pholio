//
//  IPPage-test.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 4/5/11.
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

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>
#import "IPPage.h"
#import "IPPhoto+TestHelpers.h"
#import "IPPage+TestHelpers.h"
#import "NSString+TestHelper.h"

@interface IPPage_test : SenTestCase {
  
}

@end


@implementation IPPage_test

//
//  Validates that I can load and save a page.
//

- (void)testRoundTrip {
  NSString *testFile = [@"IPPage-testRoundTrip.dat" asPathInDocumentsFolder];
  NSFileManager *defaultManager = [NSFileManager defaultManager];
  [defaultManager removeItemAtPath:testFile error:NULL];
  STAssertFalse([defaultManager fileExistsAtPath:testFile], 
                @"File should not exist");
  
  //
  //  Create a page. Put some photos in it. Save it.
  //
  
  IPPage *page = [[IPPage alloc] init];
  [page insertObject:[IPPhoto photoWithCaption:@"Photo zero"] inPhotosAtIndex:0];
  [page insertObject:[IPPhoto photoWithCaption:@"Photo one"] inPhotosAtIndex:1];
  STAssertEquals((NSUInteger)2, [page countOfPhotos], @"Should have 2 photos");
  
  BOOL success = [NSKeyedArchiver archiveRootObject:page toFile:testFile];
  STAssertTrue(success, @"Archiving should succeed");
  STAssertTrue([defaultManager fileExistsAtPath:testFile], 
               @"File should now exist");
  
  IPPage *newPage = (IPPage *)[NSKeyedUnarchiver unarchiveObjectWithFile:testFile];
  STAssertEquals((NSUInteger)2, [newPage countOfPhotos], @"Should get all photos");
  STAssertTrue([[newPage valueForKeyPath:@"caption" forPhoto:1] isEqualToString:@"Photo one"], nil);
}

//
//  Tests copying one page to another.
//

- (void)testCopy {
  
  IPPage *page = [[IPPage alloc] init];
  [page insertObject:[IPPhoto photoWithCaption:@"testCopy"] inPhotosAtIndex:0];
  IPPage *page2 = [page copy];
  STAssertNotNil(page2, @"Should have *something* after copy");
  STAssertEquals((NSUInteger)1, [page2 countOfPhotos], 
                 @"Should have the right number of photos");
  STAssertTrue([[page2 valueForKeyPath:@"caption" forPhoto:0] isEqualToString:@"testCopy"], nil);
  [page insertObject:[IPPhoto photoWithCaption:@"testCopy2"] inPhotosAtIndex:1];
  STAssertEquals((NSUInteger)2, [page countOfPhotos], nil);
  STAssertEquals((NSUInteger)1,
                 [page2 countOfPhotos],
                 @"Pages should have independent photo arrays");
  [page setValue:@"modified" forKeyPath:@"caption" forPhoto:0];
  STAssertTrue([[page valueForKeyPath:@"caption" forPhoto:0] isEqualToString:@"modified"], nil);
  STAssertTrue([[page2 valueForKeyPath:@"caption" forPhoto:0] isEqualToString:@"testCopy"], nil);
}

//
//  Test hierarchy properties (parent pointers, retain cycle detection).
//

- (void)testHierarchy {
  
  IPPage *page = [[IPPage alloc] init];
  NSUInteger desiredPhotos = 8;
  @autoreleasepool {
    for (int i = 0; i < desiredPhotos; i++) {
      [page insertObject:[IPPhoto photoWithCaption:@"testHierarchy"] inPhotosAtIndex:i];
    }
  }
  
  IPPhoto *firstPhoto = [page objectInPhotosAtIndex:0];
  STAssertEquals(page, firstPhoto.parent, @"Parent pointer should be set");
  [page removeObjectFromPhotosAtIndex:0];
  STAssertNil(firstPhoto.parent, @"Parent pointer should get cleared on removal");
}

@end
