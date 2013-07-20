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

#import "IPColors.h"
#import "IPPortfolio.h"
#import "IPSetGridViewController.h"
#import "IPSetPagingViewController.h"
#import "IPPasteboardObject.h"
#import "BDGridCell.h"
#import "BDImagePickerController.h"
#import "IPAlert.h"
#import "IPPhotoOptimizationManager.h"
#import "UIImage+Border.h"

static NSString * const kIPSetGridViewCellIdentifier = @"kIPSetGridViewCellIdentifier";

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
//  BDGridCell subclass that watches for changes to the IPPhoto image/caption
//  so we can update the cell appropriately.
//

@interface IPPageCell : BDGridCell

//
//  The photo visualized by this cell.
//

@property (nonatomic, strong) IPPhoto *photo;

@end

@implementation IPPageCell

////////////////////////////////////////////////////////////////////////////////

- (void)dealloc {
  
  [_photo removeObserver:self forKeyPath:kIPPhotoTitle];
}

////////////////////////////////////////////////////////////////////////////////
//
//  When we get assigned a photo, set up the caption / image and also watch
//  for changes in the photo title.
//

- (void)setPhoto:(IPPhoto *)photo {
  
  if (_photo == photo) {
    return;
  }
  [_photo removeObserver:self forKeyPath:kIPPhotoTitle];
  _photo = photo;
  
  self.image = nil;
  if (photo == nil) {
    
    //
    //  To go past here with |photo| equal to |nil| could mean queuing an operation
    //  for an object that's about to be deleted.
    //
    
    return;
  }
  [_photo addObserver:self forKeyPath:kIPPhotoTitle options:0 context:NULL];
  self.caption = self.photo.title;
  UIImage *thumbnail = self.photo.thumbnail;
  [[[IPPhotoOptimizationManager sharedManager] optimizationQueue] addOperationWithBlock:^(void) {
    UIImage *bordered = [thumbnail imageWithBorderWidth:10.0 andColor:[[UIColor whiteColor] CGColor]];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void) {
      
      self.image = bordered;
    }];
  }];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Watch for changes in the photo title.
//

- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change 
                       context:(void *)context {
  
  self.caption = self.photo.title;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

@interface IPSetGridViewController () <
UICollectionViewDataSource,
UICollectionViewDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate
>

@end


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPSetGridViewController

////////////////////////////////////////////////////////////////////////////////
//
//  Free memory.
//

- (void)didReceiveMemoryWarning {
  
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  self.defaultPicker = nil;
}

#pragma mark - View lifecycle

////////////////////////////////////////////////////////////////////////////////
//
//  Do post-view-loading initialization.
//

- (void)viewDidLoad {
  
  [super viewDidLoad];
  
  UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
  layout.itemSize = CGSizeMake(kGridCellSize, kGridCellSize);
  layout.sectionInset = UIEdgeInsetsMake(72, 8, 8, 8);
  
  _gridView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
  _gridView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  _gridView.dataSource = self;
  _gridView.delegate = self;
  [_gridView registerClass:[IPPageCell class] forCellWithReuseIdentifier:kIPSetGridViewCellIdentifier];
  _gridView.collectionViewLayout = layout;
  [self.view addSubview:_gridView];

  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.backButtonText 
                                                                            style:UIBarButtonItemStylePlain 
                                                                           target:self 
                                                                           action:@selector(popView)];
  self.titleTextField.text = self.title;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Make sure we use the right background image & font color.
//

- (void)viewWillAppear:(BOOL)animated {

  [super viewWillAppear:animated];
  [self setBackgroundImageName:self.currentSet.parent.backgroundImageName];
  NSAssert(self.currentSet.parent != nil, @"Set must have a parent");
}

////////////////////////////////////////////////////////////////////////////////
//
//  Fade in.
//

- (void)viewDidAppear:(BOOL)animated {
  
  [super viewDidAppear:animated];
  self.gridView.alpha = 0;
  [UIView animateWithDuration:kIPAnimationViewFade animations:^(void) {
    self.gridView.alpha = 1;
  }];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Fade out the grid view before popping back.
//

- (void)popView {
  
  [UIView animateWithDuration:kIPAnimationViewFadeFast animations:^(void) {
    self.gridView.alpha = 0;
  } completion:^(BOOL finished) {
    [self.navigationController popViewControllerAnimated:NO];
  }];
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

#pragma mark -
#pragma mark Properties

////////////////////////////////////////////////////////////////////////////////
//
//  Sets |currentSet| -- refresh the grid.
//

- (void)setCurrentSet:(IPSet *)currentSet {
  
  if (_currentSet == currentSet) {
    return;
  }
  _currentSet = currentSet;
  
  self.portfolio = self.currentSet.parent;
  self.title = self.currentSet.title;
  [self.gridView reloadData];
  DDLogVerbose(@"%s -- looking at a set with %d pages",
             __PRETTY_FUNCTION__,
             [self.currentSet countOfPages]);
}

////////////////////////////////////////////////////////////////////////////////
//
//  Lazy initializer for backButtonText.
//

- (NSString *)backButtonText {
  
  if (_backButtonText == nil) {
    
    _backButtonText = [[NSString alloc] initWithString:kBackButtonText];
  }
  return _backButtonText;
}

#pragma mark - UICollectionViewDataSource

////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  
  return 1;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  
  return [_currentSet countOfPages];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  
  IPPageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kIPSetGridViewCellIdentifier forIndexPath:indexPath];
  cell.style = BDGridCellStyleDefault;
  cell.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
  
  IPPage *page = [self.currentSet objectInPagesAtIndex:indexPath.row];
  IPPhoto *photo = [page objectInPhotosAtIndex:0];
  cell.photo = photo;
  
  return cell;
}

#pragma mark - UICollectionViewDelegate

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  
  NSUInteger index = indexPath.row;
  IPSetPagingViewController *controller = [[IPSetPagingViewController alloc] initWithNibName:@"IPSetPagingViewController" bundle:nil];
  
  controller.currentSet = self.currentSet;
  controller.currentPageIndex = index;
  controller.backButtonText = self.navigationItem.title;
  [self.navigationController pushViewController:controller animated:NO];
}

