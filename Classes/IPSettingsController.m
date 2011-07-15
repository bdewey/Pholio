//
//  IPSettingsController.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 5/9/11.
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

#import "IPFlickrApiKeys.h"
#import "IPSettingsController.h"
#import "IPButtonCell.h"
#import "IPCustomBackgroundCell.h"
#import "IPCustomAppearanceController.h"
#import "IPAlert.h"
#import "IPFlickrConnectionCell.h"
#import "IPFlickrLoginController.h"
#import "IPFontPickerCell.h"
#import "BDFontPickerController.h"
#import "IPColorCell.h"
#import "BDColorPicker.h"
#import "IPUserDefaults.h"

enum IPSettingsControllerSections {
  IPSettingsControllerUserGuide,
  IPSettingsControllerDisplay,
  IPSettingsControllerActions,
#ifdef PHOLIO_FLICKR_API_KEY
  IPSettingsControllerConnect,
#endif
  IPSettingsControllerNumSections,
  IPSettingsControllerInAppPurchases
  };

#define kIPSettingsUserGuide        NSLocalizedString(@"", @"User Guide Header")

enum IPSettingsUserGuide {
  IPSettingsUserGuideLaunch,
  IPSettingsUserGuideNumItems
};

#define kIPSettingsActionsTitle     NSLocalizedString(@"", @"Actions")

enum IPSettingsActions {
  IPSettingsActionContactDeveloper,
  IPSettingsActionRateApplication,
  IPSettingsActionNumActions,
  IPSettingsActionEmailPhoto
};

#define kIPSettingsConnectTitle     NSLocalizedString(@"Connect", @"Connect")

enum IPSettingsConnect {
  IPSettingsConnectFlickr,
  IPSettingsConnectNumItems
};

#define kIPSettingsInAppPurchasesTitle    NSLocalizedString(@"In-App Purchases", @"In-App Purchases")

enum IPSettingsInAppPurchases {
  IPSettingsInAppPurchasesRecoverPurchases,
  IPSettingsInAppPurchasesNumActions
};

#define kIPSettingsDisplayTitle     NSLocalizedString(@"Display", @"Display")

enum IPSettingsDisplay {
  IPSettingsDisplayCustomBackground = 0,
  IPSettingsDisplayTitleFont,
  IPSettingsDisplayGridFont,
  IPSettingsDisplayNavigationColor,
  IPSettingsDisplayNumItems,
  IPSettingsDisplayTextColor
};

#define kIPSettingsDisplayTitleFontName    NSLocalizedString(@"Title font", @"Title font")
#define kIPSettingsDisplayGridFontName     NSLocalizedString(@"Grid font", @"Grid font")
#define kIPSettingsDisplayTextColorName    NSLocalizedString(@"Text color", @"Text color")
#define kIPSettingsDisplayNavigationColorName NSLocalizedString(@"Navigation bar color", @"Navigation bar color")



////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface IPSettingsController ()

@property (nonatomic, retain) IPCustomAppearanceController *activeCustomBackgroundController;

//
//  This is set to 1 if we should hide the "email current photo" action.
//  0 otherwise.
//

@property (nonatomic, assign) NSUInteger actionHideEmailCurrentPhoto;

- (void)mailDeveloper;
- (void)rateApplication;
- (void)mailCurrentPhoto;
- (void)userGuide;
- (UITableViewCell *)cellForUserGuideInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)cellForActionsInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)cellForConnectInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)cellForInAppPurchasesInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)cellForDisplayInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;
- (NSDictionary *)titleFonts;
- (NSDictionary *)textFonts;

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPSettingsController

@synthesize userDefaults = userDefaults_;
@synthesize delegate = delegate_;
@synthesize activeCustomBackgroundController = activeCustomBackgroundController_;
@synthesize actionHideEmailCurrentPhoto = actionHideEmailCurrentPhoto_;

////////////////////////////////////////////////////////////////////////////////
//
//  Initialize.
//

