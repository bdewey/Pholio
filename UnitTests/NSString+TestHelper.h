//
//  NSString+TestHelper.h
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

#import <Foundation/Foundation.h>


@interface NSString (TestHelper)

- (NSString *)asPathInDocumentsFolder;

//
//  Returns a new string formed by appending the receiver to 
//  [IPPhoto thumbnailDirectory].
//

- (NSString *)asPathInThumbnailCache;

//
//  Returns a new string formed by appending the receiver to the bundle path.
//

- (NSString *)asPathInBundlePath;

//
//  As a string in the caches path. Note there is no guarantee that the
//  cache directory exists.
//

- (NSString *)asPathInCachesFolder;

+ (NSString *)cachesFolder;

@end
