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
#import "BDAssetsLibraryController.h"
#import "BDAssetsGroupCell.h"
#import "BDAssetsGroupController.h"
#import "BDAssetsSource.h"
#import "BDSelectableALAsset.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: Knows how to create BDSelectableAsset objects for an 
//  ALAssetGroup.
//

@interface BDALAssetGroupSource: NSObject<BDAssetsSource> { }

@property (nonatomic, strong) ALAssetsGroup *assetsGroup;

+ (BDALAssetGroupSource *)sourceWithGroup:(ALAssetsGroup *)assetsGroup;

@end

@implementation BDALAssetGroupSource

@synthesize assetsGroup = assetsGroup_;

+ (BDALAssetGroupSource *)sourceWithGroup:(ALAssetsGroup *)assetsGroup {
  
  BDALAssetGroupSource *source = [[BDALAssetGroupSource alloc] init];
  source.assetsGroup = assetsGroup;
  return source;
}


- (NSString *)title {
  
  return [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
}

- (void)asyncFillArrayWithChildren:(NSMutableArray *)children
                         andAssets:(NSMutableArray *)assets 
       withSelectableAssetDelegate:(id<BDSelectableAssetDelegate>)delegate 
                        completion:(void (^)())completion {
  
  [self.assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
    
    if (result != nil) {
      
      BDSelectableALAsset *asset = [[BDSelectableALAsset alloc] initWithAsset:result];
      asset.delegate = delegate;
      [assets addObject:asset];
      
    } else {
      
      //
      //  result == nil means we're done.
      //
      
      completion();
    }
  }];
}

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface BDAssetsLibraryController ()

@property (nonatomic, strong) ALAssetsLibrary *library;
- (void)didCancel;

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


@implementation BDAssetsLibraryController

@synthesize groups = groups_;
@synthesize delegate = delegate_;
@synthesize library = library_;

////////////////////////////////////////////////////////////////////////////////
//
//  Designated initializer.
//

- (id)initWithStyle:(UITableViewStyle)style {

  self = [super initWithStyle:style];
  if (self) {

    self.groups = [NSMutableArray arrayWithCapacity:10];
    self.title  = kPhotoAlbums;
    UIImage *tabBarIcon = [UIImage imageNamed:@"42-photos.png"];
    _GTMDevAssert(tabBarIcon != nil, @"Should get tab bar icon");
    self.tabBarItem.image = tabBarIcon;
    
    library_ = [[ALAssetsLibrary alloc] init];
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release all retained properties.
//

- (void)dealloc {

  groups_ = nil;
  library_ = nil;
}

#pragma mark - View lifecycle

////////////////////////////////////////////////////////////////////////////////
//
//  Load all table groups.
//
- (void)viewDidLoad {

  [super viewDidLoad];
  
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                                          target:self 
                                                                                          action:@selector(didCancel)];
  
  //
  //  Note that enumerateGroupsWithTypes already executes this in a multithreaded
  //  way. I.e., the function returns before all blocks have been enumerated.
  //  All blocks are called on the main thread, though.
  //
  
  [self.library enumerateGroupsWithTypes:ALAssetsGroupAll
                         usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                           
                           if (group != nil) {
                             
                             [self.groups addObject:group];
                             
                             //
                             //  BUGBUG -- for some reason having this line here
                             //  makes the |numberOfAssets| message work properly
                             //  later.
                             //
                             
                             [group numberOfAssets];
                             _GTMDevLog(@"%s (%@) -- Found group with %d assets",
                                        __PRETTY_FUNCTION__,
                                        [[NSOperationQueue currentQueue] name],
                                        [group numberOfAssets]);
                             
                           } else {
                             
                             //
                             //  |group| is nil when we're done enumerating.
                             //
                             
                             [self.tableView performSelectorOnMainThread:@selector(reloadData) 
                                                              withObject:nil 
                                                           waitUntilDone:NO];
                           }
                         } 
                       failureBlock:^(NSError *error) {
                           
                       }
   ];
  _GTMDevLog(@"%s -- enumeration method has returned", __PRETTY_FUNCTION__);
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
//  The user hit cancel. Tell the delegate.
//

- (void)didCancel {
  
  [self.delegate bdImagePickerControllerDidCancel];
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
//  Number of rows: Equal to the number of groups.
//

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

  return [self.groups count];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Get a cell for this group.
//

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  BDAssetsGroupCell *cell = [BDAssetsGroupCell cellForTableView:tableView];
  NSUInteger row = [indexPath row];
  cell.assetsGroup = [self.groups objectAtIndex:row];
  return cell;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Cell height.
//

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  return 57;
}

#pragma mark - Table view delegate

////////////////////////////////////////////////////////////////////////////////
//
//  Handle a cell tap.
//

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

  NSUInteger row = [indexPath row];
  ALAssetsGroup *group = [self.groups objectAtIndex:row];
  BDAssetsGroupController *groupController = [[BDAssetsGroupController alloc] initWithStyle:UITableViewStylePlain];
  groupController.assetsSource = [BDALAssetGroupSource sourceWithGroup:group];
  groupController.title = [group valueForProperty:ALAssetsGroupPropertyName];
  groupController.delegate = self;
  
  [self.navigationController pushViewController:groupController animated:YES];
}

#pragma mark - BDAssetsGroupControllerDelegate

////////////////////////////////////////////////////////////////////////////////
//
//  Pass through to our delegate.
//

- (void)bdImagePickerDidPickImages:(NSArray *)images {
  
  [self.delegate bdImagePickerDidPickImages:images];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Pass through to our delegate.
//

- (void)bdImagePickerControllerDidCancel {
  
  [self.delegate bdImagePickerControllerDidCancel];
}

@end
