//
//  IPFlickrSearchCell.h
//  ipad-portfolio
//
//  Created by Brian Dewey on 5/19/11.
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
#import "BDSmartTableViewCell.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface IPFlickrSearchCell : BDSmartTableViewCell { }

//
//  Cell title.
//

@property (nonatomic, copy) NSString *title;

//
//  The flickr search API associated with this cell.
//

@property (nonatomic, copy) NSString *searchApi;

//
//  The search arguments associated with this cell.
//

@property (nonatomic, retain) NSDictionary *searchArguments;

//
//  The key path that selects the returned photos.
//

@property (nonatomic, copy) NSString *resultKeyPath;

//
//  Configure the appearance of this cell based upon the search parameters.
//

- (void)configureCell;

//
//  Get the search results. This is an array of |IPFlickrSelectableAsset| objects.
//

- (void)searchResults:(void(^)(NSArray *results))resultsCompletion
              onError:(void(^)(NSError *error))errorCompletion;
@end
