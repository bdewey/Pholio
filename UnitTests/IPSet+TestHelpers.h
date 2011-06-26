//
//  IPSet+TestHelpers.h
//  ipad-portfolio
//
//  Created by Brian Dewey on 4/6/11.
//  Copyright 2011 Brian's Brain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPSet.h"

@interface IPSet (TestHelpers)

//
//  Creates a set with the specified number of pages. Each page will have
//  1 photo.
//

+ (IPSet *)setWithPageCount:(NSUInteger)count;

//
//  Gets the number of objects in the hierarchy.
//

- (NSUInteger)countOfObjectsInHierarchy;

@end
