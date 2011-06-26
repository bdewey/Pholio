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
#import "IPPhotoTilingManager.h"
#import "IPOptimizingPhotoNotification.h"

@interface IPPhotoScrollView ()

//
//  This is the view that contains the photo. We allow scrolling/panning/zooming
//  over this view.
//

@property (nonatomic, retain) UIView *imageView;

//
//  Displayed when we're tiling the image...
//

@property (nonatomic, retain) IPOptimizingPhotoNotification *busyIndicator;

- (void)setMaxMinZoomScalesForCurrentBounds;

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPPhotoScrollView

@synthesize photo = photo_;
@synthesize imageView = imageView_;
@synthesize busyIndicator = busyIndicator_;

////////////////////////////////////////////////////////////////////////////////
//
//  Initializer.
//

- (id)initWithFrame:(CGRect)frame {
  
  self = [super initWithFrame:frame];
  if (self != nil) {
    
    self.delegate = self;
    busyIndicator_ = [[IPOptimizingPhotoNotification alloc] init];
    [busyIndicator_ stopAnimating];
    [self addSubview:busyIndicator_.view];
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release retained properties.
//

- (void)dealloc {
  
  _GTMDevLog(@"%s -- pointer 0x%08x", __PRETTY_FUNCTION__, self);
  [photo_ release];
  [imageView_ release];
  [busyIndicator_ release];
  [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Center the subview.
//

- (void)layoutSubviews {
  
  [super layoutSubviews];
  self.busyIndicator.view.center = CGPointMake(self.bounds.size.width / 2, 
                                          self.bounds.size.height / 2);
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
  
  if (levelsOfDetail <= 1) {
    
    //
    //  With only one level, no point in using a tiling view.
    //
    
    self.imageView = [[[UIImageView alloc] initWithImage:self.photo.image] autorelease];
    [self.busyIndicator stopAnimating];
    
  } else { 

    //
    //  We're going to set up a tiling view for this image.
    //
    
    CGRect imageFrame = CGRectMake(0, 0, self.photo.image.size.width, self.photo.image.size.height);
    IPPhotoTilingView *tilingView = [[[IPPhotoTilingView alloc] initWithFrame:imageFrame] autorelease];
    tilingView.photo = self.photo;
    self.imageView = tilingView;
    
    //
    //  Now, make sure that we have tiles for the photo.
    //
    
    [self.busyIndicator startAnimating];
    __block CGFloat maximumSeenScale = 0.0;
    __block BOOL firstCallback = YES;
    IPPhoto *currentPhoto = self.photo;
    [[IPPhotoTilingManager sharedManager] asyncTilePhoto:self.photo withCompletion:^(CGFloat scale) {

      if (currentPhoto != self.photo) {
        
        _GTMDevLog(@"%s -- self.photo is not the photo we started tiling. Ignoring completion routine.",
                   __PRETTY_FUNCTION__);
        return;
      }
      if (firstCallback) {
        
        [self.imageView setNeedsDisplay];
        firstCallback = NO;
      }
      if ([self.busyIndicator isAnimating] && (scale == 1.0)) {
        
        [self.busyIndicator stopAnimating];
      }
      maximumSeenScale = MAX(maximumSeenScale, scale);
      _GTMDevLog(@"%s -- maximum seen scale is %f", __PRETTY_FUNCTION__, maximumSeenScale);
      self.maximumZoomScale = maximumSeenScale;
      ((IPPhotoTilingView *)self.imageView).maximumScale = maximumSeenScale;
    }];
  }
  
  [self insertSubview:self.imageView belowSubview:self.busyIndicator.view];
  
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
