//
//  IPCustomAppearanceController.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 5/9/11.
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

#import "IPSettingsController.h"
#import "IPCustomAppearanceController.h"
#import "IPCustomBackgroundCell.h"
#import "BDFontPickerController.h"

//
//  The sections in our table.
//

typedef enum {
  IPCustomAppearanceSectionPresets,
  IPCustomAppearanceSectionNumItems,
  IPCustomAppearanceSectionFonts
} IPCustomAppearanceSections;

#define kIPCustomAppearanceSectionTitlePreset NSLocalizedString(@"Backgrounds", @"Backgrounds")
#define kIPCustomAppearanceSectionTitleFonts  NSLocalizedString(@"Fonts", @"Fonts")

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface IPCustomAppearanceController ()

- (NSArray *)imageNames;
- (NSArray *)imageTitles;
- (NSArray *)fontColors;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForPresetRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForFontRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)tableView:(UITableView *)tableView didSelectPresetRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectFontRowAtIndexPath:(NSIndexPath *)indexPath;

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPCustomAppearanceController

@synthesize selectedImageName = selectedImageName_;
@synthesize delegate = delegate_;

////////////////////////////////////////////////////////////////////////////////
//
//  Designated initializer.
//

- (id)init {
  
  self = [super initWithStyle:UITableViewStyleGrouped];
  if (self) {

    self.title = kCustomBackground;
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release retained properties.
//


////////////////////////////////////////////////////////////////////////////////
//
//  Free memory.
//

- (void)didReceiveMemoryWarning {
  
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

////////////////////////////////////////////////////////////////////////////////
//
//  We rotate.
//

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

  // Return YES for supported orientations
  return YES;
}

#pragma mark - Table view data source

////////////////////////////////////////////////////////////////////////////////
//
//  We have 1 section.
//

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

  return IPCustomAppearanceSectionNumItems;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Get the number of rows.
//

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

  switch (section) {
    case IPCustomAppearanceSectionFonts:
      return 1;
      
    case IPCustomAppearanceSectionPresets:
      return [[self imageNames] count];
      
    default:
      _GTMDevAssert(NO, @"Unrecognized section: %d", section);
      return 0;
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  Get the section titles.
//

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  
  switch (section) {
    case IPCustomAppearanceSectionPresets:
      return kIPCustomAppearanceSectionTitlePreset;
      
    case IPCustomAppearanceSectionFonts:
      return kIPCustomAppearanceSectionTitleFonts;
      
    default:
      _GTMDevAssert(NO, @"Unrecognized section: %d", section);
      return nil;
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  Master routine to get cells for a row.
//

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  switch (indexPath.section) {
    case IPCustomAppearanceSectionPresets:
      return [self tableView:tableView cellForPresetRowAtIndexPath:indexPath];
      
    case IPCustomAppearanceSectionFonts:
      return [self tableView:tableView cellForFontRowAtIndexPath:indexPath];
      
    default:
      _GTMDevAssert(NO, @"Unrecognized section: %d", indexPath.section);
      return nil;
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  Gets a cell for |IPCustomAppearanceSectionPresets|.
//

- (UITableViewCell *)tableView:(UITableView *)tableView cellForPresetRowAtIndexPath:(NSIndexPath *)indexPath {

  IPCustomBackgroundCell *cell = [IPCustomBackgroundCell cellForTableView:tableView];
  NSUInteger row = [indexPath row];
  cell.imageName = [[self imageNames] objectAtIndex:row];
  cell.title     = [[self imageTitles] objectAtIndex:row];
  cell.checkmark = [self.selectedImageName isEqualToString:cell.imageName];
  return cell;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Gets a cell for |IPCustomAppearanceSectionFonts|.
//

- (UITableViewCell *)tableView:(UITableView *)tableView cellForFontRowAtIndexPath:(NSIndexPath *)indexPath {

  UITableViewCell *cell;
  cell = [tableView dequeueReusableCellWithIdentifier:@"BDFontPickerController"];
  if (cell == nil) {
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"BDFontPickerController"];
  }
  cell.textLabel.text = @"Title font";
  cell.detailTextLabel.text = @"Futura";
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  return cell;
}

#pragma mark - Table view delegate

////////////////////////////////////////////////////////////////////////////////
//
//  Master cell selection code.
//

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  switch (indexPath.section) {
    case IPCustomAppearanceSectionPresets:
      [self tableView:tableView didSelectPresetRowAtIndexPath:indexPath];
      break;
      
    case IPCustomAppearanceSectionFonts:
      [self tableView:tableView didSelectFontRowAtIndexPath:indexPath];
      break;
      
    default:
      _GTMDevAssert(NO, @"Unrecognized section: %d", indexPath.section);
      break;
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  On cell selection, update its checkmark state and clear the checkmark state
//  of any other rows.
//

- (void)tableView:(UITableView *)tableView didSelectPresetRowAtIndexPath:(NSIndexPath *)indexPath {

  IPCustomBackgroundCell *cell = (IPCustomBackgroundCell *)[tableView cellForRowAtIndexPath:indexPath];
  self.selectedImageName = cell.imageName;
  [self.tableView reloadData];
  
  //
  //  Breaking with pattern. Inform the delegate directly of the change to the
  //  font color.
  //
  
  NSArray *fontColors = [self fontColors];
  [self.delegate ipSettingsSetGridTextColor:[fontColors objectAtIndex:indexPath.row]];
}

////////////////////////////////////////////////////////////////////////////////
//
//  A cell was picked from the font section.
//

- (void)tableView:(UITableView *)tableView didSelectFontRowAtIndexPath:(NSIndexPath *)indexPath {
  
  BDFontPickerController *fontPicker = [[BDFontPickerController alloc] init];
  [self.navigationController pushViewController:fontPicker animated:YES];
}

#pragma mark - Underlying image data

////////////////////////////////////////////////////////////////////////////////
//
//  When |selectedImageName| is set, tell the delegate.
//

- (void)setSelectedImageName:(NSString *)selectedImageName {
  
  selectedImageName_ = [selectedImageName copy];
  
  [self.delegate ipSettingsSetBackgroundImageName:self.selectedImageName];
}

////////////////////////////////////////////////////////////////////////////////
//
//  The image file names.
//

- (NSArray *)imageNames {
  
  static NSArray *imageNames_ = nil;
  
  if (imageNames_ == nil) {
    imageNames_ = [[NSArray alloc] initWithObjects:
                   @"black.jpg",
                   @"purple.jpg",
                   @"dark_texture.jpg",
                   @"light_texture.jpg",
                   @"drops.jpg",
                   @"blue.jpg",
                   @"gold.jpg",
                   nil];
  }
  return imageNames_;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Font colors that correspond to the images.
//

- (NSArray *)fontColors {
  
  static NSArray *fontColors_ = nil;
  
  if (fontColors_ == nil) {
    
    fontColors_ = [[NSArray alloc] initWithObjects:
                   [UIColor whiteColor],
                   [UIColor blackColor], 
                   [UIColor whiteColor],
                   [UIColor blackColor],
                   [UIColor blackColor],
                   [UIColor blackColor],
                   [UIColor blackColor],
                   nil];
  }
  return fontColors_;
}

////////////////////////////////////////////////////////////////////////////////
//
//  the image titles (text that's displayed to the user)
//

- (NSArray *)imageTitles {
  
  static NSArray *imageTitles_ = nil;
  if (imageTitles_ == nil) {
    
    imageTitles_ = [[NSArray alloc] initWithObjects:
                    @"Black",
                    @"Purple", 
                    @"Dark texture",
                    @"Light texture",
                    @"Drops",
                    @"Blue",
                    @"Gold",
                    nil];
  }
  return imageTitles_;
}

@end
