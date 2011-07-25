//
//  UIImage+ColorMask.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 7/24/11.
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
#import <QuartzCore/QuartzCore.h>
#import "UIImage+ColorMask.h"

@implementation UIImage (ColorMask)

////////////////////////////////////////////////////////////////////////////////

- (UIImage *)imageAsMaskOnColor:(UIColor *)color {
  
  CGSize imageSize = self.size;
  CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                              imageSize.width,
                                              imageSize.height,
                                              8,
                                              0,
                                              rgbColorSpace,
                                              kCGImageAlphaPremultipliedFirst);
  CGRect maskRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
  CGContextClipToMask(bitmap, maskRect, [self CGImage]);
  CGContextSetFillColorWithColor(bitmap, [color CGColor]);
  CGContextFillRect(bitmap, maskRect);
  CGImageRef masked = CGBitmapContextCreateImage(bitmap);
  UIImage *maskedImage = [UIImage imageWithCGImage:masked];
  
  CFRelease(rgbColorSpace);
  CFRelease(bitmap);
  CFRelease(masked);
  return maskedImage;
}

@end
