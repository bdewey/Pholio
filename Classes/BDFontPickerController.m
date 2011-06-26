//
//  BDFontPickerController.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 5/24/11.
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

#import "BDFontPickerController.h"
#import "BDFontCell.h"

@interface BDFontPickerController ()

@property (nonatomic, retain) NSArray *fontFamilyNames;

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


@implementation BDFontPickerController

@synthesize delegate = delegate_;
@synthesize fontFamilyName = fontFamilyName_;
@synthesize fontFamilyToFont = fontFamilyToFont_;
@synthesize showOnlyMappedFonts = showOnlyMappedFonts_;
@synthesize fontFamilyNames = fontFamilyNames_;

////////////////////////////////////////////////////////////////////////////////
//
//  Designated initializer.
//

- (id)init {
  
  self = [super initWithStyle:UITableViewStylePlain];
  if (self) {

    self.showOnlyMappedFonts = YES;
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release retained properties.
//

- (void)dealloc {
  
  [fontFamilyName_ release];
  [fontFamilyToFont_ release];
  [fontFamilyNames_ release];
  [super dealloc];
}

#pragma mark - View lifecycle

////////////////////////////////////////////////////////////////////////////////
//
//  Configure the font names to choose from.
//

- (void)viewDidLoad {

  if (([self.fontFamilyToFont count] > 0) && self.showOnlyMappedFonts) {
    
    self.fontFamilyNames = [[self.fontFamilyToFont allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
  } else {
    
    self.fontFamilyNames = [[UIFont familyNames] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  We support all orientations.
//

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

  return YES;
}

#pragma mark - Table view data source

////////////////////////////////////////////////////////////////////////////////
//
//  But one section.
//

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

  return 1;
}

////////////////////////////////////////////////////////////////////////////////
//
//  One row for each font family.
//

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

  return [self.fontFamilyNames count];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Get the font family cell.
//

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  BDFontCell *cell = [BDFontCell cellForTableView:tableView];
  cell.fontFamilyName = [self.fontFamilyNames objectAtIndex:indexPath.row];
  if ([cell.fontFamilyName isEqualToString:self.fontFamilyName]) {
    
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
  } else {
    
    cell.accessoryType = UITableViewCellAccessoryNone;
  }
  return cell;
}

#pragma mark - Table view delegate

////////////////////////////////////////////////////////////////////////////////
//
//  Handle cell selection.
//

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

  BDFontCell *cell = (BDFontCell *)[tableView cellForRowAtIndexPath:indexPath];
  [cell setSelected:NO animated:NO];
  
  NSString *familyName = cell.fontFamilyName;
  NSString *fontName = [self.fontFamilyToFont objectForKey:familyName];
  
  if (fontName == nil) {
    
    fontName = familyName;

    _GTMDevLog(@"%s -- no specific font name found for family %@. Available fonts: %@",
               __PRETTY_FUNCTION__,
               familyName,
               [[UIFont fontNamesForFamilyName:familyName] description]);
  }
  
  self.fontFamilyName = familyName;
  [self.tableView reloadData];
  [self.delegate fontPickerController:self 
                didPickFontFamilyName:fontName];
}

@end
