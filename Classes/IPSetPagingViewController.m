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
#import "IPPortfolio.h"
#import "IPSetPagingViewController.h"
#import "IPAlert.h"
#import "IPPhotoScrollView.h"
#import "IPPhotoScrollViewCell.h"

static NSString * const FBPhotoCellIdentifier = @"FBPhotoCellIdentifier";

@interface IPSetPagingViewController()

- (void)popView;
- (void)toggleNavigationBarVisible;

@end


@implementation IPSetPagingViewController
{
  NSUInteger _pageIndexBeforeRotation;
  UICollectionViewFlowLayout *_layout;
}

#pragma mark - Properties

////////////////////////////////////////////////////////////////////////////////
//
//  Set the current set.
//

- (void)setCurrentSet:(IPSet *)currentSet {
  
  if (_currentSet == currentSet) {
    return;
  }
  _currentSet = currentSet;
  
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
  
  DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
  Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
  if (mailClass != nil) {
    if ([mailClass canSendMail]) {
      MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
      picker.mailComposeDelegate = self;
      
      IPPage *thePage = [self.currentSet objectInPagesAtIndex:self.currentPageIndex];
      IPPhoto *thePhoto = (thePage.photos)[0];
      
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
  
  if (_backButtonText == nil) {
    
    _backButtonText = [[NSString alloc] initWithString:kBackButtonText];
  }
  return _backButtonText;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setCurrentPageIndex:(NSUInteger)currentPageIndex
{
  [self setCurrentPageIndex:currentPageIndex animated:NO];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setCurrentPageIndex:(NSUInteger)currentPageIndex animated:(BOOL)animated
{
  if (_currentPageIndex == currentPageIndex) {
    return;
  }
  _currentPageIndex = currentPageIndex;
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentPageIndex inSection:0];
  [_pagingView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop | UICollectionViewScrollPositionLeft animated:animated];
}

#pragma mark - View lifecycle

////////////////////////////////////////////////////////////////////////////////
//
//  Any custom initialization after loading...
//

- (void)viewDidLoad {

  [super viewDidLoad];

  _layout = [[UICollectionViewFlowLayout alloc] init];
  _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
  _layout.itemSize = self.view.bounds.size;
  _layout.minimumInteritemSpacing = 0;
  _layout.minimumLineSpacing = 0;
  
  _pagingView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:_layout];
  _pagingView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  _pagingView.pagingEnabled = YES;
  _pagingView.dataSource = self;
  [_pagingView registerClass:[IPPhotoScrollViewCell class] forCellWithReuseIdentifier:FBPhotoCellIdentifier];
  
  [self.view addSubview:_pagingView];
  
  // HACK -- Force the setter logic to work, which will position the scroll view
  [_pagingView layoutIfNeeded];
  NSUInteger tempPage = _currentPageIndex;
  _currentPageIndex = NSNotFound;
  [self setCurrentPageIndex:tempPage animated:NO];
  
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.backButtonText
                                                                            style:UIBarButtonItemStyleBordered 
                                                                           target:self 
                                                                           action:@selector(popView)];

  
  //
  //  On tap, toggle visibility of navigation bar.
  //
  
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                         action:@selector(toggleNavigationBarVisible)];
  [self.view addGestureRecognizer:tap];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Set the scroll offset to whatever is required to be showing the page at
//  |currentPageIndex|, then fade in |pagingView|.
//

- (void)viewDidAppear:(BOOL)animated {

  [super viewDidAppear:animated];
  self.navigationController.navigationBar.translucent = YES;
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
  
  _pageIndexBeforeRotation = self.currentPageIndex;
}

////////////////////////////////////////////////////////////////////////////////
//
//  After rotation, re-set the page index to make sure we've scrolled to that
//  position.
//

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
  
  _layout.itemSize = self.view.bounds.size;
  [_layout invalidateLayout];
  [_pagingView setNeedsLayout];
  [_pagingView layoutIfNeeded];
  _currentPageIndex = NSNotFound;
  [self setCurrentPageIndex:_pageIndexBeforeRotation animated:NO];
}

#pragma mark - UICollectionViewDataSource

////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
  return 1;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  return [self.currentSet countOfPages];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  NSUInteger index = indexPath.row;
  IPPage *page = [self.currentSet objectInPagesAtIndex:index];
  IPPhoto *photo = [page objectInPhotosAtIndex:0];

  IPPhotoScrollViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:FBPhotoCellIdentifier forIndexPath:indexPath];
  cell.photoScrollView.photo = photo;
  return cell;
}

////////////////////////////////////////////////////////////////////////////////
//
//  The user moved to a page. Update the navigation title.
//

- (void)_updateNavigationTitleForPageIndex:(NSUInteger) index {
  
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

#pragma mark - UICollectionViewDelegate

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  NSIndexPath *indexPath = [_pagingView indexPathForItemAtPoint:_pagingView.contentOffset];
  NSAssert(indexPath.section == 0, @"Unexpected section in _pagingView: %d", indexPath.section);
  
  // don't go through the setter, because that would trigger more scrolling.
  _currentPageIndex = indexPath.row;
}

#pragma mark - UITextFieldDelegate

////////////////////////////////////////////////////////////////////////////////
//
//  When done editing, save the title.
//

- (void)textFieldDidEndEditing:(UITextField *)textField {
  
  IPPage *page = [self.currentSet objectInPagesAtIndex:self.currentPageIndex];
  [page setValue:textField.text forKeyPath:kIPPhotoTitle forPhoto:0];
  [self.currentSet.parent savePortfolioToPath:[IPPortfolio defaultPortfolioPath]];
}

@end
