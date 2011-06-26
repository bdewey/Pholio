//
//  BDPagingView.h
//
//  Implements a side-to-side paging scroll view.
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

#import <Foundation/Foundation.h>

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@protocol BDPagingViewDelegate;
@interface BDPagingView : UIScrollView<UIScrollViewDelegate> {
    
}

//
//  Our current page index.
//

@property (nonatomic, assign) NSUInteger currentPageIndex;

//
//  The data source for this paging view.
//

@property (nonatomic, assign) id<BDPagingViewDelegate> pagingViewDelegate;

//
//  Tiles the subviews.
//

- (void)tileSubviews;

//
//  Recomputes the content size and repositions all visible views.
//

- (void)recomputeContentSize;

//
//  Gets a recycled view, or nil if there are no recycled views available.
//

- (UIView *)dequeueView;

//
//  Sets the page index, with control over animating the transition.
//

- (void)setCurrentPageIndex:(NSUInteger)currentPageIndex animated:(BOOL)animated;

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@protocol BDPagingViewDelegate <NSObject>

//
//  Return the total number of pages.
//

- (NSUInteger)pagingViewCountOfPages:(BDPagingView *)pagingView;

//
//  Gets a specific page.
//

- (UIView *)pagingView:(BDPagingView *)pagingView pageAtIndex:(NSUInteger)index;

@optional

//
//  The user has moved to a specific page.
//

- (void)pagingView:(BDPagingView *)pagingView didMoveToPage:(NSUInteger)index;

@end