- (id)init {
  
  self = [super initWithStyle:UITableViewStyleGrouped];
  if (self != nil) {
    self.title = @"Settings";
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release any retained properties.

- (void)dealloc {

  [activeCustomBackgroundController_ release];
  [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Delete any cached objects.
//

- (void)didReceiveMemoryWarning {

  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

////////////////////////////////////////////////////////////////////////////////
//
//  Determine if we should hide the current photo.
//

- (void)viewDidLoad {
  
  if ([self.delegate ipSettingsShouldMailCurrentPhoto]) {
    
    self.actionHideEmailCurrentPhoto = 0;
    
  } else {
    
    self.actionHideEmailCurrentPhoto = 1;
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  When we appear, see if we've got an active custom background controller.
//  If we do, read the selected background string... we'll have a new 
//  background.
//

- (void)viewDidAppear:(BOOL)animated {

  //
  //  Actually, always reload data... so many things can change b/c of subviews.
  //
  
  _GTMDevLog(@"%s -- reloading data", __PRETTY_FUNCTION__);
  [self.tableView reloadData];
  if (self.activeCustomBackgroundController != nil) {
    
    self.activeCustomBackgroundController = nil;
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  We support all orientations.
//

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

  // Return YES for supported orientations
  return YES;
}

#pragma mark - Properties

////////////////////////////////////////////////////////////////////////////////
//
//  Lazy initializer for user defaults
//

- (IPUserDefaults *)userDefaults {
  
  if (userDefaults_ == nil) {
    
    userDefaults_ = [[IPUserDefaults defaultSettings] retain];
  }
  return userDefaults_;
}

#pragma mark - Table view data source

////////////////////////////////////////////////////////////////////////////////
//
//  The number of sections...
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

  return IPSettingsControllerNumSections;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Get the section title.
//

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  
  switch (section) {
      
    case IPSettingsControllerUserGuide:
      return kIPSettingsUserGuide;
      
    case IPSettingsControllerActions:
      return kIPSettingsActionsTitle;
      
    case IPSettingsControllerInAppPurchases:
      return kIPSettingsInAppPurchasesTitle;
      
    case IPSettingsControllerDisplay:
      return kIPSettingsDisplayTitle;
      
#ifdef PHOLIO_FLICKR_API_KEY
    case IPSettingsControllerConnect:
      return kIPSettingsConnectTitle;
#endif
      
    default:
      _GTMDevAssert(NO, @"Unrecognized section");
      return @"Unknown";
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  Calculate the number of rows in each section.
//

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

  switch (section) {
    case IPSettingsControllerUserGuide:
      return IPSettingsUserGuideNumItems;
      
    case IPSettingsControllerActions:
      return IPSettingsActionNumActions;
      
    case IPSettingsControllerInAppPurchases:
      return IPSettingsInAppPurchasesNumActions;
      
    case IPSettingsControllerDisplay:
      return IPSettingsDisplayNumItems;
      
#ifdef PHOLIO_FLICKR_API_KEY
    case IPSettingsControllerConnect:
      return IPSettingsConnectNumItems;
#endif
      
    default:
      _GTMDevAssert(NO, @"Should not get here");
      break;
  }
  return 0;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Gets the requested cell...
//

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  enum IPSettingsControllerSections section = [indexPath section];
  
  IPButtonCell *cell = nil;
  
  switch (section) {
    case IPSettingsControllerUserGuide:
      return [self cellForUserGuideInTableView:tableView atIndexPath:indexPath];
      
    case IPSettingsControllerActions:
      return [self cellForActionsInTableView:tableView atIndexPath:indexPath];
      
#ifdef PHOLIO_FLICKR_API_KEY
    case IPSettingsControllerConnect:
      return [self cellForConnectInTableView:tableView atIndexPath:indexPath];
#endif
      
    case IPSettingsControllerInAppPurchases:
      return [self cellForInAppPurchasesInTableView:tableView atIndexPath:indexPath];
      
    case IPSettingsControllerDisplay:
      return [self cellForDisplayInTableView:tableView atIndexPath:indexPath];
      
    default:
      _GTMDevAssert(NO, @"Unrecognized section");
      break;
  }
  return cell;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Gets the "launch user guide" cell.
//

- (UITableViewCell *)cellForUserGuideInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {

  IPButtonCell *cell = [IPButtonCell cellForTableView:tableView];
  cell.title = kUserGuide;
  cell.target = self;
  cell.action = @selector(userGuide);

  return cell;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Gets a cell for the "Actions" section of the settings.
//

- (UITableViewCell *)cellForActionsInTableView:(UITableView *)tableView 
                                   atIndexPath:(NSIndexPath *)indexPath {
  
  enum IPSettingsDisplay row = [indexPath row];
  IPButtonCell *cell = [IPButtonCell cellForTableView:tableView];
  switch (row) {
    case IPSettingsActionEmailPhoto:
      cell.title = @"Email photo";
      cell.target = self;
      cell.action = @selector(mailCurrentPhoto);
      break;
      
    case IPSettingsActionContactDeveloper:
      cell.title = @"Contact developer";
      cell.target = self;
      cell.action = @selector(mailDeveloper);
      break;
      
    case IPSettingsActionRateApplication:
      cell.title = @"Rate application";
      cell.target = self;
      cell.action = @selector(rateApplication);
      break;
      
    default:
      _GTMDevAssert(NO, @"Unrecognized action");
      break;
  }
  return cell;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Gets cells for the "Connect" section.
//

- (UITableViewCell *)cellForConnectInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
  
  IPFlickrConnectionCell *cell = [IPFlickrConnectionCell cellForTableView:tableView];
  [cell configureCell];
  return cell;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Gets a cell for the "In App Purchases" section of the settings.
//

- (UITableViewCell *)cellForInAppPurchasesInTableView:(UITableView *)tableView 
                                          atIndexPath:(NSIndexPath *)indexPath {
  
  enum IPSettingsInAppPurchases row = [indexPath row];
  IPButtonCell *cell = [IPButtonCell cellForTableView:tableView];
  switch (row) {
      
    case IPSettingsInAppPurchasesRecoverPurchases:
      cell.title = @"Recover purchases";
      break;
      
    default:
      _GTMDevAssert(NO, @"Unrecognized action for in-app purchases");
      break;
  }
  return cell;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Cells for the "Display" section of settings.
//

- (UITableViewCell *)cellForDisplayInTableView:(UITableView *)tableView 
                                   atIndexPath:(NSIndexPath *)indexPath {

  switch (indexPath.row) {
    case IPSettingsDisplayCustomBackground:
    {
      IPCustomBackgroundCell *cell = [IPCustomBackgroundCell cellForTableView:tableView];
      cell.imageName = [self.delegate ipSettingsBackgroundImageName];
      cell.title = @"Background";
      cell.disclosureIndicator = YES;
      return cell;
    }
      
    case IPSettingsDisplayTitleFont:
    {
      IPFontPickerCell *cell = [IPFontPickerCell cellForTableView:tableView];
      cell.title = kIPSettingsDisplayTitleFontName;
      NSString *family = [self.delegate ipSettingsTitleFontFamily];
      UIFont *font = [UIFont fontWithName:family size:[UIFont systemFontSize]];
      cell.selectedFont = font;
      return cell;
    }
      
    case IPSettingsDisplayGridFont:
    {
      IPFontPickerCell *cell = [IPFontPickerCell cellForTableView:tableView];
      cell.title = kIPSettingsDisplayGridFontName;
      NSString *family = [self.delegate ipSettingsTextFontFamily];
      UIFont *font = [UIFont fontWithName:family size:[UIFont systemFontSize]];
      cell.selectedFont = font;
      return cell;
    }
      
    case IPSettingsDisplayTextColor:
    {
      IPColorCell *cell = [IPColorCell cellForTableView:tableView];
      cell.title = kIPSettingsDisplayTextColorName;
      cell.color = [self.delegate ipSettingsGridTextColor];
      return cell;
    }
      
    case IPSettingsDisplayNavigationColor:
    {
      IPColorCell *cell = [IPColorCell cellForTableView:tableView];
      cell.title = kIPSettingsDisplayNavigationColorName;
      cell.color = [self.delegate ipSettingsNavigationColor];
      return cell;
    }
      
  }
  return nil;
}


#pragma mark - Table view delegate

////////////////////////////////////////////////////////////////////////////////
//
//  Handle cell selection.
//

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

  UITableViewCell *tableViewCell = [tableView cellForRowAtIndexPath:indexPath];
  
  if ([tableViewCell isKindOfClass:[IPCustomBackgroundCell class]]) {

    //
    //  We're looking at an IPCustomBackgroundCell. The proper action is to
    //  navigate to a subcontroller.
    //
    
    IPCustomBackgroundCell *cell = (IPCustomBackgroundCell *)[tableView cellForRowAtIndexPath:indexPath];
    self.activeCustomBackgroundController = [[[IPCustomAppearanceController alloc] init] autorelease];
    self.activeCustomBackgroundController.selectedImageName = cell.imageName;
    
    //
    //  Nota Bene: We set the delegate *after* setting |selectedImageName|. That way
    //  our delegate doesn't get notified of its own change; we'll only see user changes.
    //
    
    self.activeCustomBackgroundController.delegate = self.delegate;
    [self.navigationController pushViewController:self.activeCustomBackgroundController 
                                         animated:YES];
    
  } else if ([tableViewCell isKindOfClass:[IPButtonCell class]]) {
    
    //
    //  This is a button. Invoke the corresponding action.
    //

    [tableViewCell setSelected:NO animated:NO];
    IPButtonCell *button = (IPButtonCell *)tableViewCell;
    [button.target performSelector:button.action];
    
  } else if ([tableViewCell isKindOfClass:[IPFlickrConnectionCell class]]) {
    
    IPFlickrLoginController *loginController = [[[IPFlickrLoginController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
    [self.navigationController pushViewController:loginController animated:YES];
    
  } else if ([tableViewCell isKindOfClass:[IPFontPickerCell class]]) {
    
    BDFontPickerController *fontController = [[[BDFontPickerController alloc] init] autorelease];
    fontController.title = ((IPFontPickerCell *)tableViewCell).title;
    fontController.fontFamilyName = [((IPFontPickerCell *)tableViewCell).selectedFont familyName];
    fontController.delegate = self;
    
    if ([fontController.title isEqualToString:kIPSettingsDisplayTitleFontName]) {
      
      fontController.fontFamilyToFont = [self titleFonts];
      
    } else if ([fontController.title isEqualToString:kIPSettingsDisplayGridFontName]) {
      
      fontController.fontFamilyToFont = [self textFonts];
    }
    [self.navigationController pushViewController:fontController animated:YES];
    
  } else if ([tableViewCell isKindOfClass:[IPColorCell class]]) {
    
    BDColorPicker *colorPicker = [[[BDColorPicker alloc] init] autorelease];
    colorPicker.delegate = self;
    IPColorCell *colorCell = (IPColorCell *)tableViewCell;
    colorPicker.title = colorCell.title;
    colorPicker.currentColor = colorCell.color;
    [self.navigationController pushViewController:colorPicker animated:YES];
  }
}

#pragma mark - BDFontPickerControllerDelegate

////////////////////////////////////////////////////////////////////////////////
//
//  Font changed.
//

- (void)fontPickerController:(BDFontPickerController *)controller 
       didPickFontFamilyName:(NSString *)fontFamilyName {

  if ([controller.title isEqualToString:kIPSettingsDisplayTitleFontName]) {
    
    [self.delegate ipSettingsDidSetTitleFontFamily:fontFamilyName];
    
  } else if ([controller.title isEqualToString:kIPSettingsDisplayGridFontName]) {
    
    [self.delegate ipSettingsDidSetTextFontFamily:fontFamilyName];
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  The title fonts.
//

- (NSDictionary *)titleFonts {
  
  return [NSDictionary dictionaryWithObjectsAndKeys:
          @"Helvetica-Bold", @"Helvetica",
          @"Futura-Medium", @"Futura",
          @"GillSans-Bold", @"Gill Sans",
          @"Baskerville-Bold", @"Baskerville",
          @"AmericanTypewriter-Bold", @"American Typewriter",
          @"Arial-BoldMT", @"Arial",
          @"BodoniSvtyTwoOSITCTT-Bold", @"Bodoni 72 Oldstyle",
          @"BodoniSvtyTwoSCITCTT-Book", @"Bodoni 72 Smallcaps",
          @"CourierNewPS-BoldMT", @"Courier New",
          @"Georgia-Bold", @"Georgia",
          @"HoeflerText-Black", @"Hoefler Text",
          @"Optima-Bold", @"Optima",
          @"Palatino-Bold", @"Palatino",
          @"Papyrus", @"Papyrus",
          @"Verdana-Bold", @"Verdana",
          nil];
}

////////////////////////////////////////////////////////////////////////////////
//
//  The text fonts.
//

- (NSDictionary *)textFonts {
  
  return [NSDictionary dictionaryWithObjectsAndKeys:
          @"AmericanTypewriter", @"American Typewriter",
          @"ArialMT", @"Arial",
          @"Baskerville", @"Baskerville",
          @"BodoniSvtyTwoOSITCTT-Book", @"Bodoni 72 Oldstyle",
          @"BodoniSvtyTwoSCITCTT-Book", @"Bodoni 72 Smallcaps",
          @"CourierNewPSMT", @"Courier New",
          @"Futura-Medium", @"Futura",
          @"Georgia", @"Georgia",
          @"GillSans", @"Gill Sans",
          @"Helvetica", @"Helvetica",
          @"HoeflerText-Regular", @"Hoefler Text",
          @"Optima-Regular", @"Optima",
          @"Palatino-Roman", @"Palatino",
          @"Papyrus", @"Papyrus",
          @"Verdana", @"Verdana",
          nil];
}

#pragma mark - Email actions

////////////////////////////////////////////////////////////////////////////////
//
//  Handle mailing the developer.
//

- (IBAction)mailDeveloper {
  
  [self.delegate ipSettingsMailDeveloper];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Let the user rate the application.
//

- (IBAction)rateApplication {
  
  self.userDefaults.lastRatedVersion = kAppRatingVersion;
  self.userDefaults.lastTimeAskedToRate = [NSDate date];
  self.userDefaults.numberOfTimesAskedToRate = 0;
  
  NSURL *url = [NSURL URLWithString:APP_URL];
  [[UIApplication sharedApplication] openURL:url];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Mail the current photo.
//

- (void)mailCurrentPhoto {
  
  [self.delegate ipSettingsMailCurrentPhoto];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Show the user guide.
//

- (void)userGuide {

  [self.delegate ipSettingsShowUserGuide];
}

#pragma mark - BDColorPickerDelegate

////////////////////////////////////////////////////////////////////////////////
//
//  Handle a change in color.
//

- (void)colorPicker:(BDColorPicker *)colorPicker didPickColor:(UIColor *)color {
  
  if ([colorPicker.title isEqualToString:kIPSettingsDisplayTextColorName]) {
    
    [self.delegate ipSettingsSetGridTextColor:color];
    
  } else if ([colorPicker.title isEqualToString:kIPSettingsDisplayNavigationColorName]) {
    
    [self.delegate ipSettingsSetNavigationColor:color];
  }
}



@end
