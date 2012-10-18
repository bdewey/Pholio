//
//  BDSmartTableViewCell.m
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

#import "BDSmartTableViewCell.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation BDSmartTableViewCell

////////////////////////////////////////////////////////////////////////////////
//
//  Gets a cell for the table view. Uses the class method |cellIdentifier| to
//  determine the cell identifier for cell reuse. If the cell needs to get
//  created, it will be initialized with |initWithCellIdentifier:|.
//

+ (id)cellForTableView:(UITableView *)tableView {
  
  NSString *cellIdentifier = [self cellIdentifier];
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (cell == nil) {
    
    cell = [[self alloc] initWithCellIdentifier:cellIdentifier];
  }
  return cell;
}

////////////////////////////////////////////////////////////////////////////////
//
//  The default cell identifier -- defaults to the class name.
//

+ (NSString *)cellIdentifier {
  
  return NSStringFromClass([self class]);
}

////////////////////////////////////////////////////////////////////////////////
//
//  Designated initializer.
//

- (id)initWithCellIdentifier:(NSString *)cellIdentifier {
  
  return [self initWithStyle:UITableViewCellStyleDefault 
             reuseIdentifier:cellIdentifier];
}



@end
