//
//  IPColors.m
//
//  Contains the colors that show up in the UI.
//
//  Created by Brian Dewey on 4/26/11.
//  Copyright 2011 Brian Dewey. All rights reserved.
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

#import "IPColors.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPColors

@synthesize highlightColor = highlightColor_;

////////////////////////////////////////////////////////////////////////////////
//
//  Dealloc.
//

- (void)dealloc {
  
  [highlightColor_ release];
  [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Gets the default color scheme.
//

+ (IPColors *)defaultColors {
  
  static IPColors *defaultColors = nil;
  
  if (defaultColors == nil) {
    
    defaultColors = [[IPColors alloc] init];
    defaultColors.highlightColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.0 alpha:1.0];
  }
  return defaultColors;
}

@end
