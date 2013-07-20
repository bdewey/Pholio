//
//  IPPortfolioGridViewController.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 4/23/11.
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

#import <QuartzCore/QuartzCore.h>
#import "BDContrainPanGestureRecognizer.h"
#import "BDCustomAlert.h"
#import "BDGridCell.h"
#import "BDImagePickerController.h"
#import "IPAlert.h"
#import "IPPasteboardObject.h"
#import "IPPhoto.h"
#import "IPPhotoOptimizationManager.h"
#import "IPPortfolio.h"
#import "IPPortfolioGridViewController.h"
#import "IPSetGridViewController.h"
#import "IPSetPagingViewController.h"
#import "IPTutorialManager.h"
#import "IPUserDefaults.h"
#import "NSString+TestHelper.h"
#import "UIImage+Border.h"
#import "UIImage+Resize.h"

static NSString * const IPPortfolioCellIdentifier = @"IPPortfolioCellIdentifier";

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
//  This is a BDGridCell subclass that visualizes an IPSet.
//

@interface IPSetCell : BDGridCell {

}

//
//  This is the set associated with this cell.
//

@property (nonatomic, strong) IPSet *currentSet;

@end

@implementation IPSetCell

////////////////////////////////////////////////////////////////////////////////
//
//  Gets the composite image for the set -- a stack of the first five images of
//  the set.
//

