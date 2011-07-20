//
//  BDGridCell.h
//
//  This is the cell that goes into a BDGridViewController. 
//
//  Created by Brian Dewey on 4/20/11.
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

//
//  The style of the BDGridCell.
//

typedef enum {
  
  //
  //  Default style: An Aspect Fit image with a caption of |captionHeight|
  //  *underneath* the image.
  //
  
  BDGridCellStyleDefault,
  
  //
  //  "Tile" style: An Aspect Fill / clip to bounds image with a caption
  //  overlaying the bottom of the image.
  //
  
  BDGridCellStyleTile
} BDGridCellStyle;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface BDGridCell : UIView {
    
}

//
//  The main image to show.
//

@property (nonatomic, retain) UIImage *image;

//
//  The cell display style.
//

@property (nonatomic, assign) BDGridCellStyle style;

//
//  The image caption.
//

@property (nonatomic, copy) NSString *caption;

//
//  Font color.
//

@property (nonatomic, retain) UIColor *fontColor;

//
//  font.
//

@property (nonatomic, retain) UIFont *font;

//
//  The index of the image in the grid.
//

@property (nonatomic, assign) NSUInteger index;

//
//  Insets applied to the content.
//

@property (nonatomic, assign) UIEdgeInsets contentInset;

//
//  The caption height
//

@property (nonatomic, assign) CGFloat captionHeight;

//
//  Selected state of the cell.
//

@property (nonatomic, assign, getter=isSelected) BOOL selected;

//
//  Designated initializer.
//

- (id)initWithStyle:(BDGridCellStyle)style;

@end
