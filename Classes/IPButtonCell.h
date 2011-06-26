//
//  IPButtonCell.h
//
//  This cell is a button. You should perform the requested |action| on
//  |target| when it is selected.
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

#import <Foundation/Foundation.h>
#import "BDSmartTableViewCell.h"

@interface IPButtonCell : BDSmartTableViewCell { }

//
//  The title of the button.
//

@property (nonatomic, copy) NSString *title;

//
//  The target of the action.
//

@property (nonatomic, assign) id target;

//
//  The action to perform.
//

@property (nonatomic, assign) SEL action;


@end
