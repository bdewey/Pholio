//
//  BDFontPickerController.h
//
//  Let the user pick a font.
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

#import <UIKit/UIKit.h>

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@protocol BDFontPickerControllerDelegate;
@interface BDFontPickerController : UITableViewController { }

//
//  The delegate responds to changes in the font family name.
//

@property (nonatomic, weak) id<BDFontPickerControllerDelegate> delegate;

//
//  Name of the selected font family name.
//

@property (nonatomic, copy) NSString *fontFamilyName;

//
//  Mapping of font family names to font names. If there is an entry here,
//  then the corresponding font name is passed back to the delegate instead
//  of the font family name.
//

@property (nonatomic, strong) NSDictionary *fontFamilyToFont;

//
//  Do we show all font families, or only the families that have an entry
//  in |fontFamilyToFont|?
//

@property (nonatomic, assign) BOOL showOnlyMappedFonts;

//
//  Designated initializer.
//

- (id)init;

@end

@protocol BDFontPickerControllerDelegate <NSObject>

- (void)fontPickerController:(BDFontPickerController *)controller 
       didPickFontFamilyName:(NSString *)fontFamilyName;

@end
