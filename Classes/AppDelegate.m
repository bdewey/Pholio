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
#import "NSString+TestHelper.h"
#import "IPDropBoxApiKeys.h"
#import "DropboxSDK.h"

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

- (IPSet *)welcomeSet;
- (IPSet *)sampleLandscapes;
- (IPSet *)setNamed:(NSString *)setName fromImagesNamed:(NSArray *)imageNames;
- (void)ensureWelcomeSetForPortfolio:(IPPortfolio *)portfolio;
- (void)upgradePhotoOptimizationForPortfolio:(IPPortfolio *)portfolio completion:(IPPhotoOptimizationCompletion)completion;
- (void)preparePortfolioForDisplay;

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
  
#ifdef PHOLIO_TESTFLIGHT_TEAM_TOKEN
  [TestFlight takeOff:PHOLIO_TESTFLIGHT_TEAM_TOKEN];
  
#ifdef DEBUG
  [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#endif // DEBUG
#endif // PHOLIO_TESTFLIGHT_TEAM_TOKEN
  
  [window addSubview:self.navigationController.view];
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
  //  Initialize the DropBox session
  //
  
#ifdef PHOLIO_DROPBOX_API_KEY
  DBSession *session = [[[DBSession alloc] initWithConsumerKey:PHOLIO_DROPBOX_API_KEY 
                                                consumerSecret:PHOLIO_DROPBOX_API_SHARED_SECRET] autorelease];
  [DBSession setSharedSession:session];
#endif
  
  //
  //  Register to show UI when there are optimizations in progress.
  //
  
  [[IPPhotoOptimizationManager sharedManager] setDelegate:self];
  [self preparePortfolioForDisplay];
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
  //  Note: At this point, if |portfolio| is nil, it means we haven't finished
  //  preparing it from |viewDidLoad|. So do nothing.
  //
  
  if (self.portfolioGridView.portfolio != nil) {
    
    [self preparePortfolioForDisplay];
  }
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
  
  [[NSOperationQueue mainQueue] addOperationWithBlock:^(void) {
    _GTMDevLog(@"%s -- count is %d", __PRETTY_FUNCTION__, optimizationCount);
    if (optimizationCount == 0) {
      
      [self.optimizingNotification.view removeFromSuperview];
      self.optimizingNotification = nil;
      
    } else {
      
      if (self.optimizingNotification == nil) {
        
        self.optimizingNotification = [[[IPOptimizingPhotoNotification alloc] initWithNibName:nil bundle:nil] autorelease];
        self.optimizingNotification.modalPresentationStyle = UIModalPresentationFormSheet;
        CGRect navBounds = self.navigationController.view.bounds;
        self.optimizingNotification.view.center = CGPointMake(CGRectGetMidX(navBounds), 
                                                              CGRectGetMidY(navBounds));
        [self.navigationController.view addSubview:self.optimizingNotification.view];
      }
      self.optimizingNotification.activeOptimizations = optimizationCount;
    }
  }];
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

#pragma mark - Portfolio manipulation

////////////////////////////////////////////////////////////////////////////////
//
//  Prepares a portfolio object for displaying.
//

- (void)preparePortfolioForDisplay {
  
  [[[IPPhotoOptimizationManager sharedManager] optimizationQueue] addOperationWithBlock:^(void) {

    IPPortfolio *portfolio = [IPPortfolio loadPortfolioFromPath:[IPPortfolio defaultPortfolioPath]];
    
    _GTMDevLog(@"%s -- saved version = %d, in memory version = %d",
               __PRETTY_FUNCTION__,
               portfolio.version,
               self.portfolioGridView.portfolio.version);
    if (portfolio.version == self.portfolioGridView.portfolio.version) {
      
      //
      //  The portfolio on disk is already displayed.
      //
      
      return;
    }
    
    //
    //  Set appearance defaults.
    //
    
    if ([portfolio.backgroundImageName length] == 0) {
      
      portfolio.backgroundImageName = @"black.jpg";
      [portfolio savePortfolioToPath:[IPPortfolio defaultPortfolioPath]];
    }
    
    if (portfolio.fontColor == nil) {
      
      portfolio.fontColor = [UIColor whiteColor];
      [portfolio savePortfolioToPath:[IPPortfolio defaultPortfolioPath]];
    }
    
    //
    //  Make sure we have our welcome content.
    //
    
    [self ensureWelcomeSetForPortfolio:portfolio];
    [self upgradePhotoOptimizationForPortfolio:portfolio completion:^(void) {

      self.portfolioGridView.portfolio = portfolio;
      [self.portfolioGridView lookForFoundPictures];
      [self.portfolioGridView startTutorial];
    }];
  }];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Creates the "welcome" set.
//

- (IPSet *)welcomeSet {
  
  NSArray *imageNames = [NSArray arrayWithObjects:
                         @"ChooseYourBest.png",
                         @"GiveItYourLook.png",
                         @"CutTheCord.png",
                         @"Tips.png",
                         nil];
  return [self setNamed:kWelcomeGalleryName fromImagesNamed:imageNames];
}

////////////////////////////////////////////////////////////////////////////////

- (IPSet *)sampleLandscapes {
  
  NSArray *imageNames = [NSArray arrayWithObjects:
                         @"Across the Lake (2008).jpg",
                         @"Count the Balloons (2009).jpg",
                         @"Everglades Sunrise (2009).jpg",
                         @"Frostscape (2008).jpg",
                         @"Haystack Rock (2009).jpg",
                         @"Lone Photographer (2008).jpg",
                         @"Misty Morning (2008).jpg",
                         @"To the Sky (2008).jpg",
                         nil];
  return [self setNamed:@"Example Landscapes" fromImagesNamed:imageNames];
}

////////////////////////////////////////////////////////////////////////////////

- (IPSet *)setNamed:(NSString *)setName fromImagesNamed:(NSArray *)imageNames {
  
  IPSet *theSet = [[[IPSet alloc] init] autorelease];
  theSet.title = setName;
  for (NSString *imageName in imageNames) {
    
    //
    //  Copy the image from the bundle path to the documents path.
    //
    
    NSError *error;
    BOOL success;
    success = [[NSFileManager defaultManager] copyItemAtPath:[imageName asPathInBundlePath] 
                                                      toPath:[imageName asPathInDocumentsFolder] 
                                                       error:&error];
    if (success) {
      
      IPPhoto *photo = [[[IPPhoto alloc] init] autorelease];
      photo.filename = [imageName asPathInDocumentsFolder];
      [photo optimize];
      IPPage *page = [IPPage pageWithPhoto:photo];
      [theSet.pages addObject:page];
      
    } else {
      
      _GTMDevLog(@"%s -- unexpected error copying image %@: %@",
                 __PRETTY_FUNCTION__,
                 imageName,
                 error);
    }
  }
  
  if ([theSet countOfPages] > 0) {
    
    return theSet;
    
  } else {
    
    return nil;
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  Ensure that we have a welcome set.
//

- (void)ensureWelcomeSetForPortfolio:(IPPortfolio *)portfolio {
  
  //
  //  Bump this number each time there's a new version of the welcome set.
  //
  
  NSInteger welcomeSetVersion = 3;
  IPUserDefaults *userDefaults = [IPUserDefaults defaultSettings];
  if ([userDefaults welcomeVersion] < welcomeSetVersion) {
    
    //
    //  Right now, doing this synchronously so I don't race with the code that
    //  looks for unrecognized files. This should be fast-ish.
    //
    
    IPSet *welcomeSet = [self welcomeSet];
    if (welcomeSet) {
      
      [portfolio insertObject:welcomeSet inSetsAtIndex:[portfolio countOfSets]];
    }
    IPSet *landscapes = [self sampleLandscapes];
    if (landscapes) {

      [portfolio insertObject:landscapes inSetsAtIndex:[portfolio countOfSets]];
    }
    userDefaults.welcomeVersion = welcomeSetVersion;
    [portfolio savePortfolioToPath:[IPPortfolio defaultPortfolioPath]];
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  Upgrade optimization of any photos.
//

- (void)upgradePhotoOptimizationForPortfolio:(IPPortfolio *)portfolio completion:(IPPhotoOptimizationCompletion)completion {
  
  completion = [completion copy];
  _GTMDevLog(@"%s -- Portfolio image optimization version = %d, current = %d",
             __PRETTY_FUNCTION__,
             portfolio.imageOptimizationVersion,
             kIPPhotoCurrentOptimizationVersion);
  if (portfolio.imageOptimizationVersion == kIPPhotoCurrentOptimizationVersion) {
    
    //
    //  The portfolio has already been optimized. Short-circuit.
    //
    
    if (completion != nil) {
      [[NSOperationQueue mainQueue] addOperationWithBlock:^(void) {

        completion();
        [completion release];
      }];
    }
    return;
  }
  
  NSMutableArray *toOptimize = [[NSMutableArray alloc] init];
  for (IPSet *theSet in portfolio.sets) {
    
    for (IPPage *thePage in theSet.pages) {
      
      for (IPPhoto *thePhoto in thePage.photos) {
        
        if (![thePhoto isOptimized]) {
          
          [toOptimize addObject:thePhoto];
        }
      }
    }
  }
  
  if ([toOptimize count] == 0) {
    
    portfolio.imageOptimizationVersion = kIPPhotoCurrentOptimizationVersion;
    [portfolio savePortfolioToPath:[IPPortfolio defaultPortfolioPath]];
    if (completion != nil) {
      
      [[NSOperationQueue mainQueue] addOperationWithBlock:^(void) {
        
        completion();
        [completion release];
      }];
    }
    [toOptimize release];
    return;
  }
  
  [[IPPhotoOptimizationManager sharedManager] asyncOptimizePhotos:toOptimize withCompletion:^(void) {

    portfolio.imageOptimizationVersion = kIPPhotoCurrentOptimizationVersion;
    [portfolio savePortfolioToPath:[IPPortfolio defaultPortfolioPath]];
    if (completion != nil) {
      
      completion();
      [completion release];
    }
    [toOptimize release];
  }];
}
@end
