//
//  IPFlickrAuthorizationManager-test.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 5/18/11.
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
#import "IPFlickrAuthorizationManager.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface IPFlickrAuthorizationManager_test : GTMTestCase { }

@end


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPFlickrAuthorizationManager_test

////////////////////////////////////////////////////////////////////////////////
//
//  Ensure we can get a shared manager, a context, and set & read an auth
//  token.
//

- (void)testBasic {
  
  IPFlickrAuthorizationManager *manager = [IPFlickrAuthorizationManager sharedManager];
  STAssertNotNil(manager, nil);
  STAssertNotNil(manager.context, nil);
  STAssertNil(manager.authToken, nil);
  manager.authToken = @"token";
  STAssertEqualStrings(@"token", manager.authToken, nil);
  STAssertEqualStrings(@"token", manager.context.authToken, nil);
}

////////////////////////////////////////////////////////////////////////////////
//
//  Test login.
//

- (void)testLogin {
  
  id mockApplication = [OCMockObject mockForClass:[UIApplication class]];
  
  //
  //  Note I'm not using the shared manager here, b/c I don't want other
  //  tests to get my mockApplication.
  //
  
  IPFlickrAuthorizationManager *manager = [[[IPFlickrAuthorizationManager alloc] init] autorelease];
  manager.sharedApplication = mockApplication;
  
  NSString *expectedUrl = @"http://flickr.com/services/auth/?api_key=cc0e65877814a82cccb5b634632de2da&auth_token=token&perms=read&api_sig=f4a6e230885c3b1a3e1ae5deadaaaaf8";
  [[mockApplication expect] openURL:[NSURL URLWithString:expectedUrl]];
  
  STAssertNoThrow([manager login], nil);
  STAssertNoThrow([mockApplication verify], nil);
}
@end
