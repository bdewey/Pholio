//
//  BDContrainPanGestureRecognizer.h
//
//  Implements a "constrained pan." This is a continuous pan gesture that only
//  starts after the user has moved at least |dx| pixels along the X axis and
//  has NOT moved more than |dy| pixels along the Y axis. Basically, you have
//  to start the gesture with a horizontal line of a certain amount. Once you've
//  met the constraint, it's just a regular pan.
//
//  The intent is to get used inside a |BDGridView|, which implements vertical
//  scrolling. The constraint means that this pan can be distinguished from
//  a gesture that would scroll the scroll view, as you need no horizontal
//  movement for vertical scrolling. Using this gesture, you can "grab" a cell
//  from the view with a horizontal movement, and then pan it to a new location.
//
//  Created by Brian Dewey on 4/26/11.
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
#import <UIKit/UIGestureRecognizerSubclass.h>

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface BDContrainPanGestureRecognizer : UIGestureRecognizer {
    
}

//
//  Defaults to YES. If set to NO, then there is no movement constraint for
//  recognizing the start of the gesture.
//

@property (nonatomic, assign) BOOL enforceConstraints;

//
//  This is the *minimum* horizontal distance to move before the gesture is
//  recognized.
//

@property (nonatomic, assign) CGFloat dx;

//
//  This is the *maximum* vertical movement allowed in the initial phase in 
//  order to recognize the gesture.
//

@property (nonatomic, assign) CGFloat dy;

//
//  The translation from the initial touch point to the current point.
//

@property (nonatomic, assign) CGPoint translation;

//
//  The location of the initial touch.
//

@property (nonatomic, assign) CGPoint initialTouchPoint;

//
//  The location of the current touch.
//

@property (nonatomic, assign) CGPoint currentTouchPoint;

@end
