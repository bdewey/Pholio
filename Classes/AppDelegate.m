//
//  ipad_portfolioAppDelegate.m
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

#import "AppDelegate.h"
#import "IPPortfolioGridViewController.h"
#import "ObjectiveFlickr.h"
#import "IPFlickrAuthorizationManager.h"
#import "IPOptimizingPhotoNotification.h"

//
//  Private methods
//

@interface AppDelegate ()

//
//  Helper property to get the top-level |IPPortfolioGridViewController|.
//

@property (nonatomic, readonly) IPPortfolioGridViewController *portfolioGridView;

//
//  If we're showing UI about optimizing photos, this is the UI.
//

@property (nonatomic, retain) IPOptimizingPhotoNotification *optimizingNotification;

@end


@implementation AppDelegate

@synthesize window;
@synthesize navigationController = navigationController_;
@synthesize avoidMultithreading = avoidMultithreading_;
@dynamic portfolioGridView;
@synthesize optimizingNotification = optimizingNotification_;

////////////////////////////////////////////////////////////////////////////////
//
//  Dealloc.
//

- (void)dealloc {
  [window release];
  [navigationController_ release];
  [optimizingNotification_ release];
  [super dealloc];
}


#pragma mark -
#pragma mark Application lifecycle

////////////////////////////////////////////////////////////////////////////////
//
//  On launch, load the portfolio and assign it to |self.portfolioGridView|.
//

- (BOOL)application:(UIApplication *)application 
  didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
  
  [window addSubview:self.navigationController.view];

  //
  //  Need to force the view to load prior to assigning the portfolio.
  //
  
  // [self.portfolioGridView view];
  self.portfolioGridView.portfolio = [IPPortfolio loadPortfolioFromPath:[IPPortfolio defaultPortfolioPath]];
  
  //
  //  Set appearance defaults.
  //
  
  if ([self.portfolioGridView.portfolio.backgroundImageName length] == 0) {
    
    self.portfolioGridView.portfolio.backgroundImageName = @"black.jpg";
    [self.portfolioGridView.portfolio savePortfolioToPath:[IPPortfolio defaultPortfolioPath]];
  }
  
  if (self.portfolioGridView.portfolio.fontColor == nil) {
    
    self.portfolioGridView.portfolio.fontColor = [UIColor whiteColor];
    [self.portfolioGridView.portfolio savePortfolioToPath:[IPPortfolio defaultPortfolioPath]];
  }
  
  [window makeKeyAndVisible];
  
  //
  //  Validate any stored flickr token.
  //
  
  IPFlickrAuthorizationManager *authManager = [IPFlickrAuthorizationManager sharedManager];
  if (authManager.authToken != nil) {
    
    _GTMDevLog(@"%s -- found stored token %@, checking validity",
               __PRETTY_FUNCTION__,
               authManager.authToken);
    [authManager checkToken];
  }
  
  //
  //  Make sure we have our welcome content.
  //
  
  [self.portfolioGridView ensureWelcomeSet];
  
  //
  //  Register to show UI when there are optimizations in progress.
  //
  
  [[IPPhotoOptimizationManager sharedManager] setDelegate:self];
  
  return YES;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Handle a return from the flickr authorization routine.
//

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
  
  [[IPFlickrAuthorizationManager sharedManager] processFlickrAuthUrl:url];
  return YES;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Save the portfolio (in case I forgot to save it somewhere else -- I *should*
//  save as changes are made in case the app crashes, so this is a no-op)
//

- (void)applicationWillResignActive:(UIApplication *)application {

  //
  //  Catchall, in case I forget to save somewhere else.
  //
  
  [self.portfolioGridView.portfolio savePortfolioToPath:[IPPortfolio defaultPortfolioPath]];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Re-load user defaults and re-load the portfolio if it's changed.
//  (The primary scenario for a portfolio change is via iTunes sync.)
//

- (void)applicationDidBecomeActive:(UIApplication *)application {
  
  //
  //  NOTE: synchronize the defaults in case they've changed since we last ran
  //  the application.
  //
  
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  //
  //  If there are any popovers that were active prior to switching away,
  //  dismiss them.
  //
  
  IPEditableTitleViewController *top = (IPEditableTitleViewController *)[self.navigationController topViewController];
  [top dismissPopover];
  
  //
  //  Let the top controller know that it's about to reappear. This will
  //  potentially update the navigation bar.
  //
  
  [top viewWillAppear:NO];
  
  //
  //  Before looking for new pictures, reload the portfolio. It could be 
  //  changed through document syncing.
  //
  
  IPPortfolio *savedPortfolio = [IPPortfolio loadPortfolioFromPath:[IPPortfolio defaultPortfolioPath]];
  _GTMDevLog(@"%s -- saved version = %d, in memory version = %d",
             __PRETTY_FUNCTION__,
             savedPortfolio.version,
             self.portfolioGridView.portfolio.version);
  if (savedPortfolio.version != self.portfolioGridView.portfolio.version) {
    self.portfolioGridView.portfolio = savedPortfolio;
  }
  [self.portfolioGridView lookForFoundPictures];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Again, a catch-all save in case I forgot to save when a change was made.
//

- (void)applicationWillTerminate:(UIApplication *)application {
  [self.portfolioGridView.portfolio savePortfolioToPath:[IPPortfolio defaultPortfolioPath]];
}

#pragma mark - IPPhotoOptimizationManagerDelegate

////////////////////////////////////////////////////////////////////////////////
//
//  Display notification that optimization is going on.
//

- (void)optimizationManager:(IPPhotoOptimizationManager *)optimizationManager 
   didHaveOptimizationCount:(NSUInteger)optimizationCount {
  
  _GTMDevLog(@"%s -- count is %d", __PRETTY_FUNCTION__, optimizationCount);
  if (optimizationCount == 0) {
  
    [self.optimizingNotification.view removeFromSuperview];
    self.optimizingNotification = nil;
    
  } else {
    
    if (self.optimizingNotification == nil) {
      
      self.optimizingNotification = [[[IPOptimizingPhotoNotification alloc] initWithNibName:nil bundle:nil] autorelease];
      self.optimizingNotification.modalPresentationStyle = UIModalPresentationFormSheet;
      self.optimizingNotification.view.center = self.navigationController.view.center;
      [self.navigationController.view addSubview:self.optimizingNotification.view];
    }
    self.optimizingNotification.activeOptimizations = optimizationCount;
  }
}

#pragma mark -
#pragma mark Memory management

////////////////////////////////////////////////////////////////////////////////
//
//  Free whatever memory I can.
//

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
  /*
   Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
   */
}

#pragma mark - Properties

////////////////////////////////////////////////////////////////////////////////
//
//  Gets the top-level |IPPortfolioGridViewController|.
//

- (IPPortfolioGridViewController *)portfolioGridView {
  
  return (IPPortfolioGridViewController *)[self.navigationController.viewControllers objectAtIndex:0];
}
@end
