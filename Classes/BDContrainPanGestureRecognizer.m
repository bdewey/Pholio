//
//  BDContrainPanGestureRecognizer.m
//  ipad-portfolio
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

#import "BDContrainPanGestureRecognizer.h"

//
//  Comment this out if you don't want to see the recognizer state machine.
//

//#define __TRACE_RECOGNIZER__

//
//  Redefine _GTMDevLog based upon the __TRACE_RECOGNIZER__ #define.
//

#undef _GTMDevLog
#ifdef __TRACE_RECOGNIZER__
#define _GTMDevLog(...) NSLog(__VA_ARGS__)
#else
#define _GTMDevLog(...) do { } while (0)
#endif

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation BDContrainPanGestureRecognizer

@synthesize enforceConstraints = enforceConstraints_;
@synthesize dx = dx_;
@synthesize dy = dy_;
@synthesize translation = translation_;
@synthesize initialTouchPoint = initialTouchPoint_;
@synthesize currentTouchPoint = currentTouchPoint_;

////////////////////////////////////////////////////////////////////////////////
//
//  Designated initializer.
//

- (id)initWithTarget:(id)target action:(SEL)action {
  
  self = [super initWithTarget:target action:action];
  if (self != nil) {
    
    self.enforceConstraints = YES;
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Dealloc.
//

- (void)dealloc {

  [super dealloc];
}

#pragma mark -
#pragma mark Touch

////////////////////////////////////////////////////////////////////////////////
//
//  Note the start of the gesture.
//

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  
  [super touchesBegan:touches withEvent:event];
  if ([self numberOfTouches] != 1) {
    
    //
    //  This gesture starts with a single touch.
    //
    
    self.state = UIGestureRecognizerStateFailed;
    return;
  }
  self.initialTouchPoint = [[touches anyObject] locationInView:self.view];
#ifdef __TRACE_RECOGNIZER__
  CFDictionaryRef pointDebug = CGPointCreateDictionaryRepresentation(self.initialTouchPoint);
  _GTMDevLog(@"%s -- state = %d, initial touch %@",
             __PRETTY_FUNCTION__,
             self.state,
             pointDebug);
  CFRelease(pointDebug);
#endif
}

////////////////////////////////////////////////////////////////////////////////
//
//  The touch moved. See if it moved far enough to start the gesture.
//

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  
  [super touchesMoved:touches withEvent:event];
  if ([self numberOfTouches] != 1) {
    
    self.state = UIGestureRecognizerStateFailed;
  }
  if (self.state == UIGestureRecognizerStateFailed) {
    
    return;
  }
  
  self.currentTouchPoint = [[touches anyObject] locationInView:self.view];
  
  //
  //  Compute the translation from |initialPoint| to |currentPoint|.
  //
  
  translation_.x = currentTouchPoint_.x - initialTouchPoint_.x;
  translation_.y = currentTouchPoint_.y - initialTouchPoint_.y;
  
  //
  //  If we're still in the |UIGestureRecognizerStatePossible| state, then look
  //  at the translation to see if we've moved far enough to qualify as
  //  beginning.
  //
  
  if (self.state == UIGestureRecognizerStatePossible) {

    //
    //  Note that if enforceConstraints is NO, then we will always fall into
    //  UIGestureRecognizerStateBegan, no matter how far or in what direction
    //  we move.
    //
    
    if (!self.enforceConstraints ||
        ((ABS(translation_.x) >= dx_) && (ABS(translation_.y) < dy_))) {
      
      //
      //  We are now beginning the gesture.
      //
      
      self.state = UIGestureRecognizerStateBegan;
      
    } else if (ABS(translation_.y) >= dy_) {
      
      //
      //  We moved too far vertically. Fail.
      //
      
      self.state = UIGestureRecognizerStateFailed;
    }
    
  } else {
    
    self.state = UIGestureRecognizerStateChanged;
  }
  
#ifdef __TRACE_RECOGNIZER__
  CFDictionaryRef pointDebug = CGPointCreateDictionaryRepresentation(self.translation);
  _GTMDevLog(@"%s -- state %d, translation = %@",
             __PRETTY_FUNCTION__,
             self.state,
             pointDebug);
  CFRelease(pointDebug);
#endif
}

////////////////////////////////////////////////////////////////////////////////
//
//  We end when the touches end.
//

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  
  [super touchesEnded:touches withEvent:event];
  if ((self.state == UIGestureRecognizerStateBegan) ||
      (self.state == UIGestureRecognizerStateChanged)) {
    
    self.state = UIGestureRecognizerStateEnded;
  }
  _GTMDevLog(@"%s -- state %d",
             __PRETTY_FUNCTION__,
             self.state);
}

@end
