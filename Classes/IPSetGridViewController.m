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

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
//  BDGridCell subclass that watches for changes to the IPPhoto image/caption
//  so we can update the cell appropriately.
//

@interface IPPageCell : BDGridCell {
}

//
//  The photo visualized by this cell.
//

@property (nonatomic, retain) IPPhoto *photo;

@end

@implementation IPPageCell

@synthesize photo = photo_;

////////////////////////////////////////////////////////////////////////////////
//
//  Dealloc. Note we set photo to nil, which will not only release it but also
//  remove the observers.
//

- (void)dealloc {
  
  self.photo = nil;
  [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////
//
//  When we get assigned a photo, set up the caption / image and also watch
//  for changes in the photo title.
//

- (void)setPhoto:(IPPhoto *)photo {
  
  [self.photo removeObserver:self forKeyPath:kIPPhotoTitle];
  [photo_ autorelease];
  photo_ = [photo retain];
  
  [self.photo addObserver:self forKeyPath:kIPPhotoTitle options:0 context:NULL];
  self.caption = self.photo.title;
  self.image = self.photo.thumbnail;
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


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface IPSetGridViewController ()


- (void)popView;
@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPSetGridViewController

@synthesize currentSet = currentSet_;
@synthesize backButtonText = backButtonText_;
@synthesize gridView = gridView_;

////////////////////////////////////////////////////////////////////////////////
//
//  Designatied initializer.
//

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {

    //
    //  Spot for custom initialization.
    //
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Deallocator.
//

- (void)dealloc {
  
  [currentSet_ release];
  [backButtonText_ release];
  [gridView_ release];
  [super dealloc];
}

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
  
  self.gridView.dataSource = self;
  self.gridView.gridViewDelegate = self;
  self.gridView.topContentPadding = self.navigationController.navigationBar.frame.size.height;
  if (self.currentSet.parent.fontColor != nil) {

    self.gridView.fontColor = self.currentSet.parent.fontColor;
  }
  self.gridView.font = self.currentSet.parent.textFont;

  self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:self.backButtonText 
                                                                            style:UIBarButtonItemStylePlain 
                                                                           target:self 
                                                                           action:@selector(popView)] autorelease];
  self.titleTextField.text = self.title;
  
  //
  //  Make sure tiles exist for all photos in this set.
  //
  
//  for (IPPage *page in self.currentSet.pages) {
//    for (IPPhoto *photo in page.photos) {
//      
//      [[IPPhotoTilingManager sharedManager] asyncTilePhoto:photo 
//                                            withCompletion:nil];
//    }
//  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  Make sure we use the right background image & font color.
//

- (void)viewWillAppear:(BOOL)animated {

  [super viewWillAppear:animated];
  [self setBackgroundImageName:self.currentSet.parent.backgroundImageName];
  _GTMDevAssert(self.currentSet.parent != nil, @"Set must have a parent");
  self.gridView.fontColor = self.currentSet.parent.fontColor;
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

#pragma mark -
#pragma mark Properties

////////////////////////////////////////////////////////////////////////////////
//
//  Sets |currentSet| -- refresh the grid.
//

- (void)setCurrentSet:(IPSet *)currentSet {
  
  [currentSet_ autorelease];
  currentSet_ = [currentSet retain];
  
  self.portfolio = self.currentSet.parent;
  self.title = self.currentSet.title;
  if (self.currentSet.parent.fontColor != nil) {

    self.gridView.fontColor = self.currentSet.parent.fontColor;
  }
  [self.gridView reloadData];
  _GTMDevLog(@"%s -- looking at a set with %d pages",
             __PRETTY_FUNCTION__,
             [self.currentSet countOfPages]);
}

////////////////////////////////////////////////////////////////////////////////
//
//  Write through changes to the font color.
//

- (void)ipSettingsSetGridTextColor:(UIColor *)gridTextColor {
  
  [super ipSettingsSetGridTextColor:gridTextColor];
  self.gridView.fontColor = self.currentSet.parent.fontColor;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Handle changes to text font.
//

- (void)ipSettingsDidSetTextFontFamily:(NSString *)fontFamily {
  
  [super ipSettingsDidSetTextFontFamily:fontFamily];
  self.gridView.font = self.portfolio.textFont;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Lazy initializer for backButtonText.
//

- (NSString *)backButtonText {
  
  if (backButtonText_ == nil) {
    
    backButtonText_ = [[NSString alloc] initWithString:kBackButtonText];
  }
  return backButtonText_;
}

#pragma mark -
#pragma mark BDGridViewDataSource

////////////////////////////////////////////////////////////////////////////////
//
//  Return the cell size.
//

- (CGSize)gridViewSizeOfCell:(BDGridView *)gridView {
  
  return CGSizeMake(kGridCellSize, kGridCellSize);
}

////////////////////////////////////////////////////////////////////////////////
//
//  Return the number of sets in the portfolio.
//

- (NSUInteger)gridViewCountOfCells:(BDGridView *)gridView {
  
  return [self.currentSet countOfPages];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Get a cell for a set in the portfolio.
//

- (BDGridCell *)gridView:(BDGridView *)gridView cellForIndex:(NSUInteger)index {
  
  IPPageCell *cell = (IPPageCell *)[gridView dequeueCell];
  if (cell == nil) {
    
    cell = [[[IPPageCell alloc] initWithStyle:BDGridCellStyleDefault] autorelease];
    cell.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
  }
  
  IPPage *page = [self.currentSet objectInPagesAtIndex:index];
  IPPhoto *photo = [page objectInPhotosAtIndex:0];
  cell.photo = photo;
  
  return cell;
}

#pragma mark -
#pragma mark BDGridViewDelegate

////////////////////////////////////////////////////////////////////////////////
//
//  The user tapped a picture. Open an |IPSetPagingViewController| centered
//  on that picture.
//

- (void)gridView:(BDGridView *)gridView didTapCell:(BDGridCell *)cell {
  
  NSUInteger index = cell.index;
  IPSetPagingViewController *controller = [[[IPSetPagingViewController alloc] initWithNibName:@"IPSetPagingViewController" bundle:nil] autorelease];

  controller.currentSet = self.currentSet;
  controller.currentPageIndex = index;
  controller.backButtonText = self.navigationItem.title;
  [self.navigationController pushViewController:controller animated:NO];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Let the user pick a picture to insert.
//

- (void)gridView:(BDGridView *)gridView didInsertAtPoint:(NSUInteger)insertionPoint 
        fromRect:(CGRect)rect {
  
  self.popoverController = [BDImagePickerController presentPopoverFromRect:rect inView:gridView onSelection:^(NSArray *assets) {
    
    __block NSUInteger currentInsertionPoint = insertionPoint;
    for (id<BDSelectableAsset> asset in assets) {
      
      [asset imageAsyncWithCompletion:^(NSString *filename, NSString *uti) {
        
        if (filename == nil) {
          return;
        }
        IPPhoto *photo = [[IPPhoto alloc] init];
        photo.filename = filename;
        [[IPPhotoOptimizationManager sharedManager] asyncOptimizePhoto:photo withCompletion:^(void) {
          
          IPPage *page = [IPPage pageWithPhoto:photo];
          [self.currentSet insertObject:page inPagesAtIndex:currentInsertionPoint];
          [self.currentSet.parent savePortfolioToPath:[IPPortfolio defaultPortfolioPath]];
          [self.gridView insertCellAtIndex:currentInsertionPoint];
          currentInsertionPoint++;
          [photo release];
        }];
      }];
    }
  }];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Handle a cut.
//

- (void)gridView:(BDGridView *)gridView didCut:(NSSet *)indexes {
  
  UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
  _GTMDevAssert([indexes count] == 1, @"Should only cut one item");
  for (NSNumber *indexNumber in indexes) {
    
    NSUInteger index = [indexNumber unsignedIntegerValue];
    _GTMDevAssert(index < [self.currentSet countOfPages], 
                  @"Should have a valid index");
    IPPage *page = [self.currentSet objectInPagesAtIndex:index];
    IPPasteboardObject *pasteboardObject = [[[IPPasteboardObject alloc] init] autorelease];
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
  _GTMDevAssert([indexes count] == 1, @"Can only copy one item");
  NSUInteger index = [[indexes anyObject] unsignedIntegerValue];
  _GTMDevAssert(index < [self.currentSet countOfPages], 
                @"index must be in bounds");
  IPPasteboardObject *pasteboardObject = [[[IPPasteboardObject alloc] init] autorelease];
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
  NSArray *allowedTypes = [NSArray arrayWithObject:kIPPasteboardObjectUTI];
  _GTMDevLog(@"%s -- pasteboard contains %@",
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
  
  _GTMDevAssert([indexes count] == 1, @"Only know how to delete one page");
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
  
  IPPage *page = [[[self.currentSet objectInPagesAtIndex:initialIndex] retain] autorelease];
  [self.currentSet removeObjectFromPagesAtIndex:initialIndex];
  [self.currentSet insertObject:page inPagesAtIndex:finalIndex];
  [self.currentSet.parent savePortfolioToPath:[IPPortfolio defaultPortfolioPath]];
}

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
