//
//  BDSelectableAsset.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 5/6/11.
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

#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "BDSelectableALAsset.h"
#import "IPPhoto.h"
#import "IPPhotoOptimizationManager.h"

@interface BDSelectableALAsset()

//
//  These are the UTIs that I understand.
//

@property (nonatomic, readonly) NSArray *imageUTIs;
@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation BDSelectableALAsset

@synthesize asset = asset_;
@synthesize selected = selected_;
@synthesize delegate = delegate_;
@synthesize imageUTIs = imageUTIs_;

////////////////////////////////////////////////////////////////////////////////
//
//  Designated initializer.
//

- (id)initWithAsset:(ALAsset *)asset {
  
  self = [super init];
  if (self != nil) {
    
    self.asset = asset;
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release all retained properties.
//


////////////////////////////////////////////////////////////////////////////////
//
//  Convenience constructor.
//

+ (BDSelectableALAsset *)selectableAssetWithAsset:(ALAsset *)asset {
  
  return [[BDSelectableALAsset alloc] initWithAsset:asset];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Gets the thumbnail image for this asset.
//

- (void)thumbnailAsyncWithCompletion:(void (^)(UIImage *))completion {
  
  completion([UIImage imageWithCGImage:[self.asset thumbnail]]);
}

////////////////////////////////////////////////////////////////////////////////
//
//  Gets the image associated with this asset.
//

- (void)imageAsyncWithCompletion:(void (^)(NSString *, NSString *))completion {
  
  completion = [completion copy];

  //
  //  While I'll do this async (i.e., the method returns to the caller right away),
  //  you can't call the ALAsset functions on anything but the main thread.
  //  So this block will just get queued up onto the main thread and completed
  //  in one go.
  //
  
  NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^(void) {
      
    //
    //  General strategy: Create a CGImageSourceRef from the raw asset image.
    //  If the image size would be too big, have ImageIO thumbnail the image for
    //  us. Otherwise, get the full image. Then, save to JPEG.
    //
    
    NSString *filename = nil;
    @autoreleasepool {
      
      UIImageOrientation orientation = [[self.asset valueForProperty:ALAssetPropertyOrientation] intValue];
      ALAssetRepresentation *representation = [self.asset defaultRepresentation];
      NSDictionary *metadata = [representation metadata];
      CGFloat width = [[metadata objectForKey:(id)kCGImagePropertyPixelWidth] floatValue];
      CGFloat height = [[metadata objectForKey:(id)kCGImagePropertyPixelHeight] floatValue];
      CGFloat maxEdge = MAX(width, height);
      _GTMDevLog(@"%s -- maxEdge is %f (%f, %f)", __PRETTY_FUNCTION__, maxEdge, width, height);
      
      //
      //  Get the raw bytes and create a CGImageSourceRef.
      //
      
      NSMutableData *imageBytes = [[NSMutableData alloc] initWithLength:[representation size]];
      [representation getBytes:[imageBytes mutableBytes] fromOffset:0 length:[representation size] error:NULL];
      
      CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageBytes, NULL);
      CGImageRef theImage = NULL;
      
      if (maxEdge > kIPPhotoMaxEdgeSize) {
        
        //
        //  We need ImageIO to generate a thumbnail for us.
        //
        
        NSDictionary *thumbnailOptions = [NSDictionary dictionaryWithObjectsAndKeys:(id)kCFBooleanFalse, kCGImageSourceCreateThumbnailWithTransform,
                                          kCFBooleanTrue, kCGImageSourceCreateThumbnailFromImageAlways,
                                          [NSNumber numberWithFloat:kIPPhotoMaxEdgeSize], kCGImageSourceThumbnailMaxPixelSize,
                                          nil];
        theImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (__bridge CFDictionaryRef)thumbnailOptions);
        
      } else {
        
        theImage = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
      }
      
      CFRelease(imageSource);
      
      if (theImage != NULL) {
        
        UIImage *uiImage = [[UIImage alloc] initWithCGImage:theImage scale:1.0 orientation:orientation];
        NSData *jpegData = UIImageJPEGRepresentation(uiImage, 0.8);
        filename = [IPPhoto filenameForNewPhoto];
        [jpegData writeToFile:filename atomically:YES];
        CFRelease(theImage);
      }
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
      
      completion(filename, @"public.jpeg");
    }];
  }];
  
  [operation setQueuePriority:NSOperationQueuePriorityNormal];
  [[[IPPhotoOptimizationManager sharedManager] optimizationQueue] addOperation:operation];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Images from the asset library have no title.
//

- (NSString *)title {
  
  return nil;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Sets the selected state of this asset.
//

- (void)setSelected:(BOOL)selected {
  
  selected_ = selected;
  
  if (self.selected) {
    
    [self.delegate selectableAssetDidSelect:self];
    
  } else {
    
    [self.delegate selectableAssetDidUnselect:self];
  }
}

////////////////////////////////////////////////////////////////////////////////
//
//  The image UTIs we understand.
//

- (NSArray *)imageUTIs {
  
  if (imageUTIs_ != nil) {
    
    return imageUTIs_;
  }
  imageUTIs_ = [[NSArray alloc] initWithObjects:@"public.jpeg", @"public.png", nil];
  return imageUTIs_;
}
@end