- (UIImage *)compositeImage {
  
  //
  //  Bail out if there's nothing to composite.
  //
  
  if ([self.currentSet countOfPages] == 0) {
    
    return [UIImage imageNamed:@"Portfolio-72.png"];
  }
  
  UIView *compositeView = [[UIView alloc] initWithFrame:self.bounds];
  
  //
  //  Build a thumbnail from 5 images.
  //
  
  for (int i = 0; i < 5; i++) {
    
    if (i >= [self.currentSet countOfPages]) {
      break;
    }
    @autoreleasepool {
      IPPage *page = [self.currentSet objectInPagesAtIndex:i];
      IPPhoto *photo = [page objectInPhotosAtIndex:0];
      UIImage *bordered = [photo.thumbnail imageWithBorderWidth:10.0 andColor:[[UIColor whiteColor] CGColor]];
      bordered = [bordered imageWithBorderWidth:1.0 andColor:[[UIColor lightGrayColor] CGColor]];
      UIImageView *photoView = [[UIImageView alloc] initWithImage:bordered];
      CGAffineTransform transform = CGAffineTransformMakeRotation(i * 0.15);
      CGRect postTransformViewSize = CGRectApplyAffineTransform(photoView.frame, transform);
      CGFloat heightScale = compositeView.bounds.size.height / postTransformViewSize.size.height;
      CGFloat widthScale  = compositeView.bounds.size.width  / postTransformViewSize.size.width;
      CGFloat finalScale = MIN(heightScale, widthScale);
      transform = CGAffineTransformScale(transform, finalScale, finalScale);
      photoView.center = compositeView.center;
      photoView.transform = transform;
      photoView.contentMode = UIViewContentModeScaleAspectFit;
      [compositeView addSubview:photoView];
      [compositeView sendSubviewToBack:photoView];
    }
  }
  
  UIGraphicsBeginImageContextWithOptions(compositeView.frame.size, NO, 0);
  [compositeView.layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *compositeImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return compositeImage;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Does the compositing on a background thread, then calls a completion
//  routine with the composite image on the main thread.
//

- (void)compositeAsyncWithCompletion:(void(^)(UIImage *compositeImage))completion {
  
  completion = [completion copy];
  
  //
  //  ACK! Note that UIGraphicsBeginImageContextWithOptions must be called
  //  on the main thread. Compositing uses this function. Ergo, we'll do the
  //  operation async but we'll do it on the main queue.
  //
  
  [[NSOperationQueue mainQueue] addOperationWithBlock:^(void) {
    UIImage *composite = [self compositeImage];
    completion(composite);
  }];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Updates the thumbnail for this cell.
//

- (void)updateThumbnail {
  
  IPPage *page;
  if ([self.currentSet countOfPages] > 0) {
    
    page = [self.currentSet objectInPagesAtIndex:0];
    
  } else {
    
    page = nil;
  }
  IPPhoto *photo = [page objectInPhotosAtIndex:0];
  
  switch (self.style) {
    case BDGridCellStyleDefault: {
      [self compositeAsyncWithCompletion:^(UIImage *compositeImage) {
        self.image = compositeImage;
      }];
      break;
    }
      
    case BDGridCellStyleTile: {
      if (self.frame.size.width <= kThumbnailSize) {
        
        self.image = photo.thumbnail;
        
      } else {
        
        self.image = photo.image;
      }
      break;
    }
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  Looks at the size of the image and the size of the cell to determine if
//  we should update the thumbnail.
//

- (void)drawRect:(CGRect)rect {
  
  [self updateThumbnail];
  [super drawRect:rect];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Update the caption/image for the cell. Watch for changes to the set
//  thumbnail image.
//

- (void)setCurrentSet:(IPSet *)currentSet {

  if (_currentSet == currentSet) {
    return;
  }
  [_currentSet removeObserver:self forKeyPath:kIPSetTitle];
  [_currentSet removeObserver:self forKeyPath:kIPSetThumbnailFilename];
  
  _currentSet = currentSet;
  
  if (_currentSet != nil) {
    
    //
    //  Note that in |dealloc|, we set |currentSet| to nil. We therefore
    //  shouldn't do any of this extra work in the nil case, as |self| is
    //  about to go away. |updateThumbnail| is especially dangerous as it
    //  queues up work on another thread, and |self| will no longer be valid.
    //
    
    [self updateThumbnail];
    
    self.caption = _currentSet.title;
    [_currentSet addObserver:self forKeyPath:kIPSetTitle options:0 context:NULL];
    [_currentSet addObserver:self forKeyPath:kIPSetThumbnailFilename options:0 context:NULL];
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  Watch for significant changes to the underlying set.
//

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  
  [self updateThumbnail];
  self.caption = self.currentSet.title;
}

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface IPPortfolioGridViewController() <UICollectionViewDelegateFlowLayout>

//
//  The font we use for showing the header label. 
//

@property (weak, nonatomic, readonly) UIFont *headerFont;

@end

@implementation IPPortfolioGridViewController

////////////////////////////////////////////////////////////////////////////////
//
//  Deallocator.
//

- (void)dealloc {

  [self _stopObservingPortfolio:self.portfolio];
}

#pragma mark - View lifecycle

////////////////////////////////////////////////////////////////////////////////
//
//  Do post-view-loading initialization.
//

- (void)viewDidLoad {

  [super viewDidLoad];
  
  UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
  layout.itemSize = CGSizeMake(220, 240);
  _gridView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
  _gridView.dataSource = self;
  _gridView.delegate = self;
  [_gridView registerClass:[IPSetCell class] forCellWithReuseIdentifier:IPPortfolioCellIdentifier];
  
  [self setTitleToPortfolioTitle];
  UINavigationBar *navigationBar = self.navigationController.navigationBar;
  CGRect navBarFrameInWindow = [navigationBar convertRect:navigationBar.bounds toView:nil];
  UIEdgeInsets insets = UIEdgeInsetsMake(8 + CGRectGetMaxY(navBarFrameInWindow), 8, 8, 8);
  _gridView.contentInset = insets;

  
  UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeDown)];
  swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
  swipeDown.numberOfTouchesRequired = 2;
  [_gridView addGestureRecognizer:swipeDown];
  
  UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeUp)];
  swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
  swipeUp.numberOfTouchesRequired = 2;
  [_gridView addGestureRecognizer:swipeUp];
  
  [self.view addSubview:_gridView];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Clean up when the view is unloaded. Release any retained subviews.
//

- (void)viewDidUnload {

  [super viewDidUnload];
  
  self.gridView = nil;
}

////////////////////////////////////////////////////////////////////////////////

- (void)viewWillAppear:(BOOL)animated {

  [super viewWillAppear:animated];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Always do a fade-in transition, to help from popping in from the stack.
//

- (void)viewDidAppear:(BOOL)animated {
  
  [super viewDidAppear:animated];
  
  //
  //  If we need to show a tutorial, do so.
  //
  
  if (self.tutorialManager.state == IPTutorialManagerStateWelcome) {
    
    [self startTutorial];
  }
  self.gridView.alpha = 0;
  [UIView animateWithDuration:0.2 animations:^(void) {
    self.gridView.alpha = 1;
  }];
  
  //
  //  See if we should ask the user to rate the application.
  //
  
  NSDate *lastTimeAsked = [self.userDefaults lastTimeAskedToRate];
  if ([lastTimeAsked timeIntervalSince1970] < 10) {
    
    lastTimeAsked = [NSDate date];
    self.userDefaults.lastTimeAskedToRate = lastTimeAsked;
  }
  NSTimeInterval timeSinceLastAsk = [[NSDate date] timeIntervalSinceDate:lastTimeAsked];
  if (([self.userDefaults lastRatedVersion] < kAppRatingVersion) &&
      (timeSinceLastAsk >= kMinIntervalBetweenAsks) &&
      (self.userDefaults.numberOfTimesAskedToRate < kMaxAsksPerVersion)) {
    
    //
    //  The user should have a chance to rate the app.
    //
    
    self.userDefaults.lastTimeAskedToRate = [NSDate date];
    self.userDefaults.numberOfTimesAskedToRate += 1;
    
    [BDCustomAlert showWithTitle:@"Rate Pholio" 
                         message:@"5 star ratings help fund updates. Rate now?" 
                     cancelTitle:@"Maybe later" 
                     cancelBlock:nil 
                      otherTitle:@"Rate now" 
                      otherBlock:^(void) {
                        
                        self.userDefaults.lastRatedVersion = kAppRatingVersion;
                        self.userDefaults.numberOfTimesAskedToRate = 0;
                        NSURL *url = [NSURL URLWithString:APP_URL];
                        [[UIApplication sharedApplication] openURL:url];
                      }
     ];
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  We support all interface orientations.
//

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

  return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)shouldAutorotate {
    
  return YES;
}

#pragma mark - Swiping

////////////////////////////////////////////////////////////////////////////////
//
//  Handle a down swipe by showing the navigation bar.
//

- (void)didSwipeDown {
  
  [self.navigationController setNavigationBarHidden:NO animated:YES];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Handle an up swipe by hiding the navigation bar.
//

- (void)didSwipeUp {
  
  [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark -
#pragma mark Properties

////////////////////////////////////////////////////////////////////////////////
//
//  Sets the view title to the portfolio title.
//

- (void)setTitleToPortfolioTitle {
  
  if ((self.portfolio.title != nil) && ![@"" isEqualToString:self.portfolio.title]) {
    self.titleTextField.text = self.portfolio.title;
  } else {
    self.titleTextField.text = kProductName;
  }
  DDLogVerbose(@"%s -- titleTextField is %@",
             __PRETTY_FUNCTION__,
             self.titleTextField.text);
}

////////////////////////////////////////////////////////////////////////////////
//
//  Gets the header font. This is a larger version of the font stored in
//  |self.portfolio|.
//

- (UIFont *)headerFont {
  
  return [UIFont fontWithName:self.portfolio.titleFont.fontName size:36.0];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Stop observing changes to _portfolio
//

- (void)_stopObservingPortfolio:(IPPortfolio *)portfolio {
  
  [portfolio removeObserver:self forKeyPath:kIPPortfolioBackgroundImageName];
  [portfolio removeObserver:self forKeyPath:kIPPortfolioFontColor];
  [portfolio removeObserver:self forKeyPath:kIPPortfolioLayoutStyle];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Start observing changes to a portfolio
//

- (void)_startObservingPortfolio:(IPPortfolio *)portfolio {
  
  [portfolio addObserver:self
              forKeyPath:kIPPortfolioBackgroundImageName
                 options:0
                 context:NULL];
  [portfolio addObserver:self
              forKeyPath:kIPPortfolioFontColor
                 options:0
                 context:NULL];
  [portfolio addObserver:self forKeyPath:kIPPortfolioLayoutStyle options:0 context:NULL];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Sets the portfolio -- refresh the grid.
//

- (void)setPortfolio:(IPPortfolio *)portfolio {
  
  //
  //  Stop looking for changes to the background image.
  //
  
  [self _stopObservingPortfolio:self.portfolio];
  [super setPortfolio:portfolio];
  
  [self setTitleToPortfolioTitle];
  self.titleTextField.font = self.portfolio.titleFont;
  if (self.portfolio.navigationColor != nil) {
    
    self.navigationController.navigationBar.barTintColor = self.portfolio.navigationColor;
    self.navigationController.navigationBar.translucent = YES;
  }

  DDLogVerbose(@"%s -- looking at a portfolio with %d set(s)",
             __PRETTY_FUNCTION__,
             [self.portfolio countOfSets]);
  DDLogVerbose(@"%s -- portfolio background image is %@",
             __PRETTY_FUNCTION__,
             self.portfolio.backgroundImageName);
  [self setBackgroundImageName:self.portfolio.backgroundImageName];
  
  //
  //  Look for further changes to the background image.
  //
  
  [self _startObservingPortfolio:self.portfolio];
  [self.gridView reloadData];
}

////////////////////////////////////////////////////////////////////////////////
//
//  When the background image changes, update our view.
//

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

  [self setBackgroundImageName:self.portfolio.backgroundImageName];
  if ([keyPath isEqualToString:kIPPortfolioLayoutStyle]) {
    
    [self.gridView reloadData];
  }
}

#pragma mark - Actions

////////////////////////////////////////////////////////////////////////////////
//
//  Look for found pictures, async.
//

- (void)lookForFoundPictures {
  
  DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
  [self.portfolio lookForFoundPicturesAsyncWithCompletion:^(IPSet *foundSet) {
    
    DDLogVerbose(@"%s -- in completion routine. foundSet = %@",
               __PRETTY_FUNCTION__,
               [foundSet description]);
    if (foundSet != nil) {
      
      NSUInteger insertionIndex = [self.portfolio countOfSets];
      __block NSUInteger currentIndex = 0;
      IPSet *optimizedSet = [[IPSet alloc] init];
      optimizedSet.title = foundSet.title;
      [self.portfolio insertObject:optimizedSet inSetsAtIndex:insertionIndex];
      NSIndexPath *indexPath = [NSIndexPath indexPathForItem:insertionIndex inSection:0];
      [self.gridView insertItemsAtIndexPaths:@[indexPath]];
      IPSetCell *cell = (IPSetCell *)[self.gridView cellForItemAtIndexPath:indexPath];

      for (IPPage *page in foundSet.pages) {
        
        [[IPPhotoOptimizationManager sharedManager] asyncOptimizePage:page withCompletion:^(void) {
          
          [optimizedSet insertObject:page inPagesAtIndex:currentIndex];
          [self.portfolio savePortfolioToPath:[IPPortfolio defaultPortfolioPath]];
          [cell updateThumbnail];
          currentIndex++;
        }];
      }
    }
  }];
}

#pragma mark -
#pragma mark UICollectionViewDataSource

////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  
  return 1;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  
  return [self.portfolio countOfSets];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  
  IPSetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:IPPortfolioCellIdentifier forIndexPath:indexPath];
  cell.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);
  switch (self.portfolio.layoutStyle) {
    case IPPortfolioLayoutStyleStacks:
      cell.style = BDGridCellStyleDefault;
      cell.captionHeight = 21;
      break;
      
    case IPPortfolioLayoutStyleTiles:
      cell.style = BDGridCellStyleTile;
      cell.captionHeight = 55;
      break;
      
    default:
      break;
  }
  cell.currentSet = [self.portfolio objectInSetsAtIndex:indexPath.row];
  
  return cell;
}

#pragma mark - UICollectionViewDelegate

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  
  NSUInteger index = indexPath.row;
  IPSet *nextSet = [self.portfolio objectInSetsAtIndex:index];
  [self _pushControllerForSet:nextSet];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
  
  return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)collectionView:(UICollectionView *)collectionView
      canPerformAction:(SEL)action
    forItemAtIndexPath:(NSIndexPath *)indexPath
            withSender:(id)sender {
  
  if (action == @selector(paste:)) {
    NSArray *types = @[kIPPasteboardObjectUTI];
    return [[UIPasteboard generalPasteboard] containsPasteboardTypes:types] ||
    ([[UIPasteboard generalPasteboard] image] != nil);
  }
  return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)collectionView:(UICollectionView *)collectionView
         performAction:(SEL)action
    forItemAtIndexPath:(NSIndexPath *)indexPath
            withSender:(id)sender {
  
  NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:indexPath.row];
  if (action == @selector(cut:)) {
    
    [self _collectionView:collectionView didCut:indexes];
    
  } else if (action == @selector(copy:)) {
    
    [self _collectionView:collectionView didCopy:indexes];
    
  } else if (action == @selector(paste:)) {
    
    [self _collectionView:collectionView didPasteAtIndexSet:indexes];
  }
}

#pragma mark - UICollectionViewFlowLayoutDelegate

////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  The size of a cell is set to a constant 200 pixel height, and whatever width preserves the aspect ratio.
//

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  
  NSUInteger index = indexPath.row;
  IPSet *set = [self.portfolio objectInSetsAtIndex:index];
  UIImage *coverImage = set.thumbnail;
  CGSize imageSize = coverImage.size;
  CGFloat aspectRatio;
  if (imageSize.height) {
    
    aspectRatio = imageSize.width / imageSize.height;
    
  } else {
    
    aspectRatio = 1.0;
  }
  CGFloat cellWidth = 200 * aspectRatio;
  return CGSizeMake(cellWidth, 200);
}

#pragma mark -
#pragma mark BDGridViewDelegate

////////////////////////////////////////////////////////////////////////////////
//
//  Helper routine to push the navigation controller for a specific set.
//

- (void)_pushControllerForSet:(IPSet *)set {
  
  IPSetGridViewController *setController = [[IPSetGridViewController alloc] initWithNibName:@"IPSetGridViewController" bundle:nil];
//  IPSetPagingViewController *setController = [[[IPSetPagingViewController alloc] initWithNibName:@"IPSetPagingViewController" bundle:nil] autorelease];
  setController.backButtonText = self.titleTextField.text;
  setController.currentSet = set;
  [self.navigationController pushViewController:setController animated:NO];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Helper. Asynchronously creates |IPPage| objects for each image in |images|.
//  For each page, calls back to |progress| on the main thread. At the end of
//  everything, calls back to |completion| on the main thread.
//

- (void)asyncLoadImages:(NSArray *)assets
           pageProgress:(void(^)(IPPage *nextPage, NSUInteger count))progress 
             completion:(void(^)())completion {
  
  progress = [progress copy];
  completion = [completion copy];
  NSConditionLock *workersDone = [[NSConditionLock alloc] initWithCondition:[assets count]];
  
  for (id<BDSelectableAsset> asset in assets) {
    
    [asset imageAsyncWithCompletion:^(NSString *filename, NSString *uti) {
      
      if (filename == nil) {
        
        //
        //  There was at least one case where we couldn't get an image.
        //
        
        [workersDone lock];
        [workersDone unlockWithCondition:[workersDone condition] - 1];
        return;
      }
      
      IPPhoto *photo = [[IPPhoto alloc] init];
      photo.filename = filename;
      photo.title = [asset title];
      
      [[IPPhotoOptimizationManager sharedManager] asyncOptimizePhoto:photo withCompletion:^(void) {
        
        IPPage *page = [IPPage pageWithPhoto:photo];
        [workersDone lock];
        progress(page, [assets count] - [workersDone condition]);
        [workersDone unlockWithCondition:[workersDone condition] - 1];
      }];
    }];
  }
  
  dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  dispatch_async(defaultQueue, ^(void) {
    

    [workersDone lockWhenCondition:0];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
      
      completion();
    });
    [workersDone unlockWithCondition:0];
  });
}

////////////////////////////////////////////////////////////////////////////////
//
//  Copy a set.
//

- (void)_collectionView:(UICollectionView *)collectionView didCopy:(NSIndexSet *)indexes {
  
  NSAssert([indexes count] == 1, @"Only know how to copy single sets");
  NSUInteger index = [indexes firstIndex];
  IPPasteboardObject *pasteboardObject = [[IPPasteboardObject alloc] init];
  pasteboardObject.modelObject = [self.portfolio objectInSetsAtIndex:index];
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:pasteboardObject];
  if (data) {
    
    [[UIPasteboard generalPasteboard] setData:data forPasteboardType:kIPPasteboardObjectUTI];
    
  } else {
    
    [self.alertManager showErrorMessage:kErrorCopyFailed];
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  Cut a set.
//

- (void)_collectionView:(UICollectionView *)collectionView didCut:(NSIndexSet *)indexes {
  
  NSAssert([indexes count] == 1, @"Only know how to cut single sets");
  NSUInteger index = [indexes firstIndex];
  IPPasteboardObject *pasteboardObject = [[IPPasteboardObject alloc] init];
  IPSet *set = [self.portfolio objectInSetsAtIndex:index];
  pasteboardObject.modelObject = set;
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:pasteboardObject];
  if (data) {
    
    [set deletePhotoFiles];
    [[UIPasteboard generalPasteboard] setData:data forPasteboardType:kIPPasteboardObjectUTI];
    [self.portfolio removeObjectFromSetsAtIndex:index];
    [self.portfolio savePortfolioToPath:[IPPortfolio defaultPortfolioPath]];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [collectionView performBatchUpdates:^{
      [collectionView deleteItemsAtIndexPaths:@[indexPath]];
    } completion:nil];
    
  } else {
    
    [self.alertManager showErrorMessage:kErrorCutFailed];
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  Helper routine for pasting: Returns a set object from the contents of the 
//  pasteboard.
//

- (IPSet *)setFromPasteboard {
  
  NSData *data = [[UIPasteboard generalPasteboard] dataForPasteboardType:kIPPasteboardObjectUTI];
  IPPasteboardObject *pasteboardObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
  IPSet *set = nil;
  if ([pasteboardObject.modelObject isKindOfClass:[IPSet class]]) {
    
    set = (IPSet *)pasteboardObject.modelObject;
    
  } else if ([pasteboardObject.modelObject isKindOfClass:[IPPage class]]) {
    
    IPPage *page = (IPPage *)pasteboardObject.modelObject;
    set = [IPSet setWithPages:page, nil];
    
  } else if ([[UIPasteboard generalPasteboard] image] != nil) {
    
    UIImage *image = [[UIPasteboard generalPasteboard] image];
    IPPage *page = [IPPage pageWithImage:image];
    set = [IPSet setWithPages:page, nil];
  }
  return set;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Do a paste.
//

- (void)_collectionView:(UICollectionView *)collectionView didPasteAtIndexSet:(NSIndexSet *)indexSet {
  
  NSAssert(indexSet.count <= 1, @"Cannot handle more than one index");
  NSUInteger insertionPoint = indexSet.firstIndex;
  NSIndexPath *indexPath = [NSIndexPath indexPathForItem:insertionPoint inSection:0];
  IPSet *unoptimizedSet = [self setFromPasteboard];
  if (unoptimizedSet != nil) {

    IPSet *optimizedSet = [[IPSet alloc] init];
    optimizedSet.title = unoptimizedSet.title;
    
    //
    //  Put the empty, optimized set in the model & UI.
    //
    
    [self.portfolio insertObject:optimizedSet inSetsAtIndex:insertionPoint];
    [self.portfolio savePortfolioToPath:[IPPortfolio defaultPortfolioPath]];
    [collectionView performBatchUpdates:^{
      [collectionView insertItemsAtIndexPaths:@[indexPath]];
    } completion:nil];
    
    //
    //  Optimize each page from the unoptimized set and stick it in the
    //  optimized set.
    //
    
    __block NSUInteger currentSetIndex = 0;
    for (IPPage *page in unoptimizedSet.pages) {
      
      [[IPPhotoOptimizationManager sharedManager] asyncOptimizePage:page withCompletion:^(void) {
        
        [optimizedSet insertObject:page inPagesAtIndex:currentSetIndex];
        currentSetIndex++;
      }];
    }
  }
}

#pragma mark - UITextFieldDelegate

////////////////////////////////////////////////////////////////////////////////
//
//  Save changes to the portfolio title.
//

- (void)textFieldDidEndEditing:(UITextField *)textField {
  
  self.portfolio.title = textField.text;
  [self.portfolio savePortfolioToPath:[IPPortfolio defaultPortfolioPath]];
  if ([self.tutorialManager updateTutorialStateForEvent:IPTutorialManagerEventEditTitle]) {
    
    self.overlayController = [self overlayControllerForCurrentState];
  }
}

#pragma mark - Tutorial

////////////////////////////////////////////////////////////////////////////////

- (void)startTutorial {
  
//  self.tutorialManager.state = IPTutorialManagerStateWelcome;
  [self setOverlayController:[self overlayControllerForCurrentState] animated:YES];
}

@end
