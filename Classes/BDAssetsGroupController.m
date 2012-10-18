//
//  BDAssetGroupController.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 5/6/11.
//  Copyright 2011 Brian's Brain. All rights reserved.
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

#import <AssetsLibrary/AssetsLibrary.h>
#import "BDAssetsGroupController.h"
#import "BDAssetRowCell.h"
#import "BDSelectableALAsset.h"
#import "BDAssetsSource.h"
#import "BDAssetsSourceCell.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
//  Private properties
//

@interface BDAssetsGroupController()

@property (nonatomic, strong) NSMutableArray *children;
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) NSMutableSet *selectedAssets;

- (void)configureTitle;
- (void)didSelectDone;
- (void)didSelectAll;

@end


@implementation BDAssetsGroupController

@synthesize assetsSource = assetsSource_;
@synthesize delegate = delegate_;
@synthesize children = children_;
@synthesize assets = assets_;
@synthesize selectedAssets = selectedAssets_;

////////////////////////////////////////////////////////////////////////////////
//
//  Designated initializer.
//

- (id)initWithStyle:(UITableViewStyle)style {
  
  self = [super initWithStyle:style];
  if (self) {
    
    self.children = [NSMutableArray arrayWithCapacity:10];
    self.assets = [NSMutableArray arrayWithCapacity:10];
    self.selectedAssets = [NSMutableSet setWithCapacity:10];
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release all retained properties.
//


#pragma mark - View lifecycle

////////////////////////////////////////////////////////////////////////////////
//
//  Load all table groups.
//

- (void)viewDidLoad {
  
  [super viewDidLoad];
  self.tableView.separatorColor = [UIColor clearColor];
//  self.tableView.allowsSelection = NO;
  
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                                          target:self 
                                                                                          action:@selector(didSelectDone)];
  self.navigationItem.rightBarButtonItem.enabled = NO;
  
  UIBarButtonItem *selectAll = [[UIBarButtonItem alloc] initWithTitle:@"Select All" 
                                                                 style:UIBarButtonItemStyleBordered 
                                                                target:self 
                                                                action:@selector(didSelectAll)];
  UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                                                  target:nil 
                                                                                  action:nil];
  self.toolbarItems = [NSArray arrayWithObjects:flexibleSpace, selectAll, flexibleSpace, nil];
  
  //
  //  TODO: Need to set the delegate for all of these selectable assets.
  //
  
  [self.assetsSource asyncFillArrayWithChildren:self.children
                                      andAssets:self.assets 
                    withSelectableAssetDelegate:self 
                                     completion:^ {
                                       [self.tableView reloadData];
                                     }];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release any retained subviews.
//

- (void)viewDidUnload {
  
  [super viewDidUnload];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Make sure the toolbar is visible when we are.
//

- (void)viewDidAppear:(BOOL)animated {
  
  [self.navigationController setToolbarHidden:NO animated:animated];
  self.navigationController.toolbar.barStyle = UIBarStyleBlack;
}

////////////////////////////////////////////////////////////////////////////////
//
//  We can rotate.
//

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  
  // Return YES for supported orientations
  return YES;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Update the title of this view in the navigation controller.
//

- (void)configureTitle {

  NSUInteger selectedCount = [self.selectedAssets count];
  if (selectedCount == 0) {
    
    self.navigationItem.title = [self.assetsSource title];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
  } else {
    
    self.navigationItem.title = [NSString stringWithFormat:@"%d selected", selectedCount];
    self.navigationItem.rightBarButtonItem.enabled = YES;
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  The user clicked the "done" button. Inform the delegate.
//

- (void)didSelectDone {

  NSMutableArray *assetArray = [NSMutableArray arrayWithCapacity:[self.selectedAssets count]];
  for (BDSelectableALAsset *asset in self.selectedAssets) {
    
    [assetArray addObject:asset];
  }
  [self.delegate bdImagePickerDidPickImages:assetArray];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Select all images.
//

- (void)didSelectAll {
  
  for (id<BDSelectableAsset> asset in self.assets) {
    
    [asset setSelected:YES];
  }
  [self.tableView reloadData];
}

#pragma mark - Table view data source

////////////////////////////////////////////////////////////////////////////////
//
//  Number of sections: 1.
//

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  
  return 1;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Number of rows: Recall that we can put 4 assets in a cell.
//

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
  return [self.children count] + ceil([self.assets count] / (CGFloat)kAssetsPerRow);
}

////////////////////////////////////////////////////////////////////////////////
//
//  Get a cell for this group.
//

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  int row = [indexPath row];

  if (row < [self.children count]) {
    
    BDAssetsSourceCell *cell = [BDAssetsSourceCell cellForTableView:tableView];
    cell.assetsSource = [self.children objectAtIndex:row];
    return cell;
  }
  row -= [self.children count];
  BDAssetRowCell *cell = [BDAssetRowCell cellForTableView:tableView];
  NSRange indexRange = NSMakeRange(row * kAssetsPerRow, kAssetsPerRow);
  if ((indexRange.location + indexRange.length) >= [self.assets count]) {
    
    indexRange.length = [self.assets count] - indexRange.location;
  }
  NSIndexSet *assetIndexes = [NSIndexSet indexSetWithIndexesInRange:indexRange];
  cell.assets = [NSArray arrayWithArray:[self.assets objectsAtIndexes:assetIndexes]];
  return cell;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Height of our cells.
//

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  return kAssetRowHeight;
}

#pragma mark - Table view delegate

////////////////////////////////////////////////////////////////////////////////
//
//  Handle a cell tap.
//

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

  NSUInteger row = [indexPath row];
  if (row >= [self.children count]) {
    
    return;
  }
  id<BDAssetsSource> source = [self.children objectAtIndex:row];
  BDAssetsGroupController *childController = [[BDAssetsGroupController alloc] initWithStyle:UITableViewStylePlain];
  childController.assetsSource = source;
  childController.delegate = self.delegate;
  [self.navigationController pushViewController:childController animated:YES];
}

#pragma mark - BDSelectableAssetDelegate

////////////////////////////////////////////////////////////////////////////////
//
//  A cell was selected.
//

- (void)selectableAssetDidSelect:(id<BDSelectableAsset>)selectableAsset {
  
  _GTMDevAssert(self.selectedAssets != nil, @"selectedAssets must not be nil");
  [self.selectedAssets addObject:selectableAsset];
  [self configureTitle];
}

////////////////////////////////////////////////////////////////////////////////
//
//  A cell was unselected.
//

- (void)selectableAssetDidUnselect:(id<BDSelectableAsset>)selectableAsset {
  
  _GTMDevAssert(self.selectedAssets != nil, @"selectedAssets must not be nil");
  [self.selectedAssets removeObject:selectableAsset];
  [self configureTitle];
}

@end
