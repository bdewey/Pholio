//
//  BDPagingView.m
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

#import "BDPagingView.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
//  Private class to associate a child view with an index.
//

@interface BDPagingViewCell: NSObject {}

@property (nonatomic, strong) UIView *subview;
@property (nonatomic, assign) NSUInteger index;

@end

@implementation BDPagingViewCell

@synthesize subview = subview_;
@synthesize index = index_;

- (id)initWithSubview:(UIView *)subview andIndex:(NSUInteger)index {
  
  self = [super init];
  if (self != nil) {
    
    self.subview = subview;
    self.index   = index;
  }
  return self;
}


@end

#define kBDPagingViewPadding        (20)

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
//  Private 
//

@interface BDPagingView()

//
//  Views that we can currently see in the scroll view.
//

@property (nonatomic, strong) NSMutableSet *visibleViews;

//
//  Views that have recycled off the screen.
//

@property (nonatomic, strong) NSMutableSet *recycledViews;

- (void)setup;
- (BDPagingViewCell *)isViewVisible:(NSInteger)pageIndex;
- (BDPagingViewCell *)viewForPage:(NSInteger)pageIndex;
- (CGRect)frameForPage:(NSInteger)pageIndex;

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation BDPagingView

@dynamic currentPageIndex;
@synthesize pagingViewDelegate = pagingViewDelegate_;
@synthesize visibleViews = visibleViews_;
@synthesize recycledViews = recycledViews_;

////////////////////////////////////////////////////////////////////////////////
//
//  Designated initializer.
//

