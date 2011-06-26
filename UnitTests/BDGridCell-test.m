//
//  BDGridCell-test.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 4/21/11.
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
#import "BDGridCell.h"


@interface BDGridCell_test : GTMTestCase {
  
}

@end


@implementation BDGridCell_test

//
//  Simplest possible test: Make sure the class loads and everything's wired
//  as expected.
//

- (void)testBindings {

  CGRect frame = CGRectMake(20, 20, 120, 120);
  BDGridCell *cell = [[[BDGridCell alloc] initWithFrame:frame] autorelease];
  
  STAssertEquals(cell.bounds.origin.x, (CGFloat)0, nil);
  STAssertEquals(cell.bounds.size.width, (CGFloat)120, 
                 @"Expected bounds width %f, got %f", (CGFloat)120, cell.bounds.size.width);
  
  //
  //  Can set a caption and get it back. Note the copy semantics.
  //
  
  NSMutableString *caption = [NSMutableString stringWithString:@"Test"];
  cell.caption = caption;
  STAssertEqualStrings(caption, cell.caption, nil);
  [caption appendString:@" has been changed"];
  STAssertNotEqualStrings(caption, cell.caption, nil);
}

@end
