//
//  UIImage+Border.h
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

#import <Foundation/Foundation.h>


@interface UIImage (UIImage_Border)

//
//  Put an border of the specified width and color on the image.
//

- (UIImage *)imageWithBorderWidth:(CGFloat)borderSize andColor:(CGColorRef)color;
@end
