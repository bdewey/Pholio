//
//  IPFlickrSearchSource.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 5/20/11.
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

#import "IPFlickrSearchSource.h"
#import "IPFlickrSearchCell.h"
#import "IPFlickrRequest.h"
#import "IPFlickrSelectableAsset.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPFlickrSearchSource

@synthesize searchCell = searchCell_;

////////////////////////////////////////////////////////////////////////////////
//
//  Designated initializer.
//

- (id)initWithSearchCell:(IPFlickrSearchCell *)cell {
  
  self = [super init];
  if (self != nil) {
    
    self.searchCell = cell;
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Convenience constructor.
//

+ (IPFlickrSearchSource *)sourceWithSearchCell:(IPFlickrSearchCell *)cell {
  
  IPFlickrSearchSource *source = [[IPFlickrSearchSource alloc] initWithSearchCell:cell];
  return source;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release retained properties.
//


#pragma mark - BDAssetsSource

////////////////////////////////////////////////////////////////////////////////
//
//  Fill in an assets array.
//

- (void)asyncFillArrayWithChildren:(NSMutableArray *)children
                         andAssets:(NSMutableArray *)assets 
       withSelectableAssetDelegate:(id<BDSelectableAssetDelegate>)delegate 
                        completion:(void (^)())completion {
  
  completion = [completion copy];
  [self.searchCell searchResults:^(NSArray *results) {
    
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [results count])];
    [assets insertObjects:results atIndexes:indexes];
    [assets enumerateObjectsAtIndexes:indexes options:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      
      ((IPFlickrSelectableAsset *)obj).delegate = delegate;
    }];
    completion();
  } 
                         onError:^(NSError *error) {
                           
                           _GTMDevLog(@"%s -- error performing search: %@",
                                      __PRETTY_FUNCTION__,
                                      error);
                         }
   ];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Return the title.
//

- (NSString *)title {
  
  return self.searchCell.title;
}

@end
