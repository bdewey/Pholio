//
//  IPDropBoxConnectionCell.m
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

#import "IPDropBoxConnectionCell.h"
#import "DropboxSDK.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPDropBoxConnectionCell

////////////////////////////////////////////////////////////////////////////////

- (id)initWithCellIdentifier:(NSString *)cellIdentifier {
  
  self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
  if (self != nil) {
    
    self.textLabel.text = @"DropBox";
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////

- (void)configureCell {
  
  if ([[DBSession sharedSession] isLinked]) {

    self.textLabel.text = @"Disconnect from DropBox";
    
  } else {
    
    self.textLabel.text = @"DropBox";
  }
}

////////////////////////////////////////////////////////////////////////////////

- (BOOL)isConnected {
  
  return [[DBSession sharedSession] isLinked];
}

@end
