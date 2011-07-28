//
//  BDGridViewController.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 4/21/11.
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

#import "BDGridCell.h"
#import "BDGridView.h"
#import "BDContrainPanGestureRecognizer.h"

#define kEditModeFrameInset       ((CGFloat)13.0)
#define kAnimationDuration        (0.1)

//
//  Constants for |BDConstrainPanGestureRecognizer|
//

#define kMoveCellMinX             (25)
#define kMoveCellMaxY             (10)

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface BDGridView ()

//
//  The cells that are currently in view.
//

@property (nonatomic, retain) NSMutableSet *viewCells;

//
//  The cells that have been recycled.
//

@property (nonatomic, retain) NSMutableSet *recycledCells;

//
//  The cells that are currently selected.
//

@property (nonatomic, retain) NSMutableSet *selectedCells;

//
//  The active insertion point (for pasting).
//  NSNotFound means no active insertion point.
//

@property (nonatomic, assign) NSUInteger insertionPoint;

//
//  The active gap (for rearranging photos).
//  NSNotFound means there is no active gap.
//

@property (nonatomic, assign) NSUInteger activeGap;

//
//  This is the cell that the user is panning around the screen.
//

@property (nonatomic, retain) BDGridCell *pannedCell;

//
//  The target rectangle of the edit menu.
//

@property (nonatomic, assign) CGRect editMenuTarget;

//
//  The gesture recognizer for rearranging cells.
//

@property (nonatomic, retain) BDContrainPanGestureRecognizer *cellPanRecognizer;

//
//  Private methods; commented with the code.
//

- (void)setup;
- (CGFloat)topPaddingIncludingHeader;
- (void)recomputeContentSize;
- (NSUInteger)indexForPoint:(CGPoint)point;
- (BOOL)isCellVisible:(NSUInteger)index;
- (void)configureCell:(BDGridCell *)cell;
- (void)selectCell:(BDGridCell *)cell;
- (void)unselectCell:(BDGridCell *)cell;
- (void)unselectAllCells;
- (void)toggleCellSelection:(BDGridCell *)cell;
- (void)adjustAllVisibleCellFrames;
- (void)tileCells;
- (void)handleTap:(UITapGestureRecognizer *)tapGesture;
- (void)handleLongTap:(UILongPressGestureRecognizer *)gestureRecognizer;
- (void)handleCellPan:(BDContrainPanGestureRecognizer *)panGesture;
- (void)addNew;
- (CGSize)sizeForIndex:(NSUInteger)index;

@end


@implementation BDGridView

@synthesize viewCells = viewCells_;
@synthesize recycledCells = recycledCells_;
@synthesize selectedCells = selectedCells_;
@synthesize insertionPoint = insertionPoint_;
@synthesize activeGap = activeGap_;
@synthesize pannedCell = pannedCell_;
@synthesize padding = padding_;
@synthesize editMenuTarget = editMenuTarget_;
@synthesize cellPanRecognizer = cellPanRecognizer_;
@synthesize dataSource = dataSource_;
@synthesize gridViewDelegate = gridViewDelegate_;
@synthesize minimumPadding = minimumPadding_;
@synthesize topContentPadding = topContentPadding_;
@synthesize headerView = headerView_;
@synthesize cellsPerRow = cellsPerRow_;
@synthesize countOfRows = countOfRows_;
@synthesize dropCapWidth = dropCapWidth_;
@synthesize dropCapHeight = dropCapHeight_;
@synthesize labelBackgroundColor = labelBackgroundColor_;
@synthesize fontColor = fontColor_;
@synthesize font = font_;
@synthesize firstVisibleIndex = firstVisibleIndex_;
@synthesize lastVisibleIndex = lastVisibleIndex_;

////////////////////////////////////////////////////////////////////////////////
//
//  Initialization.
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
//  Init with coder -- used when loading from a nib.
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
//  Dealloc.
//

- (void)dealloc {
  
  [headerView_ release];
  [viewCells_ release];
  [recycledCells_ release];
  [selectedCells_ release];
  [labelBackgroundColor_ release];
  [fontColor_ release];
  [font_ release];
  [pannedCell_ release];
  [cellPanRecognizer_ release];
  [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Common setup.
//

- (void)setup {
  
  viewCells_ = [[NSMutableSet alloc] initWithCapacity:5];
  recycledCells_ = [[NSMutableSet alloc] initWithCapacity:5];
  selectedCells_ = [[NSMutableSet alloc] initWithCapacity:1];
  activeGap_ = NSNotFound;
  insertionPoint_ = NSNotFound;
  minimumPadding_ = kMinimumPadding;
  
  //
  //  By default, we don't do any fancy drop-capping.
  //
  
  dropCapWidth_ = dropCapHeight_ = 1;
  
  UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)] autorelease];
  tap.cancelsTouchesInView = NO;
  [self addGestureRecognizer:tap];
  
  UILongPressGestureRecognizer *longPress = [[[UILongPressGestureRecognizer alloc] 
                                              initWithTarget:self 
                                              action:@selector(handleLongTap:)] autorelease];
  longPress.delegate = self;
  [self addGestureRecognizer:longPress];
  
  self.cellPanRecognizer = [[[BDContrainPanGestureRecognizer alloc]
                             initWithTarget:self 
                             action:@selector(handleCellPan:)] autorelease];
  self.cellPanRecognizer.delegate = self;
  self.cellPanRecognizer.dx = kMoveCellMinX;
  self.cellPanRecognizer.dy = kMoveCellMaxY;
  [self addGestureRecognizer:self.cellPanRecognizer];

  //
  //  Make sure we have a valid default font color.
  //
  
  self.fontColor = [UIColor blackColor];
  self.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
  
  //
  //  Add our custom menu item ("Add")
  //
  
  UIMenuController *editMenu = [UIMenuController sharedMenuController];
  UIMenuItem *addItem = [[[UIMenuItem alloc] initWithTitle:@"Add" action:@selector(addNew)] autorelease];
  editMenu.menuItems = [NSArray arrayWithObject:addItem];
}

