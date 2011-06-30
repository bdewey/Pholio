//
//  IPPhotoScrollView.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 6/4/11.
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

#import "IPPhotoScrollView.h"
#import "IPPhoto.h"
#import "IPPhotoTilingView.h"
#import "IPPhotoOptimizationManager.h"

@interface IPPhotoScrollView ()

//
//  This is the view that contains the photo. We allow scrolling/panning/zooming
//  over this view.
//

@property (nonatomic, retain) UIView *imageView;

- (void)setMaxMinZoomScalesForCurrentBounds;

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPPhotoScrollView

@synthesize photo = photo_;
@synthesize imageView = imageView_;

////////////////////////////////////////////////////////////////////////////////
//
//  Initializer.
//

- (id)initWithFrame:(CGRect)frame {
  
  self = [super initWithFrame:frame];
  if (self != nil) {
    
    self.delegate = self;
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release retained properties.
//

- (void)dealloc {
  
  [photo_ release];
  [imageView_ release];
  [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Center the subview.
//

- (void)layoutSubviews {
  
  [super layoutSubviews];
  CGRect frameToCenter = self.imageView.frame;
  
  if (frameToCenter.size.width < self.bounds.size.width) {
    
    frameToCenter.origin.x = (self.bounds.size.width - frameToCenter.size.width) / 2;
    
  } else {
    
    frameToCenter.origin.x = 0;
  }
  
  if (frameToCenter.size.height < self.bounds.size.height) {
    
    frameToCenter.origin.y = (self.bounds.size.height - frameToCenter.size.height) / 2;
    
  } else {
    
    frameToCenter.origin.y = 0;
  }
  
  self.imageView.frame = frameToCenter;
}

#pragma mark - Properties

////////////////////////////////////////////////////////////////////////////////
//
//  Set the photo we are displaying.
//

- (void)setPhoto:(IPPhoto *)photo {
  
  [photo_ autorelease];
  photo_ = [photo retain];
  
  //
  //  Clear the previous imageView.
  //
  
  [self.imageView removeFromSuperview];
  self.imageView = nil;
  
  self.zoomScale = 1.0;
  size_t levelsOfDetail = [self.photo levelsOfDetail];
  
  if (![photo isOptimized]) {

    _GTMDevLog(@"%s -- unexpectedly optimizing a photo", __PRETTY_FUNCTION__);
    [photo optimize];
  }
  
  if (levelsOfDetail <= 1) {
    
    //
    //  With only one level, no point in using a tiling view.
    //
    
    self.imageView = [[[UIImageView alloc] initWithImage:self.photo.image] autorelease];
    
  } else { 

    //
    //  We're going to set up a tiling view for this image.
    //
    
    CGRect imageFrame = CGRectMake(0, 0, self.photo.imageSize.width, self.photo.imageSize.height);
    IPPhotoTilingView *tilingView = [[[IPPhotoTilingView alloc] initWithFrame:imageFrame] autorelease];
    tilingView.photo = self.photo;
    self.imageView = tilingView;
    
    self.maximumZoomScale = 1.0;
  }
  
  [self addSubview:self.imageView];
  
  self.contentSize = self.photo.imageSize;
  [self setMaxMinZoomScalesForCurrentBounds];
  self.zoomScale = self.minimumZoomScale;
}

////////////////////////////////////////////////////////////////////////////////
//
//  We've set a frame... recompute the zoom scale.
//

- (void)setFrame:(CGRect)frame {
  
  if (CGRectEqualToRect(frame, self.frame)) {
    
    return;
  }
  [super setFrame:frame];
  [self setMaxMinZoomScalesForCurrentBounds];
  self.zoomScale = self.minimumZoomScale;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Compute the zoom scale for the current image.
//
//  From the Apple "PhotoScroller" example.
//

- (void)setMaxMinZoomScalesForCurrentBounds {

  CGSize boundsSize = self.bounds.size;
  CGSize imageSize = self.imageView.bounds.size;
  
  // calculate min/max zoomscale
  CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
  CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
  CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
  
  // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
  // maximum zoom scale to 0.5.
  CGFloat maxScale = 1.0 / [[UIScreen mainScreen] scale];
  
  // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.) 
  if (minScale > maxScale) {
    minScale = maxScale;
  }
  
  CFDictionaryRef boundsSizeDict = CGSizeCreateDictionaryRepresentation(boundsSize);
  CFDictionaryRef imageSizeDict  = CGSizeCreateDictionaryRepresentation(self.imageView.bounds.size);
  _GTMDevLog(@"%s -- min scale = %f, max scale = %f. Bounds size = %@, image bounds = %@",
        __PRETTY_FUNCTION__,
        minScale,
        maxScale,
        boundsSizeDict,
        imageSizeDict);
  CFRelease(boundsSizeDict);
  CFRelease(imageSizeDict);
  
  
  self.maximumZoomScale = maxScale;
  self.minimumZoomScale = minScale;
}

#pragma mark - UIScrollViewDelegate

////////////////////////////////////////////////////////////////////////////////
//
//  We zoom |imageView|.
//

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
  
  return self.imageView;
}

@end