#if 0

#pragma mark -
#pragma mark BDGridViewDelegate

////////////////////////////////////////////////////////////////////////////////
//
//  Let the user pick a picture to insert.
//

- (void)gridView:(BDGridView *)gridView didInsertAtPoint:(NSUInteger)insertionPoint 
        fromRect:(CGRect)rect {
  
  [BDImagePickerController confirmLocationServicesAndPresentPopoverFromRect:rect inView:gridView onSelection:^(NSArray *assets) {
    
    __block NSUInteger currentInsertionPoint = insertionPoint;
    for (id<BDSelectableAsset> asset in assets) {
      
      [asset imageAsyncWithCompletion:^(NSString *filename, NSString *uti) {
        
        if (filename == nil) {
          return;
        }
        IPPhoto *photo = [[IPPhoto alloc] init];
        photo.filename = filename;
        photo.title = [asset title];
        [[IPPhotoOptimizationManager sharedManager] asyncOptimizePhoto:photo withCompletion:^(void) {
          
          IPPage *page = [IPPage pageWithPhoto:photo];
          [self.currentSet insertObject:page inPagesAtIndex:currentInsertionPoint];
          [self.currentSet.parent savePortfolioToPath:[IPPortfolio defaultPortfolioPath]];
          [self.gridView insertCellAtIndex:currentInsertionPoint];
          currentInsertionPoint++;
        }];
      }];
    }
  }
   setPopover:^(UIPopoverController *popover) {
     self.activePopoverController = popover;
   }
   ];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Handle a cut.
//

- (void)gridView:(BDGridView *)gridView didCut:(NSSet *)indexes {
  
  UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
  NSAssert([indexes count] == 1, @"Should only cut one item");
  for (NSNumber *indexNumber in indexes) {
    
    NSUInteger index = [indexNumber unsignedIntegerValue];
    NSAssert(index < [self.currentSet countOfPages], 
                  @"Should have a valid index");
    IPPage *page = [self.currentSet objectInPagesAtIndex:index];
    IPPasteboardObject *pasteboardObject = [[IPPasteboardObject alloc] init];
    pasteboardObject.modelObject = page;
    NSData *pageData = [NSKeyedArchiver archivedDataWithRootObject:pasteboardObject];
    [pasteboard setData:pageData forPasteboardType:kIPPasteboardObjectUTI];
    [page deletePhotoFiles];
    [self.currentSet removeObjectFromPagesAtIndex:index];
    [self.currentSet.parent savePortfolioToPath:[IPPortfolio defaultPortfolioPath]];
    [gridView deleteCellAtIndex:index];
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  Handle a copy.
//

- (void)gridView:(BDGridView *)gridView didCopy:(NSSet *)indexes {
  
  UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
  NSAssert([indexes count] == 1, @"Can only copy one item");
  NSUInteger index = [[indexes anyObject] unsignedIntegerValue];
  NSAssert(index < [self.currentSet countOfPages], 
                @"index must be in bounds");
  IPPasteboardObject *pasteboardObject = [[IPPasteboardObject alloc] init];
  pasteboardObject.modelObject = [self.currentSet objectInPagesAtIndex:index];
  NSData *pasteData = [NSKeyedArchiver archivedDataWithRootObject:pasteboardObject];
  if (pasteData != nil) {
    [pasteboard setData:pasteData forPasteboardType:kIPPasteboardObjectUTI];
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  Can we handle what's on the pasteboard?
//

- (BOOL)gridViewCanPaste:(BDGridView *)gridView {
  
  UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
  NSArray *allowedTypes = @[kIPPasteboardObjectUTI];
  DDLogVerbose(@"%s -- pasteboard contains %@",
             __PRETTY_FUNCTION__,
             [pasteboard.pasteboardTypes description]);
  
  //
  //  We can handle pastes of pages or any image.
  //
  
  return [pasteboard containsPasteboardTypes:allowedTypes] ||
    (pasteboard.image != nil);
}

////////////////////////////////////////////////////////////////////////////////
//
//  Handle a paste.
//

- (void)gridView:(BDGridView *)gridView didPasteAtPoint:(NSUInteger)insertionPoint {
  
  UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
  NSData *pasteData = [pasteboard dataForPasteboardType:kIPPasteboardObjectUTI];
  IPPasteboardObject *pasteboardObject = [NSKeyedUnarchiver unarchiveObjectWithData:pasteData];
  if ([pasteboardObject.modelObject isKindOfClass:[IPPage class]]) {

    //
    //  The pasteboard contained a page.
    //
    
    IPPage *page = (IPPage *)pasteboardObject.modelObject;

    [[IPPhotoOptimizationManager sharedManager] asyncOptimizePage:page withCompletion:^(void) {

      [self.currentSet insertObject:page inPagesAtIndex:insertionPoint];
      [self.currentSet.parent savePortfolioToPath:[IPPortfolio defaultPortfolioPath]];
      [gridView insertCellAtIndex:insertionPoint];
    }];
    
  } else if ([pasteboardObject.modelObject isKindOfClass:[IPSet class]]) {
    
    //
    //  The pasteboard contains a *set*. Put each page in, individually.
    //
    
    IPSet *set = (IPSet *)pasteboardObject.modelObject;
    __block NSUInteger currentInsertionPoint = insertionPoint;
    for (IPPage *page in set.pages) {
      
      [[IPPhotoOptimizationManager sharedManager] asyncOptimizePage:page withCompletion:^(void) {
        
        [self.currentSet insertObject:page inPagesAtIndex:currentInsertionPoint];
        [self.currentSet.parent savePortfolioToPath:[IPPortfolio defaultPortfolioPath]];
        [gridView insertCellAtIndex:currentInsertionPoint];
        currentInsertionPoint++;
      }];
    }
    
  } else if (pasteboard.image != nil) {

    //
    //  There's a picture on the pasteboard instead of a page.
    //  Create a page for the picture.
    //

    IPPage *page = [IPPage pageWithImage:pasteboard.image];
    [[IPPhotoOptimizationManager sharedManager] asyncOptimizePage:page withCompletion:^(void) {
      
      [self.currentSet insertObject:page inPagesAtIndex:insertionPoint];
      [self.currentSet.parent savePortfolioToPath:[IPPortfolio defaultPortfolioPath]];
      [gridView insertCellAtIndex:insertionPoint];
    }];
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  Delete.
//

- (void)gridView:(BDGridView *)gridView didDelete:(NSSet *)indexes {
  
  NSAssert([indexes count] == 1, @"Only know how to delete one page");
  NSUInteger index = [[indexes anyObject] unsignedIntegerValue];
  IPPage *page = [self.currentSet objectInPagesAtIndex:index];
  CGRect frame = [self.gridView frameForCellAtIndex:index];
  
  NSString *alertText;
  NSString *pageTitle = [page valueForKeyPath:kIPPhotoTitle forPhoto:0];
  if ([pageTitle length] > 0) {
    
    alertText = [NSString stringWithFormat:kConfirmDelete, pageTitle];
    
  } else {
    
    alertText = kConfirmDeletePageNoTitle;
  }
  
  [self.alertManager confirmWithDescription:alertText 
                             andButtonTitle:kDeleteString 
                                   fromRect:frame 
                                     inView:self.gridView 
                              performAction:
   ^(void) {
     [page deletePhotoFiles];
     NSUInteger index = [self.currentSet.pages indexOfObject:page];
     [self.currentSet.pages removeObject:page];
     [gridView deleteCellAtIndex:index];
     [self.currentSet.parent savePortfolioToPath:[IPPortfolio defaultPortfolioPath]];
   }
   ];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Move a cell.
//

- (void)gridView:(BDGridView *)gridView didMoveItemFromIndex:(NSUInteger)initialIndex 
         toIndex:(NSUInteger)finalIndex {
  
  IPPage *page = [self.currentSet objectInPagesAtIndex:initialIndex];
  [self.currentSet removeObjectFromPagesAtIndex:initialIndex];
  [self.currentSet insertObject:page inPagesAtIndex:finalIndex];
  [self.currentSet.parent savePortfolioToPath:[IPPortfolio defaultPortfolioPath]];
}

#endif

#pragma mark - UITextFieldDelegate

////////////////////////////////////////////////////////////////////////////////
//
//  Commit title changes to the set.
//

- (void)textFieldDidEndEditing:(UITextField *)textField {
  
  self.currentSet.title = textField.text;
  self.navigationItem.title = textField.text;
  [self.currentSet.parent savePortfolioToPath:[IPPortfolio defaultPortfolioPath]];
}

@end
