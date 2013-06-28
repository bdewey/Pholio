//
//  IPPhotoTilingView.m
//  ipad-portfolio
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

#import <QuartzCore/QuartzCore.h>
#import "IPPhotoTilingView.h"
#import "IPPhoto.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPPhotoTilingView

@synthesize photo = photo_;
@synthesize annotates = annotates_;
@synthesize maximumScale = maximumScale_;

////////////////////////////////////////////////////////////////////////////////
//
//  Initializer.
//

- (id)initWithFrame:(CGRect)frame {

  self = [super initWithFrame:frame];
  if (self) {

    self.maximumScale = 1.0;
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release retained properties.
//


#pragma mark - Properties

////////////////////////////////////////////////////////////////////////////////
//
//  When the photo gets set, figure out the levels of detail we will compute.
//

- (void)setPhoto:(IPPhoto *)photo {
  
  photo_ = photo;
  
  CATiledLayer *layer = (CATiledLayer *)[self layer];
  layer.levelsOfDetail = [photo levelsOfDetail];
  layer.tileSize = [photo defaultTileSize];
  DDLogVerbose(@"%s -- set levels of detail to %ld", 
             __PRETTY_FUNCTION__, 
             layer.levelsOfDetail);
}

#pragma mark - Drawing

////////////////////////////////////////////////////////////////////////////////
//
//  We use a CATiledLayer for drawing.
//

+ (Class)layerClass {
  
  return [CATiledLayer class];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Draw!
//
//  Code based on Apple's PhotoScroller example.
//

- (void)drawRect:(CGRect)rect {
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  // get the scale from the context by getting the current transform matrix, then asking for
  // its "a" component, which is one of the two scale components. We could also ask for "d".
  // This assumes (safely) that the view is being scaled equally in both dimensions.
  CGFloat scale = CGContextGetCTM(context).a;
  
  CFDictionaryRef rectDict = CGRectCreateDictionaryRepresentation(rect);
  DDLogVerbose(@"%s -- scale = %f, rect = %@", 
             __PRETTY_FUNCTION__,
             scale,
             rectDict);
  CFRelease(rectDict);
  CATiledLayer *tiledLayer = (CATiledLayer *)[self layer];
  CGSize tileSize = tiledLayer.tileSize;
  
  //
  //  Round |scale| to the nearest power of two.
  //
  
  // scale = powf(2.0, roundf(log2f(scale)));
  
  //
  //  If scale is greater than the maximum scale, clamp it.
  //
  
  if (scale > self.maximumScale) {
    
    DDLogVerbose(@"%s -- scale = %f, maximum scale = %f; clamping.",
               __PRETTY_FUNCTION__,
               scale,
               self.maximumScale);
    scale = self.maximumScale;
  }
  
  if (scale < [self.photo minimumTileScale]) {
    
    DDLogVerbose(@"%s -- scale is %f. Minimum scale is %f. Levels of detail: photo %ld, layer %ld",
               __PRETTY_FUNCTION__,
               scale,
               [self.photo minimumTileScale],
               [self.photo levelsOfDetail],
               tiledLayer.levelsOfDetail);
    
    //
    //  I don't expect to be here.
    //
    
    // scale = [self.photo minimumTileScale];
  }
  
  
  // Even at scales lower than 100%, we are drawing into a rect in the coordinate system of the full
  // image. One tile at 50% covers the width (in original image coordinates) of two tiles at 100%. 
  // So at 50% we need to stretch our tiles to double the width and height; at 25% we need to stretch 
  // them to quadruple the width and height; and so on.
  // (Note that this means that we are drawing very blurry images as the scale gets low. At 12.5%, 
  // our lowest scale, we are stretching about 6 small tiles to fill the entire original image area. 
  // But this is okay, because the big blurry image we're drawing here will be scaled way down before 
  // it is displayed.)
  tileSize.width /= scale;
  tileSize.height /= scale;
  
  // calculate the rows and columns of tiles that intersect the rect we have been asked to draw
  int firstCol = floorf(CGRectGetMinX(rect) / tileSize.width);
  int lastCol = floorf((CGRectGetMaxX(rect)-1) / tileSize.width);
  int firstRow = floorf(CGRectGetMinY(rect) / tileSize.height);
  int lastRow = floorf((CGRectGetMaxY(rect)-1) / tileSize.height);
  
  for (int row = firstRow; row <= lastRow; row++) {
    for (int col = firstCol; col <= lastCol; col++) {
      @autoreleasepool {
        UIImage *tile = [self.photo tileForScale:scale row:row column:col];
        CGRect tileRect = CGRectMake(tileSize.width * col, tileSize.height * row,
                                     tileSize.width, tileSize.height);
        
        // if the tile would stick outside of our bounds, we need to truncate it so as to avoid
        // stretching out the partial tiles at the right and bottom edges
        tileRect = CGRectIntersection(self.bounds, tileRect);
        
        [tile drawInRect:tileRect];
        
        if (self.annotates) {
          [[UIColor whiteColor] set];
          CGContextSetLineWidth(context, 6.0 / scale);
          CGContextStrokeRect(context, tileRect);
        }
      }
    }
  }
}

@end
