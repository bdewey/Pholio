//
//  IPPhotoTilingView.h
//
//  Uses a CATiledLayer to efficiently display large |IPPhoto| classes.
//
//  Created by Brian Dewey on 6/5/11.
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

@class IPPhoto;
@interface IPPhotoTilingView : UIView { }

//
//  The photo to display.
//

@property (nonatomic, strong) IPPhoto *photo;

//
//  Set to YES to draw borders around each tile.
//

@property (nonatomic, assign) BOOL annotates;

//
//  The maximum scale for which tiles have been calculated.
//

@property (nonatomic, assign) CGFloat maximumScale;

@end
