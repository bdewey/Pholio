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

- (void)dealloc {
  
  [asset_ release];
  [imageUTIs_ release];
  [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Convenience constructor.
//

+ (BDSelectableALAsset *)selectableAssetWithAsset:(ALAsset *)asset {
  
  return [[[BDSelectableALAsset alloc] initWithAsset:asset] autorelease];
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
  
  [[[IPPhotoOptimizationManager sharedManager] optimizationQueue] addOperationWithBlock:^(void) {

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSString *uti = nil;
    ALAssetRepresentation *representation;
    NSString *filename = nil;
    
    //
    //  Look to see if I understand the raw data of the asset. If I do, just
    //  copy the bytes over.
    //
    
    if (NO) {
      
      //
      //  bdewey 2011-06-30 Skip this for now until I'm better at handling 
      //  large images.
      //
      
      for (uti in self.imageUTIs) {
        
        representation = [self.asset representationForUTI:uti];
        if (representation != nil) {
          
          long long size = [representation size];
          NSMutableData *bytes = [[NSMutableData alloc] initWithLength:size];
          _GTMDevLog(@"%s -- found representation %@ (%lld bytes)",
                     __PRETTY_FUNCTION__,
                     uti,
                     size);
          [representation getBytes:[bytes mutableBytes] fromOffset:0 length:size error:NULL];
          filename = [[IPPhoto filenameForNewPhoto] retain];
          [bytes writeToFile:filename atomically:YES];
          [bytes release];
          break;
        }
      }
    }
    
    if (filename == nil) {

      //
      //  If we couldn't find one of the representations we know, then decode
      //  the image into memory and save it out.
      //
      
      uti = @"public.jpeg";
      UIImageOrientation orientation = [[self.asset valueForProperty:ALAssetPropertyOrientation] intValue];
      representation = [self.asset defaultRepresentation];
      UIImage *image = [[UIImage alloc] initWithCGImage:[representation fullScreenImage] scale:1.0 orientation:orientation];
      filename = [[IPPhoto filenameForNewPhoto] retain];
      NSData *jpegData = UIImageJPEGRepresentation(image, 0.8);
      _GTMDevLog(@"%s -- couldn't find UTI. Wrote %d jpeg bytes",
                 __PRETTY_FUNCTION__,
                 [jpegData length]);
      [jpegData writeToFile:filename atomically:YES];
      [image release];
    }
    [pool drain];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
      
      completion(filename, uti);
      [filename release];
      [completion release];
    }];
  }];
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
