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

#define kIPTutorialManagerStateKey            @"kIPTutorialManagerStateKey"

@interface IPTutorialManager()

@property (nonatomic, strong) NSArray *tutorialTitles;
@property (nonatomic, strong) NSArray *tutorialDescriptions;

- (void)advanceState;
@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPTutorialManager

////////////////////////////////////////////////////////////////////////////////

- (id)init {
  
  self = [super init];
  if (self) {
    
    _tutorialTitles = @[@"Welcome to Pholio!",
                       @"The Long Press",
                       @"Drag and Drop",
                       @"Editing titles",
                       @"Have fun!",
                       @"No tutorial"];
    _tutorialDescriptions = @[@"Pholio helps you build, organize, and display beautiful portfolios of your images.",
                             @"The key gesture for using Pholio is the long press. Doing a long press on the screen brings up a menu of actions. Not only can you do a long press on existing galleries or photos, you can do a long press on empty space to create new photos or galleries. Try a long press now.",
                             @"It's easy to rearrange anything: Just drag and drop. Try it now!",
                             @"You can also edit the title of anything. Just tap the title bar and you can start editing. You can even put your name or your photo business name as the title of the main screen. Try it now.",
                             @"That's it! I hope you find Pholio easy to use, and I hope you enjoy using it to show off your work to friends, family, and clients.",
                             @"No tutorial"];
    _state = [[NSUserDefaults standardUserDefaults] integerForKey:kIPTutorialManagerStateKey];
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////


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
    
    return;
    
  } else {
    
    self.state++;
  }
}

#pragma mark - Properties

////////////////////////////////////////////////////////////////////////////////

- (NSString *)tutorialTitle {
  
  return (self.tutorialTitles)[self.state];
}

////////////////////////////////////////////////////////////////////////////////

- (NSString *)tutorialDescription {
  
  return (self.tutorialDescriptions)[self.state];
}

////////////////////////////////////////////////////////////////////////////////

- (BOOL)isLastState {
  
  return (self.state == kTutorialManagerStateLast);
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setState:(IPTutorialManagerState)state {
  
  _state = state;
  [[NSUserDefaults standardUserDefaults] setInteger:_state forKey:kIPTutorialManagerStateKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
