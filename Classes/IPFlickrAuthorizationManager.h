//
//  IPFlickrAuthorizationManager.h
//
//  Encapsulates all of the work for handling Flickr logon.
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

@interface IPFlickrAuthorizationManager: NSObject<OFFlickrAPIRequestDelegate> { }

//
//  Get the singleton manager.
//

+ (IPFlickrAuthorizationManager *)sharedManager;

//
//  Context for doing Flickr API requests.
//

@property (nonatomic, readonly) OFFlickrAPIContext *context;

//
//  The authorization token. Note that this property will get automatically
//  set onto |context| and stored for future use in the User Defaults.
//

@property (nonatomic, copy) NSString *authToken;

//
//  The flickr user name. Valid only after the auth token has been checked.
//

@property (nonatomic, copy, readonly) NSString *flickrUserName;

//
//  DEBUG HOOK: You can set this property to intercept messages that go to
//  [UIApplication sharedApplication].
//

@property (nonatomic, strong) UIApplication *sharedApplication;

//
//  Launch the Flickr login screen.
//

- (void)login;

//
//  Process the flickr authorization url. This is the URL that the app is
//  launched with after successful authorization. It contains the FROB in
//  the query string.
//

- (void)processFlickrAuthUrl:(NSURL *)authUrl;

//
//  Checks the token stored in the NSUserDefaults.
//

- (void)checkToken;

@end
