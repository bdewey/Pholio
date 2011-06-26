//
//  BDSmartTableViewCell.h
//
//  Design comes from "iOS Recipes" book.
//
//  This is a table cell superclass that simplifies creating custom table cells.
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

#import <UIKit/UIKit.h>

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface BDSmartTableViewCell : UITableViewCell { }

//
//  Gets a cell.
//

+ (id)cellForTableView:(UITableView *)tableView;

//
//  Identifier for this cell class (for cell reuse)
//

+ (NSString *)cellIdentifier;

//
//  Initialize the cell. Subclasses should override this.
//

- (id)initWithCellIdentifier:(NSString *)cellIdentifier;

@end
