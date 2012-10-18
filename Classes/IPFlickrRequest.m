//
//  IPFlickrRequest.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 5/18/11.
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

#import "IPFlickrRequest.h"
#import "IPFlickrAuthorizationManager.h"

@interface IPFlickrRequest ()

@property (nonatomic, readonly) OFFlickrAPIRequest *request;
@property (nonatomic, copy) IPFlickrRequestSuccessCompletion successCompletion;
@property (nonatomic, copy) IPFlickrRequestErrorCompletion errorCompletion;
@property (nonatomic, strong) IPFlickrRequest *selfReference;

//
//  Private initializer.
//

- (id)initWithGet:(NSString *)apiName 
     andArguments:(NSDictionary *)arguments
        onSuccess:(IPFlickrRequestSuccessCompletion)successCompletion 
          onError:(IPFlickrRequestErrorCompletion)errorCompletion;

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPFlickrRequest

@synthesize request = request_;
@synthesize successCompletion = successCompletion_;
@synthesize errorCompletion = errorCompletion_;

////////////////////////////////////////////////////////////////////////////////
//
//  Public routine for doing calls.
//

+ (void)callWithGet:(NSString *)apiName 
       andArguments:(NSDictionary *)arguments 
          onSuccess:(IPFlickrRequestSuccessCompletion)successCompletion 
            onError:(IPFlickrRequestErrorCompletion)errorCompletion {
  
  _GTMDevLog(@"%s -- doing call %@ with arguments %@",
             __PRETTY_FUNCTION__,
             apiName,
             arguments);
  
  //
  //  Note this object will get released on completion.
  //
  
  [[IPFlickrRequest alloc] initWithGet:apiName 
                          andArguments:arguments 
                             onSuccess:successCompletion 
                               onError:errorCompletion];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Designated initializer.
//

- (id)initWithGet:(NSString *)apiName 
     andArguments:(NSDictionary *)arguments 
        onSuccess:(IPFlickrRequestSuccessCompletion)successCompletion 
          onError:(IPFlickrRequestErrorCompletion)errorCompletion {
  
  self = [super init];
  if (self != nil) {
    
    request_ = [[OFFlickrAPIRequest alloc] initWithAPIContext:[[IPFlickrAuthorizationManager sharedManager] context]];
    request_.delegate = self;
    self.successCompletion = successCompletion;
    self.errorCompletion = errorCompletion;
    [self.request callAPIMethodWithGET:apiName arguments:arguments];
    self.selfReference = self;
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release retained properties.
//


#pragma mark - OFFlickrAPIRequestDelegate

////////////////////////////////////////////////////////////////////////////////
//
//  Successful completion.
//

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary {
  
  if (self.successCompletion != nil) {
    
    self.successCompletion(inResponseDictionary);
  }
  self.selfReference = nil;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Error completion.
//

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError {
  
  if (self.errorCompletion != nil) {
    
    self.errorCompletion(inError);
  }
  self.selfReference = nil;
}

@end
