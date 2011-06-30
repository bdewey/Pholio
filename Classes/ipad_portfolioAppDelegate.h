//
//  ipad_portfolioAppDelegate.h
//  ipad-portfolio
//
//  Created by Brian Dewey on 8/4/10.
//  Copyright 2010 Brian Dewey. 
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

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "IPPortfolio.h"
#import "BDSplashScreen.h"
#import "IPPhotoOptimizationManager.h"

@interface ipad_portfolioAppDelegate : NSObject <
  UIApplicationDelegate, 
  IPPhotoOptimizationManagerDelegate,
  BDSplashScreenDelegate> {
    
  UIWindow *window;
  UINavigationController *navigationController_;
  BOOL avoidMultithreading_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

//
//  If |avoidMultithreading| is YES, then the delegate will avoid posting
//  work to other threads and do the work inline instead. The intended use
//  is unit testing.
//

@property (nonatomic) BOOL avoidMultithreading;

@end

