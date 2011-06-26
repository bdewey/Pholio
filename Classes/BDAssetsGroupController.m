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

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
//  Private properties
//

@interface BDAssetsGroupController()

@property (nonatomic, retain) NSMutableArray *assets;
@property (nonatomic, retain) NSMutableSet *selectedAssets;

- (void)configureTitle;
- (void)didSelectDone;

@end


@implementation BDAssetsGroupController

@synthesize assetsSource = assetsSource_;
@synthesize delegate = delegate_;
@synthesize assets = assets_;
@synthesize selectedAssets = selectedAssets_;

////////////////////////////////////////////////////////////////////////////////
//
//  Designated initializer.
//

- (id)initWithStyle:(UITableViewStyle)style {
  
  self = [super initWithStyle:style];
  if (self) {
    
    self.assets = [NSMutableArray arrayWithCapacity:10];
    self.selectedAssets = [NSMutableSet setWithCapacity:10];
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release all retained properties.
//

- (void)dealloc {

  [assetsSource_ release];
  [assets_ release];
  [selectedAssets_ release];
  [super dealloc];
}

#pragma mark - View lifecycle

////////////////////////////////////////////////////////////////////////////////
//
//  Load all table groups.
//

- (void)viewDidLoad {
  
  [super viewDidLoad];
  self.tableView.separatorColor = [UIColor clearColor];
  self.tableView.allowsSelection = NO;
  
  self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                                          target:self 
                                                                                          action:@selector(didSelectDone)] autorelease];
  self.navigationItem.rightBarButtonItem.enabled = NO;
  
  //
  //  TODO: Need to set the delegate for all of these selectable assets.
  //
  
  [self.assetsSource asyncFillArrayWithAssets:self.assets 
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
  
  return ceil([self.assets count] / (CGFloat)kAssetsPerRow);
}

////////////////////////////////////////////////////////////////////////////////
//
//  Get a cell for this group.
//

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  BDAssetRowCell *cell = [BDAssetRowCell cellForTableView:tableView];
  int row = [indexPath row];
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
  
  // Navigation logic may go here. Create and push another view controller.
  /*
   <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
   // ...
   // Pass the selected object to the new view controller.
   [self.navigationController pushViewController:detailViewController animated:YES];
   [detailViewController release];
   */
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
