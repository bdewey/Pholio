//
//  IPPortfolio+TestHelpers.h
//  ipad-portfolio
//
//  Created by Brian Dewey on 4/7/11.
//  Copyright 2011 Brian's Brain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPPortfolio.h"

@interface IPPortfolio (TestHelpers)

//
//  Gets the number of objects in the hierarchy.
//

- (NSUInteger)countOfObjectsInHierarchy;

//
//  Creates a portfolio with a number of sets. Each set will
//  have 5 photos.
//

+ (IPPortfolio *)portfolioWithSetCount:(NSUInteger)setCount;

@end
