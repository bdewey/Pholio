//
//  IPSet+TestHelpers.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 4/6/11.
//  Copyright 2011 Brian's Brain. All rights reserved.
//

#import "IPSet+TestHelpers.h"
#import "IPPage+TestHelpers.h"

@implementation IPSet (TestHelpers)

+ (IPSet *)setWithPageCount:(NSUInteger)count {
  IPSet *set = [[[IPSet alloc] init] autorelease];
  for (NSUInteger i = 0; i < count; i++) {
    IPPage *page = [IPPage pageWithPhotoCount:1];
    [page setValue:[NSString stringWithFormat:@"Page %d", i] 
        forKeyPath:@"title" 
          forPhoto:0];
    [set insertObject:page inPagesAtIndex:i];
  }
  return set;
}

- (NSUInteger)countOfObjectsInHierarchy {
  NSUInteger count = 0;
  for (IPPage *page in pages_) {
    count += [page countOfObjectsInHierarchy];
  }
  return count + 1;
}

@end
