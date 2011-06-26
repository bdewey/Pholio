//
//  NSObject+DeallocUnitTests.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 4/6/11.
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

#import "NSObject+DeallocUnitTests.h"
#import <objc/runtime.h>

//
//  Counter that gets incremented each time a tracked object receives a
//  |dealloc| message.
//

static NSUInteger deallocCallCounter = 0;

@implementation NSObject (DeallocUnitTests)

//
//  PRIVATE: This method performs tracked dealloc. It's intended to be swizzled
//  with |dealloc|.
//

- (void)trackDealloc {
  
  deallocCallCounter++;
  [self trackDealloc];
}

+ (void)markClassForDeallocTracking:(Class)currentClass {
  
  //
  //  Make currentClass override the NSObject trackDealloc implementation.
  //
  
  IMP trackDeallocImp = class_getMethodImplementation([NSObject class], @selector(trackDealloc));
  BOOL success = class_addMethod(currentClass, @selector(trackDealloc), trackDeallocImp, "v@:");
  _GTMDevAssert(success, @"Should be able to add override");
  Method originalDealloc = class_getInstanceMethod(currentClass, @selector(dealloc));
  Method trackedDealloc  = class_getInstanceMethod(currentClass, @selector(trackDealloc));
  method_exchangeImplementations(originalDealloc, trackedDealloc);
}

+ (NSUInteger)deallocCallCounter {
  return deallocCallCounter;
}

+ (void)clearDeallocCallCounter {
  deallocCallCounter = 0;
}

@end
