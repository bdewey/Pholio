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
    
    tutorialTitles_ = [[NSArray alloc] initWithObjects:@"No Tutorial",
                       @"Welcome",
                       @"Drag and Drop",
                       nil];
    tutorialDescriptions_ = [[NSArray alloc] initWithObjects:@"No Tutorial",
                             @"Welcome to Pholio!",
                             @"(Add some text about how you can drag and drop here...)",
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

- (BOOL)updateTutorialStateForEvent:(IPTutorialManagerEvent)event {
  
  if (event == IPTutorialManagerEventDidSelectLearnMore) {
    
    //
    //  The resulting state is always IPTutorialManagerStateDragDrop.
    //
    
    if (self.state == IPTutorialManagerStateDragDrop) {
      
      //
      //  Already there.
      //
      
      return NO;
      
    } else {
      
      self.state = IPTutorialManagerStateDragDrop;
      return YES;
    }
  }
  
  switch (self.state) {
      
    case IPTutorialManagerStateNoTutorial:
      
      break;
      
    case IPTutorialManagerStateWelcome:
      break;
      
    case IPTutorialManagerStateDragDrop:
      if (event == IPTutorialManagerEventDidDragDrop) {
        
        self.state = IPTutorialManagerStateNoTutorial;
        return YES;
      }
      return NO;
      
    default:
      break;
  }
  
  return NO;
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