- (id)initWithFrame:(CGRect)frame {
  
  self = [super initWithFrame:frame];
  if (self != nil) {
    
    [self setup];
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Needed for building the view from a nib.
//

- (id)initWithCoder:(NSCoder *)aDecoder {
  
  self = [super initWithCoder:aDecoder];
  if (self != nil) {
    
    [self setup];
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Common initialization.
//

- (void)setup {

  visibleViews_ = [[NSMutableSet alloc] initWithCapacity:2];
  recycledViews_ = [[NSMutableSet alloc] initWithCapacity:1];
  self.pagingEnabled = YES;
  self.delegate = self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Dealloc.
//


#pragma mark - Properties

////////////////////////////////////////////////////////////////////////////////
//
//  Gets the current "page index". This is derived from the current bounds of
//  the display and the width of the view.
//

- (NSUInteger)currentPageIndex {
  
  CGRect visibleBounds = self.bounds;
  CGSize pageSize      = self.frame.size;
  CGFloat centerPage = floor(CGRectGetMidX(visibleBounds) / pageSize.width);
  return centerPage;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Sets the current page index, with control over if the change is animated.
//

- (void)setCurrentPageIndex:(NSUInteger)currentPageIndex animated:(BOOL)animated {
  
  CGSize pageSize = self.frame.size;
  [self setContentOffset:CGPointMake(pageSize.width * currentPageIndex, 0) 
                animated:animated];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Sets the current page index... does this by scrolling so the appropriate page
//  is in view.
//

- (void)setCurrentPageIndex:(NSUInteger)currentPageIndex {
  
  [self setCurrentPageIndex:currentPageIndex animated:NO];
}

#pragma mark - Page management

////////////////////////////////////////////////////////////////////////////////
//
//  Gets a view out of |recycledViews|.
//

- (UIView *)dequeueView {
  
  BDPagingViewCell *cell = [self.recycledViews anyObject];
  if (cell != nil) {
    
    [self.recycledViews removeObject:cell];
  }
  return cell.subview;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Layout my subviews.
//

- (void)tileSubviews {
  
  self.contentSize = CGSizeMake(self.frame.size.width * [self.pagingViewDelegate pagingViewCountOfPages:self], 
                                self.frame.size.height);
  CGRect visibleBounds = self.bounds;
  CGSize pageSize      = self.frame.size;
  
  CGFloat firstVisiblePage = floor(CGRectGetMinX(visibleBounds) / pageSize.width);
  CGFloat lastVisiblePage  = floor((CGRectGetMaxX(visibleBounds)-1) / pageSize.width);

  
  //
  //  Update the title based upon the center of the visible bounds.
  //
  
  if ([self.pagingViewDelegate respondsToSelector:@selector(pagingView:didMoveToPage:)]) {
    
    [self.pagingViewDelegate pagingView:self didMoveToPage:self.currentPageIndex];
  }
  
  _GTMDevAssert(self.visibleViews != nil, @"visibleViews should be initialized");
  _GTMDevAssert(self.recycledViews != nil, @"recycledViews should be initialized");
  
  //
  //  Loop through the active visible cells, looking for ones we no longer need
  // 
  
  for (BDPagingViewCell *cell in self.visibleViews) {
    
    CGFloat subviewIndex = cell.index;
    if ((subviewIndex < firstVisiblePage) || (subviewIndex > lastVisiblePage)) {

      [self.recycledViews addObject:cell];
      [cell.subview removeFromSuperview];
    }
  }
  [self.visibleViews minusSet:self.recycledViews];
  
  for (NSInteger i = firstVisiblePage; i <= lastVisiblePage; i++) {
    
    BDPagingViewCell *cell = [self isViewVisible:i];
    if (cell == nil) {
      
      //
      //  Subview wasn't found. Create it.
      //
      
      cell = [self viewForPage:i];
      if (cell != nil) {

        [self.visibleViews addObject:cell];
        [self addSubview:cell.subview];
      }
      
    } else {
      
      //
      //  The view is visible... make sure it's at the right frame.
      //  Needed to handle the rotation case.
      //
      
      cell.subview.frame = [self frameForPage:i];
    }
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  Recomputes the content size, and then repositions all visible views.
//

- (void)recomputeContentSize {
  
  self.contentSize = CGSizeMake(self.frame.size.width * [self.pagingViewDelegate pagingViewCountOfPages:self], 
                                self.frame.size.height);

  for (BDPagingViewCell *cell in self.visibleViews) {
    
    cell.subview.frame = [self frameForPage:cell.index];
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  Gets the frame for a page.
//

- (CGRect)frameForPage:(NSInteger)pageIndex {
  
  CGFloat pageWidth = self.frame.size.width;
  CGRect pageFrame = self.frame;
  pageFrame.origin.x = pageWidth * pageIndex + kBDPagingViewPadding;
  pageFrame.size.width = pageWidth - 2 * kBDPagingViewPadding;
  return pageFrame;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Gets the view for a particular page.
//  Returns |nil| on invalid index.
//

- (BDPagingViewCell *)viewForPage:(NSInteger)pageIndex {
  
  NSUInteger pageCount = [self.pagingViewDelegate pagingViewCountOfPages:self];
  BOOL outOfBounds = (pageIndex < 0) || (pageIndex >= pageCount);
  if (outOfBounds) {
    
    return nil;
  }
  
  UIView *subview = [self.pagingViewDelegate pagingView:self pageAtIndex:pageIndex];
  subview.frame = [self frameForPage:pageIndex];
  return [[BDPagingViewCell alloc] initWithSubview:subview andIndex:pageIndex];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Tests if a page is in |visibleViews|. Returns the page if found, else nil.
//

- (BDPagingViewCell *)isViewVisible:(NSInteger)pageIndex {
  
  for (BDPagingViewCell *cell in self.visibleViews) {
    
    NSInteger subviewIndex = cell.index;
    if (subviewIndex == pageIndex) {
      
      return cell;
    }
  }
  return nil;
}

#pragma mark - UIScrollViewDelegate

////////////////////////////////////////////////////////////////////////////////
//
//  When we scroll, we need to retile the views. This adjusts the visibility
//  of the subviews.
//

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  
  [self tileSubviews];
}

@end