#pragma mark -
#pragma mark Properties

////////////////////////////////////////////////////////////////////////////////
//
//  A little bit of debug sanity... nothing in |viewCells| should have the
//  index |activeGap|.
//

- (void)validateViewCellsAndActiveGap {
  
  for (BDGridCell *cell in self.viewCells) {
    
    _GTMDevAssert(cell.index != self.activeGap, 
                  @"Found cell with index %d!", cell.index);
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  Sets the active gap w/ animation control.
//

- (void)setActiveGap:(NSUInteger)desiredActiveGap
            animated:(BOOL)animated {
  
  [self validateViewCellsAndActiveGap];
  if (activeGap_ != desiredActiveGap) {
    
    //
    //  We're going to change the active gap. To do that, we adjust the 
    //  index of everything currently in view.
    //
    
    if (desiredActiveGap < activeGap_) {
      
      //
      //  We're trying to move the gap lower. Adjust of objects UP to 
      //  "fill in" the current gap and make room for the desired gap.
      //
      
      for (BDGridCell *cell in self.viewCells) {
        
        if (cell.index >= desiredActiveGap && cell.index < activeGap_) {
          
          cell.index++;
        }
      }
      
    } else {
      
      //
      //  We're trying to move the gap higher. Adjust objects DOWN
      //  to fill in the current gap and make room for the desired gap.
      //
      
      for (BDGridCell *cell in self.viewCells) {
        
        if (cell.index > activeGap_ &&
            cell.index <= desiredActiveGap) {
          
          cell.index--;
        }
      }
    }
    activeGap_ = desiredActiveGap;
    [self validateViewCellsAndActiveGap];
    if (animated) {
      
      [UIView animateWithDuration:0.2 
                            delay:0 
                          options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction 
                       animations:
       ^(void) {
        
        [self adjustAllVisibleCellFrames];
      } completion:nil];
      
    } else {
      
      [self adjustAllVisibleCellFrames];
    }
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  This is the cell that we're moving about the screen. Remove it from
//  |viewCells| when set, and return to |viewCells| when unset.
//
//  Note this has the side effect of updating |activeGap|, as adding the
//  cell to the panning area makes a gap where it once was.
//

- (void)setPannedCell:(BDGridCell *)pannedCell {
  
  if (self.pannedCell != nil) {
    
    //
    //  Drop the object in |self.pannedCell| back into the tracked views.
    //  It's going to go into the gap, so adjust its index accordingly.
    //

    self.pannedCell.index = self.activeGap;
    [self.viewCells addObject:self.pannedCell];
  }
  [pannedCell_ autorelease];
  pannedCell_ = [pannedCell retain];
  if (self.pannedCell != nil) {
    
    [self.viewCells removeObject:self.pannedCell];
    activeGap_ = self.pannedCell.index;
    
  } else {
    
    activeGap_ = NSNotFound;
  }
  _GTMDevAssert(![self.viewCells containsObject:pannedCell], 
                @"Panned cell should no longer be visible");
}

////////////////////////////////////////////////////////////////////////////////

- (void)setLabelBackgroundColor:(UIColor *)labelBackgroundColor {
  
  if (labelBackgroundColor == labelBackgroundColor_) {
    
    return;
  }
  [labelBackgroundColor_ release];
  labelBackgroundColor_ = [labelBackgroundColor retain];
  
  for (BDGridCell *cell in self.viewCells) {
    
    cell.labelBackgroundColor = self.labelBackgroundColor;
  }
  [self setNeedsLayout];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Update the font color for all visible cells.
//

- (void)setFontColor:(UIColor *)fontColor {

  _GTMDevAssert(fontColor != nil, @"Font color must not be nil");
  [fontColor_ autorelease];
  fontColor_ = [fontColor retain];
  
  for (BDGridCell *cell in self.viewCells) {
    
    cell.fontColor = self.fontColor;
  }
  [self setNeedsLayout];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Update the font for all visible cells.
//

- (void)setFont:(UIFont *)font {
  
  [font_ autorelease];
  font_ = [font retain];
  
  for (BDGridCell *cell in self.viewCells) {
    
    cell.font = self.font;
  }
  [self setNeedsLayout];
}

////////////////////////////////////////////////////////////////////////////////
//
//  When setting a new header view, ensure that we account for it in the 
//  padding.
//

- (void)setHeaderView:(UIView *)headerView {
  
  if (headerView == headerView_) {
    return;
  }
  if (headerView_ != nil) {
    
    [headerView_ removeFromSuperview];
  }
  [headerView_ release];
  headerView_ = [headerView retain];
  if (headerView_ != nil) {
    
    CGSize frameSize = headerView_.frame.size;
    headerView_.frame = CGRectMake(0, topContentPadding_, frameSize.width, frameSize.height);
    [self addSubview:headerView_];
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  When setting |topContentPadding|, need to adjust the position of any
//  header view.
//

- (void)setTopContentPadding:(CGFloat)topContentPadding {
  
  topContentPadding_ = topContentPadding;
  if (headerView_ != nil) {
    
    CGSize frameSize = headerView_.frame.size;
    headerView_.frame = CGRectMake(0, topContentPadding_, frameSize.width, frameSize.height);
  }
}

#pragma mark - Logical / Grid Index translation

////////////////////////////////////////////////////////////////////////////////

- (NSUInteger)cellIndexForGridIndex:(NSUInteger)gridIndex {
  
  //
  //  Get the grid row & column that correspond to this index.
  //
  
  NSUInteger row = gridIndex / self.cellsPerRow;
  NSUInteger column = gridIndex % self.cellsPerRow;
  
  if ((column < self.dropCapWidth) && (row < self.dropCapHeight)) {
    
    //
    //  If both the row & column index are less than the drop cap dimensions,
    //  then we're looking at the first cell.
    //
    
    return 0;
  }
  
  if (row < self.dropCapHeight) {
    
    //
    //  We're in the "truncated" region of the grid. Here, you don't get a 
    //  full row of new cells for each row of the grid, because part of the
    //  row is taken up by the drop cap.
    //
    
    _GTMDevAssert(self.cellsPerRow > self.dropCapWidth, 
                  @"Must have enough cells per row to accomodate the drop cap");
    _GTMDevAssert(column >= self.dropCapWidth,
                  @"The column value must be in the truncated region of the grid");
    NSUInteger truncatedCellsPerRow = self.cellsPerRow - self.dropCapWidth;
    return 1 + (row * truncatedCellsPerRow) + (column - self.dropCapWidth);
  }
  
  //
  //  In this case, we're in the "full" portion of the grid. Each row gets a
  //  full row of new cells.
  //
  
  NSUInteger firstFullIndex = 1 + (self.cellsPerRow - self.dropCapWidth) * self.dropCapHeight;
  return firstFullIndex + ((row - self.dropCapHeight) * self.cellsPerRow) + column;
}

////////////////////////////////////////////////////////////////////////////////

- (NSUInteger)gridIndexForCellIndex:(NSUInteger)cellIndex {
  
  if (cellIndex == 0) {
    
    //
    //  This is the same no matter what drop cap we're using.
    //
    
    return 0;
  }
  
  //
  //  Compute the first index in the "full" region of the grid.
  //  This is the region below the drop cap, that gets a full complement of 
  //  cells in each row.
  //
  
  NSUInteger row, column;
  NSUInteger firstFullRegionIndex = 1 + (self.cellsPerRow - self.dropCapWidth) * self.dropCapHeight;
  if (cellIndex < firstFullRegionIndex) {
    
    //
    //  We're in the truncated region. Compute the corresponding grid index.
    //
    
    NSUInteger cellsPerTruncatedRow = self.cellsPerRow - self.dropCapWidth;
    row = (cellIndex - 1) / cellsPerTruncatedRow;
    column = self.dropCapWidth + ((cellIndex - 1) % cellsPerTruncatedRow);
    
  } else {
    
    //
    //  We're in the full region. 
    //
    
    NSUInteger indexIntoFullRegion = cellIndex - firstFullRegionIndex;
    row = self.dropCapHeight + indexIntoFullRegion / self.cellsPerRow;
    column = indexIntoFullRegion % self.cellsPerRow;
  }
  
  return row * self.cellsPerRow + column;
}

////////////////////////////////////////////////////////////////////////////////

- (NSUInteger)countOfGridRowsGivenCellsPerRow:(NSUInteger)cellsPerRow {
  
  CGFloat numberOfCells = [self.dataSource gridViewCountOfCells:self];
  
  //
  //  Simple adjustment for drop cap.
  //
  
  numberOfCells += (dropCapWidth_ * dropCapHeight_) - 1;
  return MAX(1, ceil(numberOfCells / cellsPerRow));
}

#pragma mark -
#pragma mark Cell management

////////////////////////////////////////////////////////////////////////////////
//
//  The amount of top padding.
//

- (CGFloat)topPaddingIncludingHeader {
  
  CGFloat topPadding = self.topContentPadding;
  if (self.headerView != nil) {
    
    topPadding += self.headerView.frame.size.height;
  }
  return topPadding;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Recomputes the content size. Should be called when either |self.view.frame|
//  changes or [self numberOfCells] changes.
//

- (void)recomputeContentSize {

  CGSize cellSize = [self.dataSource gridViewSizeOfCell:self];
  CGFloat width = MAX(cellSize.width,
                      CGRectGetWidth(self.frame));
  
  //
  //  These are floats so we don't do integer arithmetic in the computation
  //  for |totalRows|.
  //
  
  CGFloat cellsPerRow = MAX(1, floor(width / cellSize.width));
  cellsPerRow_ = round(cellsPerRow);
  countOfRows_ = [self countOfGridRowsGivenCellsPerRow:cellsPerRow_];
  
  //
  //  Adjust |cellsPerRow| until |padding| is at least |kMinimumPadding|.
  //
  
  do {

    //
    //  Compute the "slop" in the layout. This is horizontal space left after
    //  placing |self.cellsPerRow| cells in a row. We want to distribute that 
    //  slop evenly between each column... this is |padding|.
    //
    
    CGFloat slop = CGRectGetWidth(self.bounds) - self.cellsPerRow * cellSize.width;
    padding_ = MAX(0, slop / (self.cellsPerRow + 1));
    if (padding_ < self.minimumPadding) {
      
      cellsPerRow_--;
      countOfRows_ = [self countOfGridRowsGivenCellsPerRow:cellsPerRow_];
    }
  } while (padding_ < self.minimumPadding);
  
  self.contentSize = CGSizeMake(width, 
                                countOfRows_ * cellSize.height + [self topPaddingIncludingHeader]);
  
  //
  //  If the content size height is greater than the bounds height, then the
  //  user will need to scroll vertically to see everything. In that case, we
  //  must enforce that the cellPanRecognizer start only with a horizontal
  //  motion. Otherwise, the cellPanRecognizer is free to recognize any panning
  //  gesture.
  //
  
  self.cellPanRecognizer.enforceConstraints = self.contentSize.height > self.bounds.size.height;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Computes the cell index for a point in the view.
//

- (NSUInteger)indexForPoint:(CGPoint)point {
  
  CGSize cellSize = [self.dataSource gridViewSizeOfCell:self];

  CGFloat pointRow = floor((point.y - [self topPaddingIncludingHeader]) / cellSize.height);
  CGFloat pointColumn = floor(point.x / (cellSize.width + self.padding));
  
  return [self cellIndexForGridIndex:round(pointRow * self.cellsPerRow + pointColumn)];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Are we showing a particular cell?
//

- (BOOL)isCellVisible:(NSUInteger)index {
  
  BOOL cellFound = NO;

  if (self.pannedCell != nil &&
      self.pannedCell.index == index) {
    return YES;
  }
  if (index == self.activeGap) {
    
    return YES;
  }
  for (BDGridCell *cell in viewCells_) {
    
    if (cell.index == index) {
      cellFound = YES;
      break;
    }
  }
  return cellFound;
}

////////////////////////////////////////////////////////////////////////////////

- (CGSize)sizeForIndex:(NSUInteger)index {
  
  CGSize cellSize = [self.dataSource gridViewSizeOfCell:self];
  
  if (index == 0) {
    
    //
    //  This is the "drop cap" index. Adjust the cell size appropriately.
    //
    
    cellSize.width = self.dropCapWidth * (cellSize.width + self.padding) - self.padding;
    cellSize.height = self.dropCapHeight * cellSize.height;
  }
  return cellSize;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Computes the frame for a particular cell.
//

- (CGRect)frameForCellAtIndex:(NSUInteger)index {

  index = [self gridIndexForCellIndex:index];
  NSUInteger targetRow = index / self.cellsPerRow;
  NSUInteger targetColumn = index % self.cellsPerRow;
  CGSize cellSize = [self sizeForIndex:index];

  //
  //  Compute the origin of this cell. Note there is |self.padding| pixels 
  //  of padding between each column, including before the first and after the
  //  last.
  //
  
  CGPoint cellOrigin = CGPointMake(targetColumn * (cellSize.width + self.padding) + self.padding, 
                                   targetRow * cellSize.height + [self topPaddingIncludingHeader]);
  CGRect frame = CGRectMake(cellOrigin.x,
                            cellOrigin.y,
                            cellSize.width, 
                            cellSize.height);
  return frame;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Put a cell into |scrollView| at the proper location.
//  |cell.index| must be correctly set prior to sending this message.
//

- (void)configureCell:(BDGridCell *)cell {
  
  CGRect newFrame = [self frameForCellAtIndex:cell.index];
  CGRect oldFrame = cell.frame;
  cell.frame = [self frameForCellAtIndex:cell.index];
  if (newFrame.size.width != oldFrame.size.width) {
    
    [cell setNeedsDisplay];
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  Selects a cell.
//

- (void)selectCell:(BDGridCell *)cell {
  
  _GTMDevAssert(selectedCells_ != nil, @"selectedCells_ should be initialized");
  
  //
  //  If a cell is selected, the insertion point is before the cell.
  //
  
  self.insertionPoint = cell.index;
  
  //
  //  Right now we only do single selection.
  //
  
  [self unselectAllCells];
  [selectedCells_ addObject:cell];
  cell.selected = YES;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Unselects a cell.
//

- (void)unselectCell:(BDGridCell *)cell {
  
  _GTMDevAssert(selectedCells_ != nil, @"selectedCells_ should be initialized");
  [selectedCells_ removeObject:cell];
  cell.selected = NO;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Unselects all selected cells.
//

- (void)unselectAllCells {
  
  for (BDGridCell *cell in selectedCells_) {
    
    cell.selected = NO;
  }
  [selectedCells_ removeAllObjects];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Toggles cell selection state.
//

- (void)toggleCellSelection:(BDGridCell *)cell {
  
  if ([cell isSelected]) {
    
    [self unselectCell:cell];
    
  } else {
    
    [self selectCell:cell];
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  Reconfigures all visible cells. Useful to do after the content size has
//  changed.
//

- (void)adjustAllVisibleCellFrames {

  if (headerView_ != nil) {
    
    //
    //  The width of the header view will get bounded by |padding| on both
    //  sides.
    //
    
    CGRect frame = headerView_.frame;
    frame.origin.x = self.padding;
    frame.size.width = self.bounds.size.width - 2 * self.padding;
    headerView_.frame = frame;
  }
  for (BDGridCell *cell in self.viewCells) {
    
    [self configureCell:cell];
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  Adjust the layout of everything in the view.
//

- (void)layoutSubviews {

  [self recomputeContentSize];
  [self tileCells];
  [self adjustAllVisibleCellFrames];
}

////////////////////////////////////////////////////////////////////////////////
//
//  I manually adjust every subview.
//

- (BOOL)autoresizesSubviews {
  
  return NO;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Layout the visible cells.
//
//  General algorithm comes from the Apple "PhotoScroller" example.
//

- (void)tileCells {

  CGRect visibleBounds = self.bounds;
  CGSize cellSize = [self.dataSource gridViewSizeOfCell:self];
  CGFloat topPaddingIncludingHeader = [self topPaddingIncludingHeader];
  visibleBounds = CGRectOffset(visibleBounds, 0, -1.0 * topPaddingIncludingHeader);
  CGFloat firstVisibleRow = floor(CGRectGetMinY(visibleBounds) / cellSize.height);
  firstVisibleRow = MAX(0, firstVisibleRow);
  CGFloat lastVisibleRow  = floor((CGRectGetMaxY(visibleBounds)-1) / cellSize.height);
  NSUInteger firstVisibleCell = firstVisibleRow * self.cellsPerRow;
  firstVisibleCell = [self cellIndexForGridIndex:firstVisibleCell];
  
  NSInteger countOfCells = [self.dataSource gridViewCountOfCells:self];
  
  //
  //  Adjust |countOfCells| to account for additional space consumed by the drop
  //  cap.
  //
  
//  countOfCells += (self.dropCapHeight * self.dropCapWidth) - 1;
  NSInteger firstNonVisibleIndex = (lastVisibleRow + 1) * self.cellsPerRow;
  
  //
  //  What we just computed was a grid index. Convert it to a cell index.
  //  Do a little bit of trickery to make we don't hit the drop cap.
  //
  
  firstNonVisibleIndex = [self cellIndexForGridIndex:firstNonVisibleIndex - 1] + 1;
  
  //
  //  Cap the first non-visible index as the count of cells.
  //
  
  firstNonVisibleIndex = MIN(countOfCells, firstNonVisibleIndex);
  
  _GTMDevAssert(viewCells_ != nil, @"viewCells must not be nil");
  _GTMDevAssert(recycledCells_ != nil, @"recycledCells must not be nil");
  firstVisibleIndex_ = firstVisibleCell;
  lastVisibleIndex_ = firstNonVisibleIndex;
  
  //
  //  Go through the currently visible cells and remove the ones we no longer 
  //  need.
  //
  
  for (BDGridCell *cell in viewCells_) {
    
    NSUInteger displayIndex = cell.index;
    if (displayIndex >= self.activeGap) {
      
//      displayIndex++;
    }
    if ((displayIndex < firstVisibleCell) || (displayIndex >= firstNonVisibleIndex)) {

      [recycledCells_ addObject:cell];
      [cell removeFromSuperview];
    }
  }
  [viewCells_ minusSet:recycledCells_];
  
  //
  //  Go through each expected index and make sure we are showing the
  //  necessary cell.
  //
  
  for (NSInteger i = firstVisibleCell; i < firstNonVisibleIndex; i++) {
    _GTMDevAssert(i < countOfCells, 
                  @"Should not look for something out of bounds");
    if (![self isCellVisible:i]) {

      BDGridCell *cell = [self.dataSource gridView:self cellForIndex:i];
      if (cell != nil) {
        cell.index = i;
        cell.fontColor = self.fontColor;
        cell.font = self.font;
        cell.labelBackgroundColor = self.labelBackgroundColor;
        [viewCells_ addObject:cell];
        [self configureCell:cell];
        [self addSubview:cell];
      }
    }
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  Reloads all of the cells in the grid.
//

- (void)reloadData {
  
  for (BDGridCell *cell in viewCells_) {
    [recycledCells_ addObject:cell];
    [cell removeFromSuperview];
  }
  [viewCells_ minusSet:recycledCells_];
  _GTMDevAssert([self.viewCells count] == 0, @"Should be no visible cells");
  [self recomputeContentSize];
  [self tileCells];
  [self adjustAllVisibleCellFrames];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Animates the insertion of a cell at |index|. This means any cell that's
//  currently visible with an index >= |index| needs to get its index and frame
//  adjusted. This makes room for the new cell. Then, we plop the new cell
//  into location.
//
//  Returns the inserted cell.
//

- (BDGridCell *)insertCellAtIndex:(NSUInteger)index {

  [self recomputeContentSize];
  [UIView animateWithDuration:0.5 animations:^(void) {
    
    // 
    //  Go through each view cell and adjust index & frame if needed.
    //
    
    for (BDGridCell *cell in viewCells_) {
      
      if (cell.index >= index) {
        
        cell.index++;
        [self configureCell:cell];
        if (!CGRectIntersectsRect(cell.frame, self.bounds)) {
          
          //
          //  The cell is no longer visible. Remove it.
          //
          
          [cell removeFromSuperview];
          [self.recycledCells addObject:cell];
        }
      }
    }
  }];
  
  [self.viewCells minusSet:self.recycledCells];
  
  BDGridCell *insertedCell = [self.dataSource gridView:self cellForIndex:index];
  insertedCell.alpha = 0.0;
  if (insertedCell != nil) {
    insertedCell.index = index;
    insertedCell.fontColor = self.fontColor;
    insertedCell.font = self.font;
    [viewCells_ addObject:insertedCell];
    [self configureCell:insertedCell];
    [self addSubview:insertedCell];
  }
  
  //
  //  Fade in.
  //
  
  [UIView animateWithDuration:0.5 animations:^(void) {
    insertedCell.alpha = 1.0;
  }];
  
  return insertedCell;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Deletes the cell at |index|. Fades the cell out and then shifts all other
//  cells to fill the gap.
//

- (void)deleteCellAtIndex:(NSUInteger)index {
  
  NSSet *victims = [viewCells_ objectsPassingTest:^BOOL(id obj, BOOL *stop) {
    
    if (((BDGridCell *)obj).index == index) {
      
      *stop = YES;
      return YES;
    }
    return NO;
  }];
  
  //
  //  Fade out all deleted cells.
  //
  
  _GTMDevAssert([victims count] <= 1, @"Shouldn't be more than one victim");
  [UIView animateWithDuration:0.5 animations:^(void) {
    
    for (BDGridCell *victim in victims) {
      
      victim.alpha = 0.0;
    }
  } completion:^(BOOL finished) {
    
    for (BDGridCell *victim in victims) {
      
      [victim removeFromSuperview];
      [viewCells_ removeObject:victim];
    }
  }];
  
  //
  //  Shift remaining cells.
  //
  
  [UIView animateWithDuration:0.5 animations:^(void) {
    
    for (BDGridCell *cell in viewCells_) {
      
      if (cell.index > index) {
        
        cell.index--;
        [self configureCell:cell];
      }
    }
    
  } completion:^(BOOL finished) {

    //
    //  |tileCells| will bring in any new cells that we need.
    //  It looks strange if it's animated.
    //
    
    [self tileCells];
  }];
}


////////////////////////////////////////////////////////////////////////////////
//
//  Gets a cell from |recycledCells| (if one is available), otherwise returns nil.
//  Copied from Apple's PhotoScroller example.
//

- (BDGridCell *)dequeueCell {
  
  BDGridCell *cell = [self.recycledCells anyObject];
  if (cell != nil) {
    [[cell retain] autorelease];
    [self.recycledCells removeObject:cell];
  }
  return cell;
}

#pragma mark -
#pragma mark Touch

////////////////////////////////////////////////////////////////////////////////
//
//  Determine if we should be handling the gesture.
//

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
  
  if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
    
    //
    //  We always recognize single taps.
    //
    
    return YES;
  }
  
  BOOL isConstrainPanGestureRecognizer = [gestureRecognizer isKindOfClass:[BDContrainPanGestureRecognizer class]];
  BOOL isLongPressGestureRecognizer    = [gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]];
  
  //
  //  For the other kinds of taps, it will depend upon if we allow editing.
  //
  
  if ([self.gridViewDelegate respondsToSelector:@selector(gridViewShouldEdit:)] &&
      (isConstrainPanGestureRecognizer || isLongPressGestureRecognizer) &&
      ![self.gridViewDelegate gridViewShouldEdit:self]) {
    
    return NO;
  }
  
  //
  //  OK, we allow editing. But if this is a pan, we only recognize the gesture
  //  if the delegate will be able to respond to it.
  //
  
  if (isConstrainPanGestureRecognizer) {
    
    return [self.gridViewDelegate respondsToSelector:@selector(gridView:didMoveItemFromIndex:toIndex:)];
    
  } else {
    
    return YES;
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  The user has done a single-finger tap. 
//
//  If we are not in edit mode, notify the delegate if the user tapped a cell.
//  If we are in edit mode, tapping a cell selects it.
//

- (void)handleTap:(UITapGestureRecognizer *)tapGesture {

  if (tapGesture.state == UIGestureRecognizerStateEnded) {
    
    CGPoint tapLocation = [tapGesture locationInView:self];
    UIView *subview = [self hitTest:tapLocation withEvent:nil];
    _GTMDevLog(@"%s -- hit test %@", __PRETTY_FUNCTION__, [subview description]);
    UIMenuController *editMenu = [UIMenuController sharedMenuController];
    if (editMenu.menuVisible) {

      //
      //  All we want to do is unselect & clear.
      //
      
      [self unselectAllCells];
      [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
      return;
    }
    if ([subview isKindOfClass:[BDGridCell class]]) {
      
      if ([self.gridViewDelegate respondsToSelector:@selector(gridView:didTapCell:)]) {
        
        [self.gridViewDelegate gridView:self didTapCell:(BDGridCell *)subview];
      }
    }
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  The user has done a long tap. Bring up the edit menu.
//

- (void)handleLongTap:(UILongPressGestureRecognizer *)gestureRecognizer {
  
  if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
    
    BOOL shouldShowEditMenu = NO;
    CGPoint location = [gestureRecognizer locationInView:self];
    UIView *subview = [self hitTest:location withEvent:nil];
    UIMenuController *editMenu = [UIMenuController sharedMenuController];
    [self becomeFirstResponder];
    if ([subview isKindOfClass:[BDGridCell class]]) {
      
      //
      //  We're on a cell. Select it and bring up the edit menu.
      //
      
      [self selectCell:(BDGridCell *)subview];
      self.editMenuTarget = subview.frame;
      shouldShowEditMenu = YES;
    }
    if ([subview isKindOfClass:[BDGridView class]]) {
      
      //
      //  We're looking at empty space. Turn that into an insertion point.
      //
      
      [self unselectAllCells];
      CGPoint tapLocation = [gestureRecognizer locationInView:self];
      NSUInteger insertionPoint = [self indexForPoint:tapLocation];
      if (insertionPoint > [self.dataSource gridViewCountOfCells:self]) {
        insertionPoint = [self.dataSource gridViewCountOfCells:self];
      }
      self.insertionPoint = insertionPoint;
      self.editMenuTarget = CGRectMake(tapLocation.x, tapLocation.y, 3, 3);
      shouldShowEditMenu = YES;
    }
    if (shouldShowEditMenu) {
      
      [editMenu setTargetRect:self.editMenuTarget inView:self];
      [editMenu setMenuVisible:YES animated:YES];
    }
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  The user is trying to pan an individual cell around.
//

- (void)handleCellPan:(BDContrainPanGestureRecognizer *)panGesture {
  
  if (![self.gridViewDelegate respondsToSelector:@selector(gridView:didMoveItemFromIndex:toIndex:)]) {
    
    //
    //  Don't do anything of the delegate can't handle it.
    //
    
    panGesture.state = UIGestureRecognizerStateFailed;
    return;
  }
  
  //
  //  The initial frame of |self.pannedCell|. All translation adjustments are
  //  done from this.
  //
  
  static CGRect initialFrame;
  UIView *subview = nil;
  
  switch (panGesture.state) {
    case UIGestureRecognizerStateBegan:
      subview = [self hitTest:panGesture.initialTouchPoint withEvent:nil];
      if ([subview isKindOfClass:[BDGridCell class]]) {
        
        self.pannedCell = (BDGridCell *)subview;
        initialFrame = self.pannedCell.frame;
        [self bringSubviewToFront:self.pannedCell];
        [UIView animateWithDuration:0.1 
                              delay:0.0 
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                         animations:
         ^(void) {

          self.pannedCell.frame = CGRectOffset(initialFrame,
                                               panGesture.translation.x,
                                               panGesture.translation.y);
          
        } completion:nil];
        _GTMDevAssert([self indexForPoint:panGesture.initialTouchPoint] == self.pannedCell.index,
                      @"Should compute the right gap index");
        
      } else {
        
        self.pannedCell = nil;
      }
      break;
      
    case UIGestureRecognizerStateFailed:
      _GTMDevLog(@"%s -- gesture recognizer failed", __PRETTY_FUNCTION__);
      self.pannedCell = nil;
      break;
      
    case UIGestureRecognizerStateEnded:
      _GTMDevLog(@"%s -- gesture recognizer ended", __PRETTY_FUNCTION__);
      if ((self.pannedCell != nil) && (self.activeGap != self.pannedCell.index)) {
      
        NSUInteger maxIndex = [self.dataSource gridViewCountOfCells:self] - 1;
        self.activeGap = MIN(maxIndex, self.activeGap);
        [self.gridViewDelegate gridView:self 
                   didMoveItemFromIndex:self.pannedCell.index 
                                toIndex:self.activeGap];
      }
      
      [UIView animateWithDuration:0.2 
                            delay:0.0 
                          options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                       animations:
       ^(void) {

        self.pannedCell = nil;
        
        //
        //  Note we're controlling the animation in this block. Don't nest.
        //
        
        [self adjustAllVisibleCellFrames];
      } completion:nil];
      break;
      
    default:
      
      if (self.pannedCell != nil) {
        
        [self setActiveGap:[self indexForPoint:panGesture.currentTouchPoint] animated:YES];
        self.pannedCell.frame = CGRectOffset(initialFrame, 
                                             panGesture.translation.x, 
                                             panGesture.translation.y);
      }
      break;
  }
}

#pragma mark -
#pragma mark Cut, copy, paste

////////////////////////////////////////////////////////////////////////////////
//
//  We can become the first responder. Needed to make cut/copy/paste work.
//

- (BOOL)canBecomeFirstResponder {
  return YES;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Check the delegate to see what operations are supported.
//

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
  
  //
  //  Check and see if the delegate does a global override on editing.
  //
  
  if ([self.gridViewDelegate respondsToSelector:@selector(gridViewShouldEdit:)] &&
      ![self.gridViewDelegate gridViewShouldEdit:self]) {
    
    return NO;
  }
  
  if (action == @selector(cut:)) {
    
    return ([self.selectedCells count] > 0) &&
      [self.gridViewDelegate respondsToSelector:@selector(gridView:didCut:)];
  }
  if (action == @selector(copy:)) {
    
    return ([self.selectedCells count] > 0) &&
      [self.gridViewDelegate respondsToSelector:@selector(gridView:didCopy:)];
  }
  if (action == @selector(paste:)) {
    
    if (self.insertionPoint == NSNotFound) {
      return NO;
    }
    if ([self.gridViewDelegate respondsToSelector:@selector(gridViewCanPaste:)]) {
      
      //
      //  Note: Any delegate that implements gridViewCanPaste: MUST
      //  also implement gridView:didPasteAtPoint:.
      //
      
      return [self.gridViewDelegate gridViewCanPaste:self];
      
    } else {
      
      return NO;
    }
  }
  if (action == @selector(delete:)) {
    
    return ([self.selectedCells count] > 0) &&
      [self.gridViewDelegate respondsToSelector:@selector(gridView:didDelete:)];
  }
  if (action == @selector(addNew)) {
    
    return [self.gridViewDelegate respondsToSelector:@selector(gridView:didInsertAtPoint:fromRect:)] &&
      (self.insertionPoint != NSNotFound);
  }
  return NO;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Cut.
//

- (void)cut:(id)sender {
  
  _GTMDevLog(@"%s", __PRETTY_FUNCTION__);
  NSMutableSet *indexSet = [NSMutableSet setWithCapacity:[self.selectedCells count]];
  
  for (BDGridCell *cell in self.selectedCells) {
    
    [indexSet addObject:[NSNumber numberWithUnsignedInteger:cell.index]];
  }
  [self unselectAllCells];
  [self.gridViewDelegate gridView:self didCut:indexSet];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Copy.
//

- (void)copy:(id)sender {
  
  NSMutableSet *indexSet = [NSMutableSet setWithCapacity:[self.selectedCells count]];
  
  for (BDGridCell *cell in self.selectedCells) {
    
    [indexSet addObject:[NSNumber numberWithUnsignedInteger:cell.index]];
  }
  [self unselectAllCells];
  [self.gridViewDelegate gridView:self didCopy:indexSet];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Paste.
//

- (void)paste:(id)sender {
  
  _GTMDevLog(@"%s", __PRETTY_FUNCTION__);
  if (([self.selectedCells count] == 1) && 
      ([self.gridViewDelegate respondsToSelector:@selector(gridView:didPasteIntoCell:)])) {
    
    BDGridCell *cell = [self.selectedCells anyObject];
    [self unselectAllCells];
    [self.gridViewDelegate gridView:self didPasteIntoCell:cell];
    
  } else {
    
    [self unselectAllCells];
    [self.gridViewDelegate gridView:self didPasteAtPoint:self.insertionPoint];
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  Delete.
//

- (void)delete:(id)sender {
  
  NSMutableSet *indexSet = [NSMutableSet setWithCapacity:[self.selectedCells count]];
  
  for (BDGridCell *cell in self.selectedCells) {
    
    [indexSet addObject:[NSNumber numberWithUnsignedInteger:cell.index]];
  }
  [self unselectAllCells];
  [self.gridViewDelegate gridView:self didDelete:indexSet];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Add a new item.
//

- (void)addNew {
  
  if (([self.selectedCells count] == 1) && 
      ([self.gridViewDelegate respondsToSelector:@selector(gridView:didInsertIntoCell:)])) {
    
    BDGridCell *cell = (BDGridCell *)[self.selectedCells anyObject];
    [self unselectAllCells];
    [self.gridViewDelegate gridView:self didInsertIntoCell:cell];
    
  } else {
    
    [self unselectAllCells];
    [self.gridViewDelegate gridView:self 
                   didInsertAtPoint:self.insertionPoint 
                           fromRect:self.editMenuTarget];
  }
}

@end
