//
//  IPFlickrRequest.h
//
//  Block-oriented wrapper for OFFlickrRequest. Don't create instances of this
//  class directly; use just the class |callWithGet| method.
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

#import <Foundation/Foundation.h>
#import "ObjectiveFlickr.h"

typedef void (^IPFlickrRequestSuccessCompletion)(NSDictionary *responseDictionary);
typedef void (^IPFlickrRequestErrorCompletion)(NSError *error);

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface IPFlickrRequest : NSObject<OFFlickrAPIRequestDelegate> { }

//
//  Does a flickr API call with the specified name and arguments. When the
//  call completes, one of the completion routines is called.
//

+ (void)callWithGet:(NSString *)apiName 
       andArguments:(NSDictionary *)arguments
          onSuccess:(IPFlickrRequestSuccessCompletion)successCompletion 
            onError:(IPFlickrRequestErrorCompletion)errorCompletion;

@end
