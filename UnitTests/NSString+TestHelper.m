//
//  NSString+TestHelper.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 4/5/11.
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

#import "NSString+TestHelper.h"
#import "IPPhoto.h"

@implementation NSString (TestHelper)

- (NSString *)asPathInDocumentsFolder {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                       NSUserDomainMask, 
                                                       YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  return [documentsDirectory stringByAppendingPathComponent:self];
}

- (NSString *)asPathInThumbnailCache {
  return [[IPPhoto thumbnailDirectory] stringByAppendingPathComponent:self];
}

- (NSString *)asPathInBundlePath {
  
  NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
  return [bundlePath stringByAppendingPathComponent:self];
}

- (NSString *)asPathInCachesFolder {
  
  return [[NSString cachesFolder] stringByAppendingPathComponent:self];
}

+ (NSString *)cachesFolder {
  
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, 
                                                       NSUserDomainMask, 
                                                       YES);
  return [paths objectAtIndex:0];
}
@end
