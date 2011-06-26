//
//  UIImage+Border.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 4/24/11.
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

#import "UIImage+Border.h"
#import "UIImage+Alpha.h"


@implementation UIImage (UIImage_Border)

////////////////////////////////////////////////////////////////////////////////
//
//  Create a new image that is a copy of the receiver with a colored border.
//

- (UIImage *)imageWithBorderWidth:(CGFloat)borderSize andColor:(CGColorRef)color {
  
  //
  //  The new rect is big enough to hold the image plus the border.
  //
  
  CGRect newRect = CGRectMake(0, 0, 
                              self.size.width  + borderSize * 2, 
                              self.size.height + borderSize * 2);
  
  CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
  
  //
  //  We need to make sure we're working with an image with an alpha channel;
  //  otherwise we might not get a valid bitmap context.
  //

  UIImage *imageWithAlpha = [self imageWithAlpha];
  CGImageRef cgImage = [imageWithAlpha CGImage];
  CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                              newRect.size.width,
                                              newRect.size.height,
                                              8,
                                              0,
                                              rgbColorSpace,
                                              kCGImageAlphaPremultipliedFirst);

  //
  //  Paint the entire bitmap with the border color.
  //
  
  CGContextSetFillColorWithColor(bitmap, color);
  CGContextFillRect(bitmap, newRect);
  
  // Draw the image in the center of the context, leaving a gap around the edges
  CGRect imageLocation = CGRectMake(borderSize, borderSize, imageWithAlpha.size.width, imageWithAlpha.size.height);
  CGContextDrawImage(bitmap, imageLocation, cgImage);
  CGImageRef borderImageRef = CGBitmapContextCreateImage(bitmap);
  UIImage *borderImage = [UIImage imageWithCGImage:borderImageRef];
  
  // Clean up
  CGContextRelease(bitmap);
  CGImageRelease(borderImageRef);
  CGColorSpaceRelease(rgbColorSpace);
  
  return borderImage;
}

@end
