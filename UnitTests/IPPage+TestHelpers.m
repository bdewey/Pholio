//
//  IPPage-TestHelpers.m
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

#import "IPPage+TestHelpers.h"
#import "IPPhoto+TestHelpers.h"
#import "NSObject+DeallocUnitTests.h"


@implementation IPPage (TestHelpers)

+ (IPPage *)pageWithPhotoCount:(NSUInteger)count {
  
  IPPage *page = [[[IPPage alloc] init] autorelease];
  for (NSUInteger i = 0; i < count; i++) {
    IPPhoto *photo = [IPPhoto photoWithCaption:[NSString stringWithFormat:@"Photo %d", i]];
    [page insertObject:photo inPhotosAtIndex:i];
  }
  _GTMDevAssert([page countOfPhotos] == count, 
                @"Should have the expected number of photos");
  return page;
}

- (NSUInteger)countOfObjectsInHierarchy {
  return 1 + [self countOfPhotos];
}

@end
