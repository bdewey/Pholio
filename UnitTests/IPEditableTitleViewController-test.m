//
//  IPEditableTitleViewController-test.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 5/25/11.
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
#import "IPEditableTitleViewController.h"
#import <OCMock/OCMock.h>
#import "IPUserDefaults.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface IPEditableTitleViewController_test : GTMTestCase { }

@property (nonatomic, retain) IPEditableTitleViewController *controller;

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


@implementation IPEditableTitleViewController_test

@synthesize controller = controller_;

////////////////////////////////////////////////////////////////////////////////
//
//  Create a controller for testing.
//

- (void)setUp {
  
  self.controller = [[[IPEditableTitleViewController alloc] init] autorelease];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release the controller and do any final validation.
//

- (void)tearDown {
  
  self.controller = nil;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Simple view load.
//

- (void)testDidLoad {
  
  [self.controller view];
  STAssertNotNil(self.controller.view, nil);
}

////////////////////////////////////////////////////////////////////////////////
//
//  Test whether the controller properly passes back the editable state.
//

- (void)testShouldEdit {
  
  BOOL shouldEditYes = YES, shouldEditNo = NO;
  
  //
  //  Create two mock objects for the user defaults class; one that says
  //  we should allow editing, one that doesn't.
  //
  
  id mockShouldEditYes = [OCMockObject mockForClass:[IPUserDefaults class]];
  [[[mockShouldEditYes stub] andReturnValue:OCMOCK_VALUE(shouldEditYes)] editingEnabled];
  id mockShouldEditNo  = [OCMockObject mockForClass:[IPUserDefaults class]];
  [[[mockShouldEditNo stub] andReturnValue:OCMOCK_VALUE(shouldEditNo)] editingEnabled];
  
  //
  //  And check what the controller says for each state.
  //
  
  self.controller.userDefaults = mockShouldEditNo;
  STAssertFalse([self.controller gridViewShouldEdit:nil], nil);
  
  self.controller.userDefaults = mockShouldEditYes;
  STAssertTrue([self.controller gridViewShouldEdit:nil], nil);
}

////////////////////////////////////////////////////////////////////////////////
//
//  Test behavior in editable vs. non-editable state.
//

- (void)testEditNavigationBarTitle {
  
  BOOL shouldEditYes = YES, shouldEditNo = NO;
  
  //
  //  Create two mock objects for the user defaults class; one that says
  //  we should allow editing, one that doesn't.
  //
  
  id mockShouldEditYes = [OCMockObject mockForClass:[IPUserDefaults class]];
  [[[mockShouldEditYes stub] andReturnValue:OCMOCK_VALUE(shouldEditYes)] editingEnabled];
  id mockShouldEditNo  = [OCMockObject mockForClass:[IPUserDefaults class]];
  [[[mockShouldEditNo stub] andReturnValue:OCMOCK_VALUE(shouldEditNo)] editingEnabled];

  STAssertNoThrow([self.controller view], nil);
  self.controller.userDefaults = mockShouldEditNo;
  STAssertFalse([self.controller textFieldShouldBeginEditing:nil], nil);
  
  //
  //  Upon viewWillAppear, the controller should look at whether editing is allowed.
  //  The right bar button item appears only if editing is allowed.
  //
  
  [self.controller viewWillAppear:YES];
  STAssertNil(self.controller.navigationItem.rightBarButtonItem, nil);
  
  self.controller.userDefaults = mockShouldEditYes;
  STAssertTrue([self.controller textFieldShouldBeginEditing:nil], nil);
  [self.controller viewWillAppear:YES];
  STAssertNotNil(self.controller.navigationItem.rightBarButtonItem, nil);
  STAssertEquals(self.controller.navigationItem.rightBarButtonItem.target,
                 self.controller, nil);
  STAssertEquals(self.controller.navigationItem.rightBarButtonItem.action,
                 @selector(showSettings), nil);
}

@end
