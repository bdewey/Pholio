//
//  BDGridViewController-test.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 4/22/11.
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

#import "GTMSenTestCase.h"
#import <UIKit/UIKit.h>
#import <OCMock/OCMock.h>
#import "BDGridView.h"
#import "BDGridCell.h"
#import "BDContrainPanGestureRecognizer.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
//  Simple class that conforms to |BDGridViewDelegate| but does not 
//  implement any methods.
//

@interface TestGridViewDelegate : NSObject<BDGridViewDelegate> { }

@end

@implementation TestGridViewDelegate


@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
//  Private methods/properties that I know exist in BDGridView. Declare them 
//  here to quiet the compiler.
//

@interface BDGridView (BDGridView_test)

@property (nonatomic, assign) NSUInteger insertionPoint;

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
//  The main test class.
//

@interface BDGridViewController_test: GTMTestCase<
BDGridViewDataSource> 
{ }

//
//  How many cells this test controller has.
//

@property (nonatomic, assign) NSInteger testCellCount;

//
//  Intended cell size.
//

@property (nonatomic, assign) CGSize testCellSize;

//
//  The set of cells that have been allocated by the view.
//

@property (nonatomic, retain) NSMutableSet *allocatedCells;

//
//  Clears out our allocated cell tracker.
//

- (void)resetAllocatedCellTracking;

@end


@implementation BDGridViewController_test

@synthesize testCellCount = testCellCount_;
@synthesize testCellSize = testCellSize_;
@synthesize allocatedCells = allocatedCells_;

////////////////////////////////////////////////////////////////////////////////
//
//  Set up the test.
//

