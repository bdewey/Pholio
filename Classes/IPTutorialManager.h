//
//  IPTutorialManager.h
//  ipad-portfolio
//
//  Controls the user walkthrough of the tutorial content.
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

#import <Foundation/Foundation.h>

//
//  Nota bene: the events & states need to match. I.e., make sure that
//  IPTutorialManagerStateDragDrop (the "we're waiting for a drag/drop") state
//  has the same numeric value as:
//  IPTutorialManagerEventDidDragDrop (a "drag drop just happened").
//

typedef enum {
  IPTutorialManagerStateWelcome,
  IPTutorialManagerStateLongPressExisting,
  IPTutorialManagerStateDragDrop,
  IPTutorialManagerStateEditTitle,
  IPTutorialManagerStateHaveFun,
  IPTutorialManagerStateNoTutorial
} IPTutorialManagerState;

#define kTutorialManagerStateLast     IPTutorialManagerStateHaveFun

typedef enum {
  IPTutorialManagerEventNext,
  IPTutorialManagerEventLongPressExisting,
  IPTutorialManagerEventDidDragDrop,
  IPTutorialManagerEventEditTitle,
  IPTutorialManagerEventHaveFun
} IPTutorialManagerEvent;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface IPTutorialManager : NSObject

@property (nonatomic, assign) IPTutorialManagerState state;
@property (weak, nonatomic, readonly) NSString *tutorialTitle;
@property (weak, nonatomic, readonly) NSString *tutorialDescription;
@property (nonatomic, readonly) BOOL isLastState;

+ (IPTutorialManager *)sharedManager;

- (BOOL)updateTutorialStateForEvent:(IPTutorialManagerEvent)event;

@end
