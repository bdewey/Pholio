//
//  IPUserDefaults.m
//  ipad-portfolio
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

#import "IPUserDefaults.h"

IPUserDefaults *defaultSettings = nil;

@implementation IPUserDefaults

+ (IPUserDefaults *)defaultSettings {
  if (defaultSettings == nil) {
    defaultSettings = [[IPUserDefaults alloc] init];
  }
  return defaultSettings;
}

#pragma mark Properties

- (BOOL)editingEnabled {
  
  return ![[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultHideEditControls];
}

- (void)setEditingEnabled:(BOOL)editingEnabled {
  
  [[NSUserDefaults standardUserDefaults] setBool:!editingEnabled forKey:kUserDefaultHideEditControls];
}

- (BOOL)unlimitedGalleries {
  
  return [[NSUserDefaults standardUserDefaults] boolForKey:ProductIdentifierUnlimitedGalleries];
}

- (void)setUnlimitedGalleries:(BOOL)unlimitedGalleries {
  
  [[NSUserDefaults standardUserDefaults] setBool:unlimitedGalleries forKey:ProductIdentifierUnlimitedGalleries];
}

- (BOOL)brandingKit {
  
  return [[NSUserDefaults standardUserDefaults] boolForKey:ProductIdentifierBrandingKit];
}

- (void)setBrandingKit:(BOOL)brandingKit {
  
  [[NSUserDefaults standardUserDefaults] setBool:brandingKit forKey:ProductIdentifierBrandingKit];
}

- (void)recordPurchaseOfProductIdentifier:(NSString *)productIdentifier {
  
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
}

- (NSInteger)welcomeVersion {
  
  return [[NSUserDefaults standardUserDefaults] integerForKey:kWelcomeVersion];
}

- (void)setWelcomeVersion:(NSInteger)welcomeVersion {
  
  [[NSUserDefaults standardUserDefaults] setInteger:welcomeVersion forKey:kWelcomeVersion];
}

- (NSInteger)lastRatedVersion {
  
  return [[NSUserDefaults standardUserDefaults] integerForKey:kLastRatedVersion];
}

- (void)setLastRatedVersion:(NSInteger)lastRatedVersion {
  
  [[NSUserDefaults standardUserDefaults] setInteger:lastRatedVersion forKey:kLastRatedVersion];
}

- (NSInteger)numberOfTimesAskedToRate {
  
  return [[NSUserDefaults standardUserDefaults] integerForKey:kNumberOfTimesAskedToRate];
}

- (void)setNumberOfTimesAskedToRate:(NSInteger)numberOfTimesAskedToRate {
  
  [[NSUserDefaults standardUserDefaults] setInteger:numberOfTimesAskedToRate forKey:kNumberOfTimesAskedToRate];
}

- (NSDate *)lastTimeAskedToRate {
  
  NSTimeInterval interval = [[NSUserDefaults standardUserDefaults] doubleForKey:kLastTimeAskedToRate];
  return [NSDate dateWithTimeIntervalSince1970:interval];
}

- (void)setLastTimeAskedToRate:(NSDate *)lastTimeAskedToRate {
  
  NSTimeInterval interval = [lastTimeAskedToRate timeIntervalSince1970];
  [[NSUserDefaults standardUserDefaults] setDouble:interval forKey:kLastTimeAskedToRate];
}

@end
