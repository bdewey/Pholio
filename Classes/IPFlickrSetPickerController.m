//
//  IPFlickrSetPickerController.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 5/19/11.
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

#import "IPFlickrSetPickerController.h"
#import "IPFlickrRequest.h"
#import "IPFlickrSearchCell.h"
#import "BDImagePickerControllerDelegate.h"
#import "IPFlickrSearchSource.h"
#import "BDAssetsGroupController.h"
#import "IPFlickrLoadingCell.h"

enum IPFlickrSetPickerSections {
  
  IPFlickrSetPickerSectionPhotostream,
  IPFlickrSetPickerSectionSets,
  IPFlickrSetPickerSectionNumItems
};

@interface IPFlickrSetPickerController ()

//
//  The user's photosets.
//

@property (nonatomic, strong) NSMutableArray *flickrSets;

- (void)didCancel;

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPFlickrSetPickerController

@synthesize delegate = delegate_;
@synthesize flickrSets = flickrSets_;

////////////////////////////////////////////////////////////////////////////////
//
//  Initialize.
//

- (id)initWithStyle:(UITableViewStyle)style {

  self = [super initWithStyle:style];
  if (self) {
    
    self.title = kFlickr;
    self.flickrSets = [NSMutableArray arrayWithCapacity:5];
    UIImage *flickrIcon = [UIImage imageNamed:@"FlickrTabBarIcon.png"];
    _GTMDevAssert(flickrIcon != nil, @"Should get flickr icon");
    self.tabBarItem.image = flickrIcon;
    _GTMDevAssert(self.tabBarItem != nil, @"Controller should have a tab bar item");
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release retained properties.
//


////////////////////////////////////////////////////////////////////////////////
//
//  Release caches.
//

- (void)didReceiveMemoryWarning {

  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

////////////////////////////////////////////////////////////////////////////////
//
//  View loaded -- create cancel button.
//

- (void)viewDidLoad {
  
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                                          target:self 
                                                                                          action:@selector(didCancel)];
  
  [IPFlickrRequest callWithGet:@"flickr.photosets.getList" 
                  andArguments:nil 
                     onSuccess:^(NSDictionary *responseDictionary) {
                       
                       self.flickrSets = [responseDictionary valueForKeyPath:@"photosets.photoset"];
                       [self.tableView reloadData];
                     } 
                       onError:^(NSError *error) {
                         
                         //
                         //  NOTHING
                         //
                       }
   ];
}

////////////////////////////////////////////////////////////////////////////////
//
//  We support all orientations.
//

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

  // Return YES for supported orientations
  return YES;
}

#pragma mark - Table view data source

////////////////////////////////////////////////////////////////////////////////
//
//  Two sections.
//

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

  return IPFlickrSetPickerSectionNumItems;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Titles for sections.
//

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  
  if (section == IPFlickrSetPickerSectionSets) {
    
    return kFlickrSets;
  }
  return nil;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Rows per section.
//

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

  switch (section) {
    case IPFlickrSetPickerSectionPhotostream:
      return 1;
      
    case IPFlickrSetPickerSectionSets:
      if ([self.flickrSets count] == 0) {
        
        //
        //  If we don't yet have flickr sets loaded, we're going to display a
        //  "Loading..." cell.
        //
        
        return 1;
      }
      return [self.flickrSets count];
      
    default:
      _GTMDevAssert(NO, @"Unrecognized section %d", section);
      return 0;
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  Gets a cell.
//

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  IPFlickrSearchCell *cell = [IPFlickrSearchCell cellForTableView:tableView];
  NSDictionary *setProperties;
  NSString *setId;
  
  switch (indexPath.section) {
    case IPFlickrSetPickerSectionPhotostream:
      cell.title = @"Photostream";
      cell.searchApi = @"flickr.photos.search";
      cell.searchArguments = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"me", @"user_id",
                              @"url_l,url_m,url_o", @"extras",
                              nil];
      cell.resultKeyPath = @"photos.photo";
      [cell configureCell];
      break;
      
    case IPFlickrSetPickerSectionSets:
      if ([self.flickrSets count] == 0) {
        
        //
        //  Special case the case when we haven't yet loaded sets.
        //
        
        IPFlickrLoadingCell *loadingCell = [IPFlickrLoadingCell cellForTableView:tableView];
        return loadingCell;
      }
      setProperties = [self.flickrSets objectAtIndex:indexPath.row];
      setId = [setProperties objectForKey:@"id"];
      _GTMDevLog(@"%s -- building a query for set %@ (id = %@)",
                 __PRETTY_FUNCTION__,
                 [[setProperties objectForKey:@"title"] textContent],
                 setId);
      cell.title = [[setProperties objectForKey:@"title"] textContent];
      cell.searchApi = @"flickr.photosets.getPhotos";
      cell.searchArguments = [NSDictionary dictionaryWithObjectsAndKeys:
                              setId, @"photoset_id", 
                              @"url_l,url_m,url_o", @"extras",
                              nil];
      cell.resultKeyPath = @"photoset.photo";
      [cell configureCell];
      break;
      
    default:
      _GTMDevAssert(NO, @"Unrecognized section %d", indexPath.section);
      break;
  }
  return cell;
}

#pragma mark - Table view delegate

////////////////////////////////////////////////////////////////////////////////
//
//  Cell selection.
//

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

  IPFlickrSearchCell *cell = (IPFlickrSearchCell *)[tableView cellForRowAtIndexPath:indexPath];
  IPFlickrSearchSource *source = [IPFlickrSearchSource sourceWithSearchCell:cell];
  BDAssetsGroupController *controller = [[BDAssetsGroupController alloc] initWithStyle:UITableViewStylePlain];
  controller.assetsSource = source;
  controller.delegate = self.delegate;
  [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Other actions

////////////////////////////////////////////////////////////////////////////////
//
//  Handle cancellation.
//

- (void)didCancel {

  [self.delegate bdImagePickerControllerDidCancel];
}

@end
