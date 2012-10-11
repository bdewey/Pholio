//
//  IPSetPagingViewController.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 4/27/11.
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

#import <MessageUI/MessageUI.h>
#import "BDGridCell.h"
#import "BDPagingView.h"
#import "IPPortfolio.h"
#import "IPSetPagingViewController.h"
#import "IPAlert.h"
#import "IPPhotoScrollView.h"

@interface IPSetPagingViewController()

- (void)popView;
- (void)toggleNavigationBarVisible;

@end


@implementation IPSetPagingViewController

@synthesize currentSet = currentSet_;
@synthesize currentPageIndex = currentPageIndex_;
@synthesize backButtonText = backButtonText_;
@synthesize pagingView = pagingView_;

////////////////////////////////////////////////////////////////////////////////
//
//  Initializer.
//

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {

  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Dealloc.
//

- (void)dealloc {

  [currentSet_ release];
  [backButtonText_ release];
  [pagingView_ release];
  [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release whatever memory we can.
//

- (void)didReceiveMemoryWarning {

  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Properties

////////////////////////////////////////////////////////////////////////////////
//
//  Set the current set.
//

- (void)setCurrentSet:(IPSet *)currentSet {
  
  [currentSet_ autorelease];
  currentSet_ = [currentSet retain];
  
  self.portfolio = self.currentSet.parent;
  [self.pagingView setNeedsLayout];
  [self setBackgroundImageName:self.currentSet.parent.backgroundImageName];
}

////////////////////////////////////////////////////////////////////////////////
//
//  We let people mail the current photo from here.
//

- (BOOL)ipSettingsShouldMailCurrentPhoto {
  
  return YES;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Do the actual emailing.
//

- (void)ipSettingsMailCurrentPhoto {
  
  _GTMDevLog(@"%s", __PRETTY_FUNCTION__);
  Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
  if (mailClass != nil) {
    if ([mailClass canSendMail]) {
      MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
      picker.mailComposeDelegate = self;
      
      IPPage *thePage = [self.currentSet objectInPagesAtIndex:self.pagingView.currentPageIndex];
      IPPhoto *thePhoto = [thePage.photos objectAtIndex:0];
      
      //
      //  Get a good subject for the mail
      //
      
      NSString *portfolioName = self.currentSet.parent.title;
      if ([portfolioName length] == 0) {
        portfolioName = __PRODUCT_NAME__;
      }
      NSString *photoTitle = thePhoto.title;
      if ([photoTitle length] == 0) {
        photoTitle = kNewImageTitle;
      }
      NSString *subject = [NSString stringWithFormat:@"%@: \"%@\"", portfolioName, photoTitle, nil];
      [picker setSubject:subject];
      
      //
      //  Add the image.
      //
      
      NSData *photoData = [NSData dataWithContentsOfFile:thePhoto.filename];
      [picker addAttachmentData:photoData mimeType:@"image/jpeg" fileName:@"photo.jpg"];
      
      [self presentModalViewController:picker animated:YES];
      [picker release];
      
    } else {
      
      [self.alertManager showErrorMessage:@"This device is not configured for sending email."];
    }
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  Lazy initializer.
//

- (NSString *)backButtonText {
  
  if (backButtonText_ == nil) {
    
    backButtonText_ = [[NSString alloc] initWithString:kBackButtonText];
  }
  return backButtonText_;
}

#pragma mark - View lifecycle

////////////////////////////////////////////////////////////////////////////////
//
//  Any custom initialization after loading...
//

- (void)viewDidLoad {

  [super viewDidLoad];

  self.pagingView.pagingViewDelegate = self;
  self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:self.backButtonText 
                                                                            style:UIBarButtonItemStyleBordered 
                                                                           target:self 
                                                                           action:@selector(popView)] autorelease];

  
  //
  //  On tap, toggle visibility of navigation bar.
  //
  
  UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                         action:@selector(toggleNavigationBarVisible)] autorelease];
  [self.view addGestureRecognizer:tap];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Set the scroll offset to whatever is required to be showing the page at
//  |currentPageIndex|, then fade in |pagingView|.
//

- (void)viewDidAppear:(BOOL)animated {

  [super viewDidAppear:animated];
  [self.pagingView tileSubviews];
  self.navigationController.navigationBar.translucent = YES;
  self.pagingView.currentPageIndex = self.currentPageIndex;
  self.pagingView.alpha = 0;
  [UIView animateWithDuration:kIPAnimationViewFade animations:^(void) {
    
    self.pagingView.alpha = 1;
  }];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Pop this view from the navigation stack.
//

- (void)popView {
  
  [UIView animateWithDuration:kIPAnimationViewFadeFast animations:^(void) {
    
    self.pagingView.alpha = 0;
    
  } completion:^(BOOL finished) {

    [self.navigationController popViewControllerAnimated:NO];
  }];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Toggles the visibility of the navigation bar.
//

- (void)toggleNavigationBarVisible {
  
  [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden
                                           animated:YES];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release retained subviews.
//

- (void)viewDidUnload {

  [super viewDidUnload];
  
  self.pagingView = nil;
  self.titleTextField = nil;
}

////////////////////////////////////////////////////////////////////////////////
//
//  We support all orientations.
//

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

  // Return YES for supported orientations
  return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)shouldAutorotate {
  
  return YES;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Prior to rotation, note the page we are on.
//

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                duration:(NSTimeInterval)duration {
  
  self.currentPageIndex = self.pagingView.currentPageIndex;
}

////////////////////////////////////////////////////////////////////////////////
//
//  After rotation, re-set the page index to make sure we've scrolled to that
//  position.
//

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
  
  [self.pagingView recomputeContentSize];
  [self.pagingView setCurrentPageIndex:self.currentPageIndex animated:NO];
}

#pragma mark - BDPagingViewDelegate

////////////////////////////////////////////////////////////////////////////////
//
//  Number of pages...
//

- (NSUInteger)pagingViewCountOfPages:(BDPagingView *)pagingView {
  
  return [self.currentSet countOfPages];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Gets a page.
//

- (UIView *)pagingView:(BDPagingView *)pagingView pageAtIndex:(NSUInteger)index {
  
  IPPage *page = [self.currentSet objectInPagesAtIndex:index];
  IPPhoto *photo = [page objectInPhotosAtIndex:0];

  IPPhotoScrollView *cell;
  if ((cell = (IPPhotoScrollView *)[pagingView dequeueView]) == nil) {
    
    cell = [[[IPPhotoScrollView alloc] initWithFrame:CGRectZero] autorelease];
//    cell.contentMode = UIViewContentModeScaleAspectFit;
  }
  cell.photo = photo;
  return cell;
}

////////////////////////////////////////////////////////////////////////////////
//
//  The user moved to a page. Update the navigation title.
//

- (void)pagingView:(BDPagingView *)pagingView didMoveToPage:(NSUInteger)index {
  
  IPPage *page = [self.currentSet objectInPagesAtIndex:index];
  NSString *title = [page valueForKeyPath:kIPPhotoTitle
                                 forPhoto:0];
  if ([title length] > 0) {
    
    self.titleTextField.text = title;
    
  } else {
    
    //
    //  Handle blank image title.
    //
    
    NSString *title = [NSString stringWithFormat:@"%d of %d",
                       (index + 1),
                       [self.currentSet countOfPages]];
    self.titleTextField.text = title;
  }
}

#pragma mark - UITextFieldDelegate

////////////////////////////////////////////////////////////////////////////////
//
//  When done editing, save the title.
//

- (void)textFieldDidEndEditing:(UITextField *)textField {
  
  IPPage *page = [self.currentSet objectInPagesAtIndex:self.pagingView.currentPageIndex];
  [page setValue:textField.text forKeyPath:kIPPhotoTitle forPhoto:0];
  [self.currentSet.parent savePortfolioToPath:[IPPortfolio defaultPortfolioPath]];
}

@end
