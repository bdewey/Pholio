//
//  IPHelp-test.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 6/18/11.
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
#import "NSString+TestHelper.h"
#import "IPHelpController.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface IPHelp_test : GTMTestCase { }

@property (nonatomic, retain) IPHelpController *controller;
@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPHelp_test

@synthesize controller = controller_;

////////////////////////////////////////////////////////////////////////////////
//
//  Create a controller to test.
//

- (void)setUp {
  
  controller_ = [[IPHelpController alloc] initWithNibName:nil bundle:nil];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release our test controller.
//

- (void)tearDown {
  
  self.controller = nil;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Make sure that the expected files are in the bundle.
//

- (void)testManifest {

  NSArray *helpFiles = [NSArray arrayWithObjects:@"index.html", 
                        @"import.html",
                        @"site.css",
                        @"getting-started.html",
                        @"context-menu.png",
                        @"rename.png",
                        nil];
  
  for (NSString *filename in helpFiles) {
    
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[filename asPathInBundlePath]];
    STAssertTrue(exists, @"%@ should exist in the bundle", filename);
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  Make sure IBOutlet bindings work.
//

- (void)testBindings {

  //
  //  Force the view to load.
  //
  
  [self.controller view];
  
  //
  //  Check outlets.
  //
  
  STAssertNotNil(self.controller.webView, nil);
}

@end
