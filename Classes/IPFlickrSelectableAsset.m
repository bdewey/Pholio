//
//  IPFlickrSelectableAsset.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 5/19/11.
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

#import "IPFlickrSelectableAsset.h"
#import "IPFlickrAuthorizationManager.h"
#import "IPPhoto.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPFlickrSelectableAsset

@synthesize selected = selected_;
@synthesize photoProperties = photoProperties_;
@synthesize delegate = delegate_;

////////////////////////////////////////////////////////////////////////////////
//
//  Release retained properties.
//


////////////////////////////////////////////////////////////////////////////////
//
//  Tell the delegate about changes to our selected state.
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
//  Gets the thumbnail for this flickr photo.
//

- (void)thumbnailAsyncWithCompletion:(void (^)(UIImage *))completion {
  
  //
  //  Need a copy of the completion routine.
  //
  
  completion = [completion copy];
  
  //
  //  Get our context from the authorization manager.
  //
  
  IPFlickrAuthorizationManager *authManager = [IPFlickrAuthorizationManager sharedManager];
  OFFlickrAPIContext *context = authManager.context;
  
  //
  //  Compute the URL that has the thumbnail image.
  //
  
  DDLogVerbose(@"%s -- deriving thumbnail URL from %@",
             __PRETTY_FUNCTION__,
             [self.photoProperties description]);
  NSURL *thumbnailUrl = [context photoSourceURLFromDictionary:self.photoProperties 
                                                         size:OFFlickrSmallSquareSize];
  
  //
  //  On a background thread, send a synchronous URL request to get the image
  //  data.
  //
  
  dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  dispatch_async(defaultQueue, ^(void) {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:thumbnailUrl];
    NSURLResponse *response;
    NSData *thumbnailData = [NSURLConnection sendSynchronousRequest:request 
                                                  returningResponse:&response 
                                                              error:NULL];
    UIImage *thumbnailImage = [[UIImage alloc] initWithData:thumbnailData];
    
    //
    //  Call the completion routine on the main thread.
    //
    
    dispatch_async(dispatch_get_main_queue(), ^ {
      
      completion(thumbnailImage);
    });
  });
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  The URLs we should search for when downloading a Flickr image. We act differently if we're
//  on a retina versus non-retina device. On retina, we look for the original image first; on
//  non-retina, we look for "large" first.
//

+ (NSArray *)urlProperties {

  static NSArray *_urlProperties = nil;
  if (!_urlProperties) {
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    if (scale >= 2) {
      
      _urlProperties = @[@"url_o", @"url_l", @"url_m"];
      
    } else {
      
      _urlProperties = @[@"url_l", @"url_o", @"url_m"];
    }
  }
  return _urlProperties;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Gets the corresponding Flickr image.
//

- (void)imageAsyncWithCompletion:(void (^)(NSString *, NSString *))completion {
  
  completion = [completion copy];
  
  dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  
  DDLogVerbose(@"%s -- getting image for photo %@", 
             __PRETTY_FUNCTION__,
             [self.photoProperties description]);
  dispatch_async(defaultQueue, ^{
    
    NSString *filename = nil;
    @autoreleasepool {
      //
      //  These are the URL properties that we should try, in order.
      //
      
      NSArray *urlProperties = [IPFlickrSelectableAsset urlProperties];
      NSURL *imageUrl = nil;
      
      for (NSString *property in urlProperties) {
        
        NSString *urlString = (self.photoProperties)[property];
        if (urlString != nil) {
          
          imageUrl = [NSURL URLWithString:urlString];
          break;
        }
      }
      
      if (imageUrl != nil) {
        
        DDLogVerbose(@"%s -- requesting image from %@",
                   __PRETTY_FUNCTION__,
                   imageUrl);
        NSURLRequest *request = [NSURLRequest requestWithURL:imageUrl];
        NSURLResponse *response;
        NSData *imageData = [NSURLConnection sendSynchronousRequest:request
                                                  returningResponse:&response
                                                              error:NULL];
        
        filename = [IPPhoto filenameForNewPhoto];
        [imageData writeToFile:filename atomically:YES];
        
      } else {
        
        DDLogVerbose(@"%s -- cannot find the image for photo %@",
                   __PRETTY_FUNCTION__,
                   [self.photoProperties description]);
      }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
      
      //
      //  HACK. Guessing the UTI.
      //
      
      completion(filename, @"public.jpeg");
    });
  });
}

////////////////////////////////////////////////////////////////////////////////
//
//  Get the image title.
//

- (NSString *)title {
  
  return (self.photoProperties)[@"title"];
}

@end
