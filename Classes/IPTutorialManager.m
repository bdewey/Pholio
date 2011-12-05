//
//  IPTutorialManager.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 11/26/11.
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

#import "IPTutorialManager.h"

@interface IPTutorialManager()

@property (nonatomic, retain) NSArray *tutorialTitles;
@property (nonatomic, retain) NSArray *tutorialDescriptions;

- (void)advanceState;
@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPTutorialManager

@synthesize state                = state_;
@synthesize tutorialTitles       = tutorialTitles_;
@synthesize tutorialDescriptions = tutorialDescriptions_;

@dynamic tutorialTitle;
@dynamic tutorialDescription;

////////////////////////////////////////////////////////////////////////////////

- (id)init {
  
  self = [super init];
  if (self) {
    
    tutorialTitles_ = [[NSArray alloc] initWithObjects:
                       @"Welcome to Pholio!",
                       @"Drag and Drop",
                       @"No tutorial",
                       nil];
    tutorialDescriptions_ = [[NSArray alloc] initWithObjects:
                             @"Pholio helps you build, organize, and display beautiful portfolios of your images.",
                             @"(Add some text about how you can drag and drop here...)",
                             @"No tutorial",
                             nil];
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////

- (void)dealloc {
  
  [tutorialTitles_ release];
  [tutorialDescriptions_ release];
  
  [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////

+ (IPTutorialManager *)sharedManager {
  
  static IPTutorialManager *sharedManager_ = nil;
  if (sharedManager_ == nil) {
    
    sharedManager_ = [[IPTutorialManager alloc] init];
  }
  return sharedManager_;
}

////////////////////////////////////////////////////////////////////////////////
//
//  This algorithm is a simple linear state machine. All you can do is move 
//  from one state to the next on either a "next" event, or with an event that
//  exactly matches the current state.
//
//  This depends on the event & state enumerations matching.
//

- (BOOL)updateTutorialStateForEvent:(IPTutorialManagerEvent)event {

  if (event == IPTutorialManagerEventNext) {
    
    [self advanceState];
    return YES;
  }
  
  //
  //  Look for state matches.
  //
  
  if (event == self.state) {
    
    [self advanceState];
    return YES;
  }
  
  return NO;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Move the state machine one state forward.
//

- (void)advanceState {
  
  if (self.state == kTutorialManagerStateLast) {
    
    self.state = IPTutorialManagerStateNoTutorial;
    
  } else {
    
    self.state++;
  }
}

#pragma mark - Properties

////////////////////////////////////////////////////////////////////////////////

- (NSString *)tutorialTitle {
  
  return [self.tutorialTitles objectAtIndex:self.state];
}

////////////////////////////////////////////////////////////////////////////////

- (NSString *)tutorialDescription {
  
  return [self.tutorialDescriptions objectAtIndex:self.state];
}

@end
