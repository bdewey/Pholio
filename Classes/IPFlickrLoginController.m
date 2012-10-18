//
//  IPFlickrLoginController.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 5/18/11.
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

#import "IPFlickrLoginController.h"
#import "IPButtonCell.h"
#import "IPFlickrAuthorizationManager.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPFlickrLoginController

////////////////////////////////////////////////////////////////////////////////
//
//  Initializer.
//

- (id)initWithStyle:(UITableViewStyle)style {

  self = [super initWithStyle:style];
  if (self) {

    self.title = kFlickr;
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
//  We support all orientations.
//

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

  // Return YES for supported orientations
  return YES;
}

#pragma mark - Table view data source

////////////////////////////////////////////////////////////////////////////////
//
//  Number of sections.
//

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

  return 1;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Get the section title.
//

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  
  return @"When you connect Pholio to your Flickr account, you can easily add Flickr photos to your sets. Connecting to Flickr is an easy process that is done in your browser.";
}

////////////////////////////////////////////////////////////////////////////////
//
//  Number of rows.
//

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

  return 1;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Gets our one and only cell.
//

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  IPButtonCell *cell = [IPButtonCell cellForTableView:tableView];

  IPFlickrAuthorizationManager *authManager = [IPFlickrAuthorizationManager sharedManager];
  if (authManager.authToken == nil) {
    
    cell.title = kFlickrConnectToFlickr;
    
  } else {
    
    cell.title = [NSString stringWithFormat:@"Disconnect from %@", authManager.flickrUserName];
  }
  return cell;
}

#pragma mark - Table view delegate

////////////////////////////////////////////////////////////////////////////////
//
//  Cell selection...
//

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  [cell setSelected:NO animated:NO];
  IPFlickrAuthorizationManager *authManager = [IPFlickrAuthorizationManager sharedManager];
  if (authManager.authToken == nil) {
    
    [authManager login];
    
  } else {
    
    authManager.authToken = nil;
  }
  [self.navigationController popViewControllerAnimated:YES];
}

@end
