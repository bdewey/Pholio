//
//  IPPortfolio+TestHelpers.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 4/7/11.
//  Copyright 2011 Brian's Brain. All rights reserved.
//

#import "IPPortfolio+TestHelpers.h"
#import "IPSet+TestHelpers.h"

@implementation IPPortfolio (TestHelpers)

- (NSUInteger)countOfObjectsInHierarchy {
  NSUInteger count = 1;
  for (IPSet *set in self.sets) {
    count += [set countOfObjectsInHierarchy];
  }
  return count;
}

+ (IPPortfolio *)portfolioWithSetCount:(NSUInteger)setCount {
  
  IPPortfolio *portfolio = [[[IPPortfolio alloc] init] autorelease];
  for (int i = 0; i < setCount; i++) {
    IPSet *set = [IPSet setWithPageCount:5];
    set.title = [NSString stringWithFormat:@"Set %d", i];
    [portfolio insertObject:set inSetsAtIndex:i];
  }
  return portfolio;
}

@end
