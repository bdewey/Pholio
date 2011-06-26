//
//  NSObject+NullAwareProperties.h
//  ipad-portfolio
//
//  This category creates a |NSNull| aware version of setValue:forKeyPath:.
//  If the value is [NSNull null], then we set the value to |nil|.
//
//  Created by Brian Dewey on 4/15/11.
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


@interface NSObject (NullAwareProperties)

//
//  |NSNull| aware version of setValue:forKeyPath:.
//  If |value| is [NSNull null], then we set the key path value to |nil|.
//

- (void)nullAwareSetValue:(id)value forKeyPath:(NSString *)keyPath;

@end
