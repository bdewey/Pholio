//
//  BDImagePickerController.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 5/6/11.
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

#import "BDImagePickerController.h"
#import "BDAssetsLibraryController.h"
#import "IPFlickrAuthorizationManager.h"
#import "IPFlickrSetPickerController.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface BDImagePickerController ()

//
//  Invoked when the user picks images.
//

@property (nonatomic, copy) BDImagePickerControllerImageBlock imageBlock;

//
//  Invoked when the user cancels.
//

@property (nonatomic, copy) BDImagePickerControllerCancelBlock cancelBlock;

//
//  The popover we're shown in.
//

@property (nonatomic, assign) UIPopoverController *popover;

//
//  Creates an assets library controller wrapped in a UINavigationController.
//

- (UINavigationController *)assetsLibraryController;

//
//  Creates a |IPFlickrSetPickerController| wrapped in a UINavigationController.
//

- (UINavigationController *)flickrController;

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


@implementation BDImagePickerController

@synthesize delegate = delegate_;
@synthesize imageBlock = imageBlock_;
@synthesize cancelBlock = cancelBlock_;
@synthesize popover = popover_;

////////////////////////////////////////////////////////////////////////////////
//
//  Initializer.
//

- (id)init {
  
  self = [super init];
  return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Creates an assets library controller wrapped in a UINavigationController.
//

- (UINavigationController *)assetsLibraryController {
  
  BDAssetsLibraryController *libraryController = [[[BDAssetsLibraryController alloc] init] autorelease];
  UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:libraryController] autorelease];
  nav.navigationBar.barStyle = UIBarStyleBlack;
  libraryController.delegate = self;
  return nav;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Creates an |IPFlickrSetPickerController| wrapped in a |UINavigationController|.
//

- (UINavigationController *)flickrController {
  
  IPFlickrSetPickerController *controller = [[[IPFlickrSetPickerController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
  controller.delegate = self;
  UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
  nav.navigationBar.barStyle = UIBarStyleBlack;
  return nav;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release any retained properties.
//

- (void)dealloc {

  [imageBlock_ release], imageBlock_ = nil;
  [cancelBlock_ release], cancelBlock_ = nil;
  [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Convenience constructor. This is how I expect things to get used.
//

+ (UIPopoverController *)presentPopoverFromRect:(CGRect)rect 
                                         inView:(UIView *)view 
                                    onSelection:(BDImagePickerControllerImageBlock)imageBlock {

  BDImagePickerController *controller = [[[BDImagePickerController alloc] init] autorelease];
  controller.imageBlock = imageBlock;
  UIViewController *picker;
  IPFlickrAuthorizationManager *authManager = [IPFlickrAuthorizationManager sharedManager];
  
  if (authManager.authToken == nil) {
    
    picker = [controller assetsLibraryController];
    
  } else {
    
    UITabBarController *tab = [[[UITabBarController alloc] init] autorelease];
    [tab setViewControllers:[NSArray arrayWithObjects:[controller assetsLibraryController],
                             [controller flickrController],
                             nil]];
    picker = tab;
  }
  UIPopoverController *popover = [[[UIPopoverController alloc] initWithContentViewController:picker] autorelease];
  controller.popover = popover;
  [popover presentPopoverFromRect:rect inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
  return popover;
}

#pragma mark - BDAssetsLibraryControllerDelegate

////////////////////////////////////////////////////////////////////////////////
//
//  Handle cancel.
//

- (void)bdImagePickerControllerDidCancel {
  
  if (self.cancelBlock != nil) {
    self.cancelBlock();
  }
  [self.delegate bdImagePickerControllerDidCancel];
  [self.popover dismissPopoverAnimated:YES];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Handle images.
//

- (void)bdImagePickerDidPickImages:(NSArray *)images {
 
  if (self.imageBlock != nil) {

    self.imageBlock(images);
  }
  [self.delegate bdImagePickerDidPickImages:images];
  [self.popover dismissPopoverAnimated:YES];
}

@end
