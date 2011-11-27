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

typedef enum {
  IPTutorialManagerStateNoTutorial,
  IPTutorialManagerStateWelcome,
  IPTutorialManagerStateDragDrop
} IPTutorialManagerState;

typedef enum {
  IPTutorialManagerEventDidSelectLearnMore,
  IPTutorialManagerEventDidDragDrop
} IPTutorialManagerEvent;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface IPTutorialManager : NSObject

@property (nonatomic, assign) IPTutorialManagerState state;
@property (nonatomic, readonly) NSString *tutorialTitle;
@property (nonatomic, readonly) NSString *tutorialDescription;

+ (IPTutorialManager *)sharedManager;

- (BOOL)updateTutorialStateForEvent:(IPTutorialManagerEvent)event;

@end
