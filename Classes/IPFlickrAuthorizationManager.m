//
//  IPFlickrAuthorizationManager.m
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

#import "IPFlickrAuthorizationManager.h"
#import "IPFlickrRequest.h"
#import "IPFlickrApiKeys.h"

#define kIPFlickrAuthToken                @"kIPFlickrAuthToken"

@interface IPFlickrAuthorizationManager ()

//
//  A specific request object.
//

@property (nonatomic, readonly) OFFlickrAPIRequest *request;

//
//  Redefine as read/write for internal use.
//

@property (nonatomic, copy, readwrite) NSString *flickrUserName;

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPFlickrAuthorizationManager

@synthesize context = context_;
@synthesize request = request_;
@dynamic authToken;
@synthesize flickrUserName = flickrUserName_;
@synthesize sharedApplication = sharedApplication_;

////////////////////////////////////////////////////////////////////////////////
//
//  Release all retained properties.
//


////////////////////////////////////////////////////////////////////////////////
//
//  Get the shared authorization manager.
//

+ (IPFlickrAuthorizationManager *)sharedManager {
  
  static IPFlickrAuthorizationManager *sharedManager_;
  if (sharedManager_ == nil) {
    sharedManager_ = [[IPFlickrAuthorizationManager alloc] init];
  }
  return sharedManager_;
}

#pragma mark - Properties

////////////////////////////////////////////////////////////////////////////////
//
//  Lazy initializer for |context|. Initializes the context with the application
//  API key and shared secret, then sets the auth token to |self.authToken|
//  (which is a property persisted in NSUserDefaults).
//

- (OFFlickrAPIContext *)context {
  
#ifdef PHOLIO_FLICKR_API_KEY
  if (context_ == nil) {
    
    context_ = [[OFFlickrAPIContext alloc] initWithAPIKey:PHOLIO_FLICKR_API_KEY
                                             sharedSecret:PHOLIO_FLICKR_API_SHARED_SECRET];
    context_.authToken = self.authToken;
  }
#endif
  return context_;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Lazy initializer for |request|. The request gets set to have |self.context|
//  as its context, and this object is set as the delegate.
//

- (OFFlickrAPIRequest *)request {
  
  if (request_ == nil) {
    
    request_ = [[OFFlickrAPIRequest alloc] initWithAPIContext:self.context];
    request_.delegate = self;
  }
  return request_;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Lazy initializer for |sharedApplication|. If not set, will default to
//  [UIApplication sharedApplication].
//

- (UIApplication *)sharedApplication {
  
  if (sharedApplication_ == nil) {
    
    sharedApplication_ = [UIApplication sharedApplication];
  }
  return sharedApplication_;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Set the auth token. This gets set both on |self.context| and persisted
//  into NSUserDefaults.
//

- (void)setAuthToken:(NSString *)authToken {
  
  self.context.authToken = authToken;
  if (authToken != nil) {

    [[NSUserDefaults standardUserDefaults] setObject:authToken forKey:kIPFlickrAuthToken];
    
  } else {
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kIPFlickrAuthToken];
    self.flickrUserName = nil;
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  Get the auth token.
//

- (NSString *)authToken {

#ifdef PHOLIO_FLICKR_API_KEY
  return [[NSUserDefaults standardUserDefaults] objectForKey:kIPFlickrAuthToken];
#else
  return nil;
#endif
}

////////////////////////////////////////////////////////////////////////////////
//
//  Login to Flickr.
//

- (void)login {
  
  NSURL *loginUrl = [self.context loginURLFromFrobDictionary:nil 
                                         requestedPermission:OFFlickrReadPermission];
  [self.sharedApplication openURL:loginUrl];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Process the flickr authorization url. If the user says this app is 
//  authorized to use the app, flickr will launch the app through this URL;
//  the FROB is on the query string.
//

- (void)processFlickrAuthUrl:(NSURL *)authUrl {
  
  //
  //  Extract the FROB. It's on the query string, which is of the format
  //  "?frob=".
  //
  
  NSString *frob = [[authUrl query] substringFromIndex:6];
  _GTMDevLog(@"%s -- getting a token for frob %@", 
             __PRETTY_FUNCTION__,
             frob);
  
  //
  //  Issue a request to get an auth token from the FROB.
  //
  
  [IPFlickrRequest callWithGet:@"flickr.auth.getToken" 
                  andArguments:[NSDictionary dictionaryWithObject:frob forKey:@"frob"] 
                     onSuccess:^(NSDictionary *responseDictionary) {
                       
                       self.authToken = [[responseDictionary valueForKeyPath:@"auth.token"] textContent];
                       self.flickrUserName = [responseDictionary valueForKeyPath:@"auth.user.username"];
                       _GTMDevLog(@"%s -- successfully got token for user %@: %@",
                                  __PRETTY_FUNCTION__,
                                  self.flickrUserName,
                                  self.authToken);
                     } 
                       onError:^(NSError *error) {
                         
                         _GTMDevLog(@"%s -- unexpected error %@",
                                    __PRETTY_FUNCTION__,
                                    error);
                       }];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Checks the token that's been stored in the user defaults.
//

- (void)checkToken {
  
  [IPFlickrRequest callWithGet:@"flickr.auth.checkToken" 
                  andArguments:nil 
                     onSuccess:^(NSDictionary *responseDictionary) {
                       
                       self.flickrUserName = [responseDictionary valueForKeyPath:@"auth.user.username"];
                       _GTMDevLog(@"%s -- validated token; user is %@", 
                                  __PRETTY_FUNCTION__,
                                  self.flickrUserName);
                     } onError:^(NSError *error) {
                       
                       self.authToken = nil;
                       _GTMDevLog(@"%s -- could not validate token. Discarding.",
                                  __PRETTY_FUNCTION__);
                     }
   ];
}

@end
