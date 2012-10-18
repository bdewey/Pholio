//
//  IPUserDefaults.h
//  ipad-portfolio
//
//  This class is a singleton that provides type-safe access to important
//  settings in the "user default" store.
//
//  Created by Brian Dewey on 4/9/11.
//  Copyright 2011 Brian's Brain. All rights reserved.
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

#define kUserDefaultHideEditControls            @"hide_edit_controls"
#define kWelcomeVersion                         @"welcome_version"
#define kLastRatedVersion                       @"last_rated_version"
#define kNumberOfTimesAskedToRate               @"number_of_times_asked_to_rate"
#define kLastTimeAskedToRate                    @"last_time_asked_to_rate"
#define ProductIdentifierUnlimitedGalleries     @"org.brians_brain.pholio.galleries"
#define ProductIdentifierBrandingKit            @"org.brians_brain.pholio.branding"



@interface IPUserDefaults : NSObject {
    
}

//
//  Is editing enabled for the portfolio?
//

@property (nonatomic) BOOL editingEnabled;

//
//  Has the user bought unlimited galleries?
//

@property (nonatomic) BOOL unlimitedGalleries;

//
//  Has the user bought the branding kit?
//

@property (nonatomic) BOOL brandingKit;

//
//  What version of the welcome gallery has been created?
//

@property (nonatomic, assign) NSInteger welcomeVersion;

@property (nonatomic, assign) NSInteger lastRatedVersion;

@property (nonatomic, assign) NSInteger numberOfTimesAskedToRate;

@property (nonatomic, weak) NSDate *lastTimeAskedToRate;

//
//  This gets the default settings object.
//

+ (IPUserDefaults *)defaultSettings;

//
//  Record that a specific product identifier was purchased.
//

- (void)recordPurchaseOfProductIdentifier:(NSString *)productIdentifier;

@end
