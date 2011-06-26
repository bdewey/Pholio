//
//  BDColorPicker-test.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 5/24/11.
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
#import "BDColorPicker.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface BDColorPicker_test : GTMTestCase { }

@property (nonatomic, retain) BDColorPicker *colorPicker;

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation BDColorPicker_test

@synthesize colorPicker = colorPicker_;

////////////////////////////////////////////////////////////////////////////////
//
//  Create a controller for testing.
//

- (void)setUp {

  self.colorPicker = [[[BDColorPicker alloc] init] autorelease];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Do any final validation on the controller and release it.
//

- (void)tearDown {
  
  self.colorPicker = nil;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Verify that all the interface builder outlets are wired.
//

- (void)testBindings {
  
  //
  //  Make sure the view has been loaded.
  //
  
  STAssertNoThrow([self.colorPicker view], nil);
  STAssertNotNil(self.colorPicker.view, nil);
  STAssertNotNil(self.colorPicker.hexCode, nil);
  STAssertNotNil(self.colorPicker.redSlider, nil);
  STAssertNotNil(self.colorPicker.greenSlider, nil);
  STAssertNotNil(self.colorPicker.blueSlider, nil);
  STAssertNotNil(self.colorPicker.redValue, nil);
  STAssertNotNil(self.colorPicker.greenValue, nil);
  STAssertNotNil(self.colorPicker.blueValue, nil);
  STAssertNotNil(self.colorPicker.colorSwatch, nil);
}

@end
