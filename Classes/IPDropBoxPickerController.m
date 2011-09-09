//
//  IPDropBoxPickerController.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 9/5/11.
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

#import "IPDropBoxPickerController.h"
#import "IPDropBoxSelectableAsset.h"
#import "BDAssetRowCell.h"

////////////////////////////////////////////////////////////////////////////////
//
//  Extension for private data.
//

@interface IPDropBoxPickerController()

//
//  All of the subdirectories of the current dropbox directory. Each of these
//  will get one table cell.
//

@property (nonatomic, retain) NSMutableArray *subdirectories;

//
//  All of the images in the current dropbox directory. There will be 4 of these
//  per table cell.
//

@property (nonatomic, retain) NSMutableArray *images;

@property (nonatomic, retain) DBRestClient *dbClient;

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPDropBoxPickerController

@synthesize delegate;
@synthesize dropboxPath = dropboxPath_;
@synthesize subdirectories = subdirectories_;
@synthesize images = images_;
@synthesize dbClient = dbClient_;

////////////////////////////////////////////////////////////////////////////////

- (id)initWithStyle:(UITableViewStyle)style {
  
  self = [super initWithStyle:style];
  if (self) {
    // Custom initialization
    
    subdirectories_ = [[NSArray alloc] init];
    images_ = [[NSArray alloc] init];
    dbClient_ = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    dbClient_.delegate = self;
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////

- (void)dealloc {
  
  [dropboxPath_ release], dropboxPath_ = nil;
  [subdirectories_ release], subdirectories_ = nil;
  [images_ release], images_ = nil;
  [dbClient_ release], dbClient_ = nil;
  [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////

- (void)didReceiveMemoryWarning {
  
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

////////////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad {
  
  [super viewDidLoad];
  [self.dbClient loadMetadata:self.dropboxPath];
}

////////////////////////////////////////////////////////////////////////////////

- (void)viewDidUnload {
  
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

////////////////////////////////////////////////////////////////////////////////

- (void)viewWillAppear:(BOOL)animated {
  
  [super viewWillAppear:animated];
}

////////////////////////////////////////////////////////////////////////////////

- (void)viewDidAppear:(BOOL)animated {
  
  [super viewDidAppear:animated];
}

////////////////////////////////////////////////////////////////////////////////

- (void)viewWillDisappear:(BOOL)animated {
  
  [super viewWillDisappear:animated];
}

////////////////////////////////////////////////////////////////////////////////

- (void)viewDidDisappear:(BOOL)animated {
  
  [super viewDidDisappear:animated];
}

////////////////////////////////////////////////////////////////////////////////

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  
  // Return YES for supported orientations
  return YES;
}

#pragma mark - Table view data source

////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  
  return 1;
}

////////////////////////////////////////////////////////////////////////////////

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
  return [self.subdirectories count] + ceil(((double)[self.images count] / (double)kAssetsPerRow));
}

////////////////////////////////////////////////////////////////////////////////

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  NSUInteger row = [indexPath row];
  
  if (row < [self.subdirectories count]) {
    
    //
    //  This row represents a directory. Each directory gets one cell.
    //  TODO: Replace this code...
    //
    
    static NSString *CellIdentifier = @"Directory";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    DBMetadata *directoryMetadata = [self.subdirectories objectAtIndex:row];
    cell.textLabel.text = directoryMetadata.path;
    
    return cell;
  }
  
  //
  //  We're looking at a row that represents the images that were in this
  //  directory. We're going to make one row per every four images.
  //
  
  row -= [self.subdirectories count];
}

#pragma mark - Table view delegate

////////////////////////////////////////////////////////////////////////////////

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

#pragma mark - DBRestClientDelegate

////////////////////////////////////////////////////////////////////////////////

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
  
  for (DBMetadata *child in metadata.contents) {
    
    if (child.isDirectory) {
      
      [self.subdirectories addObject:child];
      
    } else if (child.thumbnailExists) {
      
      IPDropBoxSelectableAsset *asset = [[[IPDropBoxSelectableAsset alloc] init] autorelease];
      asset.metadata = child;
      [self.images addObject:asset];
    }
  }
  [self.tableView reloadData];
}

@end
