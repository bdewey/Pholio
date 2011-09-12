//
//  IPStrings.h
//  ipad-portfolio
//
//  Contains all strings (and other constants) that show up in the UI.
//
//  Created by Brian Dewey on 4/11/11.
//  Copyright 2011 Brian Dewey. All rights reserved.
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

#define kBrandingFilename   @"branding.png"
#define kBackgroundFilename @"background.jpg"

//
//  Constants for application rating.
//

#define kAppRatingVersion        1
#define kMaxAsksPerVersion       3
#define kMinIntervalBetweenAsks  (24.0 * 60.0 * 60.0)
#define APP_URL @"http://itunes.apple.com/us/app/pholio/id391163241?mt=8"

#define kOKString           NSLocalizedString(@"OK", @"OK")
#define kCancelString       NSLocalizedString(@"Cancel", @"Cancel")
#define kDeleteString       NSLocalizedString(@"Delete", @"Delete")
#define kBackString         NSLocalizedString(@"Back", @"Back")

#define kConfirmDelete      NSLocalizedString(@"Are you sure you want to delete %@?", @"Confirm Delete")
#define kConfirmDeleteSetNoTitle  NSLocalizedString(@"Are you sure you want to delete this gallery?", @"Confirm set delete no title")
#define kConfirmDeletePageNoTitle NSLocalizedString(@"Are you sure you want to delete this picture?", @"Confirm page delete no title")

#define kProductName        NSLocalizedString(@"Pholio", @"Product Name")
#define kNewGalleryName     NSLocalizedString(@"Untitled Gallery", @"New gallery name")
#define kWelcomeGalleryName NSLocalizedString(@"Welcome!", @"Welcome Gallery")
#define kFoundPicturesGalleryName NSLocalizedString(@"New Pictures", @"Found pictures gallery name")
#define kNewImageTitle      NSLocalizedString(@"Untitled", @"New image title")
#define kBackButtonText     NSLocalizedString(@"Back", @"Back")
#define kPhotoAlbums        NSLocalizedString(@"Photo Albums", @"Photo Albums")
#define kCustomBackground   NSLocalizedString(@"Custom Background", @"Custom Background")

#define kUserGuide          NSLocalizedString(@"Getting Started", @"User Guide title")

//
//  Flickr strings
//

#define kFlickr                 NSLocalizedString(@"Flickr", @"Flickr")
#define kFlickrNotConnected     NSLocalizedString(@"Not Connected", @"Not connected to flickr")
#define kFlickrConnectToFlickr  NSLocalizedString(@"Connect to Flickr", @"Connect to Flickr")
#define kFlickrSets             NSLocalizedString(@"Sets", @"Sets")
#define kFlickrLoading          NSLocalizedString(@"Loading...", @"Loading")

//
//  DropBox strings
//

#define kDropBox                NSLocalizedString(@"DropBox", @"DropBox")

//
//  Action menu text
//

#define kActionEmailPhoto       NSLocalizedString(@"Email photo", @"Email photo")
#define kActionContactDeveloper NSLocalizedString(@"Contact developer", @"Contact developer")
#define kActionRateApplication  NSLocalizedString(@"Rate application", @"Rate application")
#define kActionRecoverPurchases NSLocalizedString(@"Recover purchases", @"Recover purchases")

//
//  Errors
//

#define kErrorTooManyGalleries  NSLocalizedString(@"You can have at most 3 galleries. You can purchase unlimited galleries from the Action button.", @"Too Many Galleries")
#define kErrorTooManyImages     NSLocalizedString(@"To have more than 10 pictures per gallery, you must purchase Unlimited Galleries.", @"Too Many Pictures")
#define kErrorPurchase          NSLocalizedString(@"There was an error completing your purchase.", @"Purchase error")
#define kErrorEmail             NSLocalizedString(@"This device is not yet configured for sending email.", @"Email error")
#define kErrorCutFailed         NSLocalizedString(@"Pholio does not have enough memory to complete the operation.", @"Cut error")
#define kErrorCopyFailed        NSLocalizedString(@"Pholio does not have enough memory to complete the operation.", @"Copy error")

//
//  Optimizing text
//

#define kOptimizationProgressPlural NSLocalizedString(@"Pholio is optimizing %d photos for your iPad.", @"Optimizing plural")
#define kOptimizationProgressSingular NSLocalizedString(@"Pholio is optimizing a photo for your iPad.", @"Optomizing singular")

//
//  Location service checks
//

#define kLocationServiceDenied   NSLocalizedString(@"You give Pholio access to your current location so it can access your pictures, which have location information. You give Pholio access through Settings -> Location Services.", @"Location Denied")
#define kLocationServiceNotDetermined NSLocalizedString(@"Pholio needs access to your location to read your pictures, which have location information.", @"Location service not determined")

//
//  Different timings
//

#define kIPAnimationViewFade    (0.5)
#define kIPAnimationViewFadeFast (0.2)
#define kIPAnimationViewAppearFast (0.2)