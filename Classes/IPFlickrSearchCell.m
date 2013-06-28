//
//  IPFlickrSearchCell.m
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

#import "IPFlickrSearchCell.h"
#import "IPFlickrRequest.h"
#import "IPFlickrSelectableAsset.h"

@interface IPFlickrSearchCell ()

@property (nonatomic, strong) NSArray *searchResults;

@property (nonatomic, assign) NSUInteger epoch;

//
//  Perform the flickr search. Call the completion routine with the
//  result dictionary.
//

- (void)search:(void(^)(NSDictionary *results))completion
       onError:(void(^)(NSError *error))errorCompletion;


@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPFlickrSearchCell

@dynamic title;
@synthesize searchApi = searchApi_;
@synthesize searchArguments = searchArguments_;
@synthesize resultKeyPath = resultKeyPath_;
@synthesize searchResults = searchResults_;
@synthesize epoch = epoch_;

////////////////////////////////////////////////////////////////////////////////
//
//  Initializer
//

- (id)initWithCellIdentifier:(NSString *)cellIdentifier {
  
  self = [super initWithCellIdentifier:cellIdentifier];
  self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release retained properties.
//


////////////////////////////////////////////////////////////////////////////////
//
//  Configure the cell based upon search parameters. This will do the search
//  and use the thumbnail of the first result in the imageView of the cell.
//

- (void)configureCell {
  
  self.searchResults = nil;
  self.imageView.image = nil;
  self.epoch++;
  
  [self searchResults:^(NSArray *results) {
    
    IPFlickrSelectableAsset *asset = results[0];
    [asset thumbnailAsyncWithCompletion:^(UIImage *thumbnail) {
      
      self.imageView.image = thumbnail;
      [self setNeedsLayout];
    }];
  } onError:^(NSError *error) {
    
    DDLogVerbose(@"%s -- error getting results: %@",
               __PRETTY_FUNCTION__,
               error);
  }];
}

#pragma mark - Properties

////////////////////////////////////////////////////////////////////////////////
//
//  Gets the title from |textLabel|.
//

- (NSString *)title {
  
  return self.textLabel.text;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Sets the title.
//

- (void)setTitle:(NSString *)title {
  
  self.textLabel.text = title;
}

#pragma mark - Searching

////////////////////////////////////////////////////////////////////////////////
//
//  Do a search.
//

- (void)search:(void (^)(NSDictionary *))completion 
       onError:(void (^)(NSError *))errorCompletion {
  
  completion = [completion copy];
  errorCompletion = [errorCompletion copy];
  NSUInteger expectedEpoch = self.epoch;
  
  [IPFlickrRequest callWithGet:self.searchApi 
                  andArguments:self.searchArguments 
                     onSuccess:^(NSDictionary *responseDictionary) {
                       
                       if (expectedEpoch != self.epoch) {
                         
                         NSError *mismatchedEpoch = [NSError errorWithDomain:@"Pholio" code:-2 userInfo:nil];
                         errorCompletion(mismatchedEpoch);
                         return;
                       }
                       completion(responseDictionary);
                     } 
                       onError:^(NSError *error) {
                         
                         errorCompletion(error);
                       }
   ];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Return search results.
//

- (void)searchResults:(void (^)(NSArray *))resultsCompletion 
              onError:(void (^)(NSError *))errorCompletion {
  
  if (self.searchResults != nil) {
    
    resultsCompletion(self.searchResults);
    return;
  }
  
  resultsCompletion = [resultsCompletion copy];
  errorCompletion = [errorCompletion copy];
  
  [self search:^(NSDictionary *responseDictionary) {
    
    id results = [responseDictionary valueForKeyPath:self.resultKeyPath];
    if (results == nil) {
      
      DDLogVerbose(@"%s -- unable to find any results in %@",
                 __PRETTY_FUNCTION__,
                 [responseDictionary description]);
      NSError *noResults = [NSError errorWithDomain:@"Pholio" code:-1 userInfo:nil];
      errorCompletion(noResults);
      return;
    }
    if (![results isKindOfClass:[NSArray class]]) {
      
      //
      //  Wrap our result in an array if it isn't one already.
      //
      
      results = @[results];
    }
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:[results count]];
    for (NSDictionary *properties in results) {
      
      IPFlickrSelectableAsset *asset = [[IPFlickrSelectableAsset alloc] init];
      asset.photoProperties = properties;
      [assets addObject:asset];
    }

    self.searchResults = assets;
    resultsCompletion(assets);

  } onError:^(NSError *error) {
    
    errorCompletion(error);
  }];
}
@end
