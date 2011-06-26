//
//  NSObject+DeallocUnitTests.h
//  ipad-portfolio
//
//  Created by Brian Dewey on 4/6/11.
//  Copyright 2011 Brian Dewey. 
//
//  This category counts the number of times tracked objects receive a 
//  |dealloc| message. Its intended use is to detect if there are retain cycles
//  in an object hierarchy that prevent the |release| message sent to the root
//  object in a hierarchy from deallocating the entire hierarchy.
//
//  To use this, first clear the dealloc count: 
//
//    [NSObject clearDeallocCallCounter];
//
//  Then, you must "mark" each class that you want to verify gets a |dealloc| 
//  message:
//
//    [NSObject markClassForDeallocTracking:[myClass class]];
//
//  Release the object:
//
//    [myObject release];
//
//  And then you can check that the marked objects in your hierarchy got the
//  |dealloc| message. [NSObject deallocCallCounter] will tell you the number 
//  of |dealloc| messages that have been received.
//
//
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


@interface NSObject (DeallocUnitTests)

//
//  Marks an object for having its dealloc routine tracked.
//

+ (void)markClassForDeallocTracking:(Class)currentClass;

//
//  Counts the number of times that dealloc has been called on marked objects.
//

+ (NSUInteger)deallocCallCounter;

//
//  Clears the dealloc call counter.
//

+ (void)clearDeallocCallCounter;


@end