- (void)setUp {
  
  allocatedCells_ = [[NSMutableSet alloc] initWithCapacity:15];
  [self resetAllocatedCellTracking];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Tear down -- release all retained properties.
//

- (void)tearDown {
  
  [allocatedCells_ release];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Resets the allocated cell tracking.
//

- (void)resetAllocatedCellTracking {
  
  [self.allocatedCells removeAllObjects];
}

////////////////////////////////////////////////////////////////////////////////
//
//  OVERRIDE. Returns the number of test cells.
//

- (NSUInteger)gridViewCountOfCells:(BDGridView *)gridView {
  
  return testCellCount_;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Returns the size of each cell.
//

- (CGSize)gridViewSizeOfCell:(BDGridView *)gridView {
  
  return testCellSize_;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Gets a cell.
//

- (BDGridCell *)gridView:(BDGridView *)gridView cellForIndex:(NSUInteger)index {
  
  BDGridCell *cell = [gridView dequeueCell];
  if (cell == nil) {
    cell = [[[BDGridCell alloc] initWithStyle:BDGridCellStyleDefault] autorelease];
    [self.allocatedCells addObject:cell];
  }
  
  //
  //  Give it a bogus font color to make sure it gets reset.
  //
  
  cell.fontColor = [UIColor greenColor];
  return cell;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Validates that the view is showing what we expect.
//

- (void)validateView:(BDGridView *)view forTestCase:(NSString *)testCase {

  //
  //  Validate basic dimensions.
  //
  
  CGFloat pageWidth = view.frame.size.width;
  CGFloat topPadding = view.topContentPadding;
  if (view.headerView != nil) {
    
    topPadding += view.headerView.frame.size.height;
  }
  
  //
  //  Note there must be at least one cell per row.
  //
  
  CGFloat expectedCellsPerRow = MAX(1, floor(pageWidth / self.testCellSize.width));
  STAssertEquals((NSUInteger)expectedCellsPerRow, view.cellsPerRow, 
                 @"Expected %f cells per row, found %d",
                 expectedCellsPerRow,
                 view.cellsPerRow);
  CGFloat expectedCountOfRows = MAX(1, ceil((CGFloat)self.testCellCount / expectedCellsPerRow));
  STAssertEquals((NSUInteger)expectedCountOfRows, view.countOfRows,
                 @"Case %@: Expected %f rows, found %d",
                 testCase,
                 expectedCountOfRows,
                 view.countOfRows);
  
  //
  //  Validate the first & last index.
  //
  
  CGPoint contentOffset = view.contentOffset;
  CGFloat pageHeight    = view.frame.size.height;
  CGFloat firstVisibleRow = floor((contentOffset.y - topPadding) / self.testCellSize.height);
  firstVisibleRow = MAX(0, firstVisibleRow);
  
  //
  //  Validate the content size.
  //
  
  CGSize expectedContentSize = CGSizeMake(MAX(pageWidth, self.testCellSize.width),
                                          expectedCountOfRows * self.testCellSize.height + topPadding);
  CFDictionaryRef expectedSizeDictionary = CGSizeCreateDictionaryRepresentation(expectedContentSize);
  CFDictionaryRef actualSizeDictionary   = CGSizeCreateDictionaryRepresentation(view.contentSize);
  STAssertEquals(expectedContentSize,
                 view.contentSize,
                 @"(%@) expected size %@, found %@",
                 testCase,
                 expectedSizeDictionary,
                 actualSizeDictionary);
  CFRelease(expectedSizeDictionary);
  CFRelease(actualSizeDictionary);
                 
  
  //
  //  TODO: Think hard about that "-1" in the line below. Really?
  //
  
  CGFloat lastVisibleRow  = floor((contentOffset.y + pageHeight - topPadding - 1) / self.testCellSize.height);
  NSInteger expectedLastVisibleIndex = ((lastVisibleRow + 1) * expectedCellsPerRow);
  expectedLastVisibleIndex = MIN(self.testCellCount, expectedLastVisibleIndex);
  STAssertEquals((NSInteger)(firstVisibleRow * expectedCellsPerRow),
                 view.firstVisibleIndex,
                 @"(%@) Content offset = %f, test height = %f, cells per row = %f... expected first visible index %f but got %d",
                 testCase,
                 contentOffset.y,
                 self.testCellSize.height,
                 expectedCellsPerRow,
                 firstVisibleRow * expectedCellsPerRow,
                 view.firstVisibleIndex);
  STAssertEquals(expectedLastVisibleIndex,
                 view.lastVisibleIndex,
                 @"Case '%@': Content offset = %f, test height = %f, page height = %f, cells per row = %f, test cell count = %d... expected last visible index %d but got %d",
                 testCase,
                 contentOffset.y,
                 self.testCellSize.height,
                 pageHeight,
                 expectedCellsPerRow,
                 self.testCellCount,
                 expectedLastVisibleIndex,
                 view.lastVisibleIndex);
  
  //
  //  Walk through each allocated cell. Verify that it has a superview only
  //  if its index is in the expected range, and verify its position in the
  //  scroll view is expected.
  //
  
  NSUInteger visibleIndexSum = 0;
  NSUInteger visibleCount    = 0;
  for (int i = view.firstVisibleIndex; i < view.lastVisibleIndex; i++) {
    visibleIndexSum += i;
    visibleCount++;
  }
  NSUInteger observedIndexSum = 0;
  NSUInteger observedCount    = 0;
  for (BDGridCell *cell in self.allocatedCells) {
    
    if (cell.superview != nil) {
      
      //
      //  This is a visible cell. Its index should be in the visible range.
      //
      
      STAssertGreaterThanOrEqual((NSInteger)cell.index, view.firstVisibleIndex, nil);
      STAssertLessThan((NSInteger)cell.index, view.lastVisibleIndex, nil);
      observedIndexSum += cell.index;
      observedCount++;
      
      //
      //  TODO: Validate the cell's frame.
      //
      
      NSUInteger column = cell.index % view.cellsPerRow;
      NSUInteger row    = cell.index / view.cellsPerRow;
      CGRect expectedFrame = CGRectMake((view.padding + self.testCellSize.width) * column, 
                                        self.testCellSize.height * row + topPadding,
                                        self.testCellSize.width, 
                                        self.testCellSize.height);
      CFDictionaryRef expectedFrameDictionary = CGRectCreateDictionaryRepresentation(expectedFrame);
      CFDictionaryRef cellFrameDictionary     = CGRectCreateDictionaryRepresentation(cell.frame);
      STAssertEquals(expectedFrame,
                     cell.frame,
                     @"Expected frame %@ but got %@",
                     expectedFrameDictionary,
                     cellFrameDictionary);
      CFRelease(expectedFrameDictionary);
      CFRelease(cellFrameDictionary);
      
      //
      //  Its color should match.
      //
      
      STAssertEquals(cell.fontColor, view.fontColor, 
                     @"Case %@: Font color should match",
                     testCase);
    }
  }
  STAssertEquals(observedCount, visibleCount,
                 @"Expected %d visible cells, saw %d",
                 visibleCount,
                 observedCount);
  STAssertEquals(observedIndexSum, visibleIndexSum, 
                 @"Expected index sum %d, got %d",
                 visibleIndexSum,
                 observedIndexSum);
}


////////////////////////////////////////////////////////////////////////////////
//
//  Test simple loading of a |BDGridViewController|.
//

- (void)testLoad {
  
  CGRect frame = CGRectMake(0, 0, 100, 100);
  BDGridView *view = [[[BDGridView alloc] initWithFrame:frame] autorelease];

  STAssertNotNil(view, nil);
}

////////////////////////////////////////////////////////////////////////////////
//
//  Tests |recomputeContentSize|.
//

- (void)testRecomputeContentSize {
  
  CGRect testFrame = CGRectMake(10, 20, 120, 240);
  BDGridView *view = [[[BDGridView alloc] initWithFrame:testFrame] autorelease];
  view.dataSource = self;
  [self resetAllocatedCellTracking];
  
  //
  //  First simple test case: Pick a size that evenly divides the width and height
  //  of the test frame. In this case, 10x10.
  //
  
  CGSize equalDivide = CGSizeMake(10, 10);
  self.testCellSize = equalDivide;
  view.minimumPadding = 0;
  [view reloadData];

  //
  //  Subcase 1. Even with zero cells, the dimensions of the frame should be at
  //  least one cell.
  //
  
  [self validateView:view forTestCase:@"Zero cells"];
  
  //
  //  Subcase 2. Test a number that's an integral number of rows.
  //  Note the view dimensions are 12 x 24 = 288 cells visible per screen.
  //  We're telling the delgate that we have 30 * 12 = 360 cells.
  //
  
  NSUInteger expectedRows = 30;
  NSUInteger expectedCellsPerRow = floor(view.frame.size.width / equalDivide.width);
  self.testCellCount = expectedRows * expectedCellsPerRow;
  [view reloadData];
  [self validateView:view forTestCase:@"Simple aligned grid"];
  
  //
  //  Set a top margin.
  //
  
  view.topContentPadding = 44;
  [view reloadData];
  [self validateView:view forTestCase:@"topContentPadding"];
  
  //
  //  Add a header.
  //
  
  view.headerView = [[[UIView alloc] initWithFrame:CGRectMake(10, 10, 10, 10)] autorelease];
  [view reloadData];
  [self validateView:view forTestCase:@"headerView"];
  
  //
  //  Now, scroll forward one half row. There should be a new row of cells (partially) 
  //  visible in addition to all previously visible content.
  //
  
  [view setContentOffset:CGPointMake(0, 5) animated:NO];
  [view layoutIfNeeded];
  [self validateView:view forTestCase:@"Scroll forward one half row"];
  
  //
  //  Scroll forward the rest of the row. The first row of cells is now totally
  //  hidden and should be present in the recycled cells array, waiting for
  //  reuse.
  //
  
  [view setContentOffset:CGPointMake(0, 10) animated:NO];
  [view layoutIfNeeded];
  [self validateView:view forTestCase:@"Scroll forward one whole row"];
  
  //
  //  Scroll forward another row. We'll have a totally different set of cells
  //  visible, yet the total number of allocations will not change.
  //
  
  [view setContentOffset:CGPointMake(0, 20) animated:NO];
  [view layoutIfNeeded];
  [self validateView:view forTestCase:@"Scroll forward two rows"];
  
  //
  //  Change the font color.
  //
  
  view.fontColor = [UIColor orangeColor];
  [self validateView:view forTestCase:@"Just made the font color orange"];
  
  //
  //  Try inserting a cell.
  //
  
  self.testCellCount++;
  [view insertCellAtIndex:36];
  [self validateView:view forTestCase:@"Inserted cell"];
  
  //
  //  subcase 3. One less than an integral number of rows.
  //
  
  self.testCellCount -= 2;
  [view reloadData];
  [self validateView:view forTestCase:@"reload data, not full number of rows"];
  
  //
  //  Subcase: Not a full screen full of data.
  //
  
  self.testCellCount = 15;
  [view reloadData];
  [self validateView:view forTestCase:@"not a full screen"];
  
  //
  //  Next test case: Make a long & skinny frame, one that isn't long enough
  //  to hold a full cell.
  //
  
  CGRect longAndSkinny = CGRectMake(10, 10, 5, 100);
  view.frame = longAndSkinny;
  [view reloadData];
  [self validateView:view forTestCase:@"long and skinny"];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Tests |tileCells|.
//

- (void)testTileCells {
  
  CGRect testFrame = CGRectMake(0, 0, 1024, 768);
  BDGridView *view = [[[BDGridView alloc] initWithFrame:testFrame] autorelease];
  view.dataSource = self;
  self.testCellCount = 101;
  self.testCellSize = CGSizeMake(100, 100);
  view.minimumPadding = 0;
  [view reloadData];
  
  STAssertEquals((NSUInteger)10, view.cellsPerRow, nil);
  STAssertEquals((NSUInteger)11, view.countOfRows, nil);
  
  //
  //  In this configuration, we can show 7.68 rows on a screen.
  //
  
  NSUInteger rowsPerScreen = 8;
  STAssertEquals((NSInteger)0, view.firstVisibleIndex, nil);
  STAssertEquals((NSInteger)(rowsPerScreen * view.cellsPerRow),
                 view.lastVisibleIndex, nil);
}

////////////////////////////////////////////////////////////////////////////////
//
//  Tests |configureCell:|.
//

- (void)testConfigureCell {
  
  CGRect testFrame = CGRectMake(0, 0, 1200, 800);
  BDGridView *view = [[[BDGridView alloc] initWithFrame:testFrame] autorelease];
  view.dataSource = self;
  self.testCellCount = 101;
  self.testCellSize = CGSizeMake(100, 100);
  view.minimumPadding = 0;
  [view reloadData];
  
  SEL configureCell = @selector(configureCell:);
  
  BDGridCell *testCell = [[[BDGridCell alloc] init] autorelease];
  
  //
  //  Case 1: Simple configure, no edit mode. Verify the frame's in the
  //  expected location.
  //

  testCell.index = 3;
  [view performSelector:configureCell withObject:testCell];
  CGRect nonEditFrame = CGRectMake(300, 0, 100, 100);
  CFDictionaryRef nonEditFrameDictionary = CGRectCreateDictionaryRepresentation(nonEditFrame);
  STAssertEquals(nonEditFrame, testCell.frame,
                 @"Unexpected frame %@",
                 nonEditFrameDictionary);
  CFRelease(nonEditFrameDictionary);
  
  //
  //  Change the index. Frame should change.
  //
  
  testCell.index = 23;
  nonEditFrame = CGRectMake(23 % 12 * 100, 
                            23 / 12 * 100, 
                            100, 
                            100);
  [view performSelector:configureCell withObject:testCell];
  STAssertEquals(nonEditFrame, testCell.frame, nil);
}

////////////////////////////////////////////////////////////////////////////////
//
//  Tests |canPerformAction|.
//

- (void)testCanPerformAction {
  
  BDGridView *view = [[[BDGridView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)] autorelease];
  TestGridViewDelegate *dummy = [[[TestGridViewDelegate alloc] init] autorelease];
  
  //
  //  First, try |canPerformAction| with a delegate that does not respond
  //  to any of the cut/copy/paste/delete methods.
  //
  
  view.gridViewDelegate = dummy;
  SEL actions[] = { @selector(cut:), @selector(copy:), @selector(paste:), @selector(delete:) };
  NSInteger numActions = sizeof(actions) / sizeof(SEL);
  
  for (int i = 0; i < numActions; i++) {
    
    STAssertFalse([view canPerformAction:actions[i] withSender:nil], nil);
  }
  
  //
  //  Set up the view with data & a selection.
  //
  
  view.dataSource = self;
  self.testCellCount = 3;
  self.testCellSize = CGSizeMake(10, 10);
  [view reloadData];
  [view layoutIfNeeded];
  BDGridCell *selectedCell = [self.allocatedCells anyObject];
  [view performSelector:@selector(selectCell:) withObject:selectedCell];
  
  //
  //  A delegate that does not allow editing should not be able to perform actions.
  //
  
  id mockDelegateNoEdit = [OCMockObject mockForProtocol:@protocol(BDGridViewDelegate)];
  BOOL canEdit = NO;
  [[[mockDelegateNoEdit stub] andReturnValue:OCMOCK_VALUE(canEdit)] gridViewShouldEdit:view];
  view.gridViewDelegate = mockDelegateNoEdit;
  for (int i = 0; i < numActions; i++) {
    
    STAssertFalse([view canPerformAction:actions[i] withSender:nil], nil);
  }
  
  //
  //  Now, try it with a delegate that knows how to respond to all messages.
  //  Note we need some cells and we need at least one selected to make sure
  //  that all selectors work.
  //
  
  id mockDelegate = [OCMockObject mockForProtocol:@protocol(BDGridViewDelegate)];
  view.gridViewDelegate = mockDelegate;
  STAssertTrue(selectedCell.selected, nil);
  BOOL canPaste = YES;
  [[[mockDelegate stub] andReturnValue:OCMOCK_VALUE(canPaste)] gridViewCanPaste:view];
  canEdit = YES;
  for (int i = 0; i < numActions; i++) {
    
    [[[mockDelegate stub] andReturnValue:OCMOCK_VALUE(canEdit)] gridViewShouldEdit:view];
    STAssertTrue([view canPerformAction:actions[i] withSender:nil], 
                 @"Should be able to perform action %s",
                 sel_getName(actions[i]));
  }
  
  //
  //  Finally, test the actions, one at a time.
  //
  
  [[mockDelegate expect] gridView:view didCut:OCMOCK_ANY];
  [view cut:nil];
  STAssertNoThrow([mockDelegate verify], nil);
  STAssertFalse(selectedCell.selected, @"cut: should remove object selection");
  
  //
  //  Reselect the cell...
  //
  
  [view performSelector:@selector(selectCell:) withObject:selectedCell];
  STAssertTrue(selectedCell.selected, nil);
  [[mockDelegate expect] gridView:view didCopy:OCMOCK_ANY];
  [view copy:nil];
  STAssertNoThrow([mockDelegate verify], nil);
  STAssertFalse(selectedCell.selected, @"copy: should remove object selection");

  //
  //  Todo: I need to test the cases when the delegate does not implement
  //  |gridView:didPasteIntoCell:|.
  //
  
  [view performSelector:@selector(selectCell:) withObject:selectedCell];
  STAssertTrue(selectedCell.selected, nil);
  [[mockDelegate expect] gridView:view didPasteIntoCell:selectedCell];
  [view paste:nil];
  STAssertNoThrow([mockDelegate verify], nil);
  STAssertFalse(selectedCell.selected, @"paste: should remove object selection");
  
  [view performSelector:@selector(selectCell:) withObject:selectedCell];
  STAssertTrue(selectedCell.selected, nil);
  [[mockDelegate expect] gridView:view didDelete:OCMOCK_ANY];
  [view delete:nil];
  STAssertNoThrow([mockDelegate verify], nil);
  STAssertFalse(selectedCell.selected, @"paste: should remove object selection");
}

////////////////////////////////////////////////////////////////////////////////
//
//  Fine-grained tests of |canPerformAction:@selector(paste:)...|
//

- (void)testCanPaste {
  
  BDGridView *view = [[[BDGridView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)] autorelease];
  
  //
  //  By default, you can't paste.
  //
  
  STAssertFalse([view canPerformAction:@selector(paste:) withSender:nil], nil);
  
  //
  //  We have two mock objects. One that says paste is allowed, one that
  //  says it isn't.
  //
  
  BOOL canEdit = YES;
  BOOL pasteAllowed = YES;
  BOOL pasteNotAllowed = NO;
  id mockPasteAllowed = [OCMockObject mockForProtocol:@protocol(BDGridViewDelegate)];
  [[[mockPasteAllowed stub] andReturnValue:OCMOCK_VALUE(pasteAllowed)] gridViewCanPaste:view];
  [[[mockPasteAllowed stub] andReturnValue:OCMOCK_VALUE(canEdit)] gridViewShouldEdit:view];
  id mockPasteNotAllowed = [OCMockObject mockForProtocol:@protocol(BDGridViewDelegate)];
  [[[mockPasteNotAllowed stub] andReturnValue:OCMOCK_VALUE(pasteNotAllowed)] gridViewCanPaste:view];
  [[[mockPasteNotAllowed stub] andReturnValue:OCMOCK_VALUE(canEdit)] gridViewShouldEdit:view];
  
  //
  //  With no insertion point, even if paste is allowed, there is no paste.
  //
  
  view.gridViewDelegate = mockPasteAllowed;
  STAssertFalse([view canPerformAction:@selector(paste:) withSender:nil], nil);
  
  //
  //  Add an insertion point, and suddenly you can paste.
  //
  
  view.insertionPoint = 0;
  STAssertTrue([view canPerformAction:@selector(paste:) withSender:nil], nil);
  
  //
  //  ...unless the delegate says you can't.
  //
  
  view.gridViewDelegate = mockPasteNotAllowed;
  STAssertFalse([view canPerformAction:@selector(paste:) withSender:nil], nil);
}

////////////////////////////////////////////////////////////////////////////////
//
//  Tests |canPerformAction:@selector(addNew)...|
//

- (void)testAddNew {
  
  BDGridView *view = [[[BDGridView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)] autorelease];
  
  //
  //  By default, you can't add new.
  //
  
  STAssertFalse([view canPerformAction:@selector(addNew) withSender:nil], nil);
  
  //
  //  ...even with a delegate...
  //
  
  id mockAddNewAllowed = [OCMockObject mockForProtocol:@protocol(BDGridViewDelegate)];
  view.gridViewDelegate = mockAddNewAllowed;
  BOOL canEdit = YES;
  [[[mockAddNewAllowed stub] andReturnValue:OCMOCK_VALUE(canEdit)] gridViewShouldEdit:view];
  STAssertFalse([view canPerformAction:@selector(addNew) withSender:nil], nil);

  //
  //  ...unless there is an insertion point.
  //
  
  view.insertionPoint = 0;
  STAssertTrue([view canPerformAction:@selector(addNew) withSender:nil], nil);
}

////////////////////////////////////////////////////////////////////////////////
//
//  Tests the cases when I expect that cell panning should not work.
//

- (void)testCellPanFailures {
  
  BDGridView *view = [[[BDGridView alloc] initWithFrame:CGRectZero] autorelease];
  TestGridViewDelegate *dummyDelegate = [[[TestGridViewDelegate alloc] init] autorelease];
  
  view.gridViewDelegate = dummyDelegate;
  BDContrainPanGestureRecognizer *panGesture = [[[BDContrainPanGestureRecognizer alloc] initWithTarget:view 
                                                                                                action:@selector(handleCellPan:)] 
                                                autorelease];

  STAssertFalse([view gestureRecognizerShouldBegin:panGesture], nil);
  
  BOOL shouldEdit = YES;
  id mockDelegate = [OCMockObject mockForProtocol:@protocol(BDGridViewDelegate)];
  [[[mockDelegate stub] andReturnValue:OCMOCK_VALUE(shouldEdit)] gridViewShouldEdit:view];
  view.gridViewDelegate = mockDelegate;
  STAssertTrue([view gestureRecognizerShouldBegin:panGesture], nil);
}

////////////////////////////////////////////////////////////////////////////////
//
//  Tests adding a header view to the grid.
//

- (void)testHeaderView {
  
  BDGridView *view = [[[BDGridView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)] autorelease];
  UIView *header = [[[UIView alloc] initWithFrame:CGRectMake(100, 100, 50, 10)] autorelease];
  
  view.headerView = header;
  STAssertEquals(view.topContentPadding, (CGFloat)0, nil);
}

@end
