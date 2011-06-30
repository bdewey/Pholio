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

- (void)dealloc {
  
  [photoProperties_ release];
  [super dealloc];
}

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
  
  _GTMDevLog(@"%s -- deriving thumbnail URL from %@",
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
      [thumbnailImage release];
      [completion release];
    });
  });
}

////////////////////////////////////////////////////////////////////////////////
//
//  Gets the corresponding Flickr image.
//

- (void)imageAsyncWithCompletion:(void (^)(NSString *, NSString *))completion {
  
  completion = [completion copy];
  
  dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  
  _GTMDevLog(@"%s -- getting image for photo %@", 
             __PRETTY_FUNCTION__,
             [self.photoProperties description]);
  dispatch_async(defaultQueue, ^{
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    //
    //  These are the URL properties that we should try, in order.
    //
    
    NSArray *urlProperties = [NSArray arrayWithObjects:@"url_l", @"url_o", @"url_m", nil];
    NSURL *imageUrl = nil;
    
    for (NSString *property in urlProperties) {
      
      NSString *urlString = [self.photoProperties objectForKey:property];
      if (urlString != nil) {
        
        imageUrl = [NSURL URLWithString:urlString];
        break;
      }
    }

    NSString *filename = nil;
    
    if (imageUrl != nil) {

      _GTMDevLog(@"%s -- requesting image from %@", 
                 __PRETTY_FUNCTION__,
                 imageUrl);
      NSURLRequest *request = [NSURLRequest requestWithURL:imageUrl];
      NSURLResponse *response;
      NSData *imageData = [NSURLConnection sendSynchronousRequest:request 
                                                returningResponse:&response 
                                                            error:NULL];
      
      filename = [[IPPhoto newPhotoFilename] retain];
      [imageData writeToFile:filename atomically:YES];
      
    } else {
      
      _GTMDevLog(@"%s -- cannot find the image for photo %@",
                 __PRETTY_FUNCTION__,
                 [self.photoProperties description]);
    }
    [pool drain];
    dispatch_async(dispatch_get_main_queue(), ^{
      
      //
      //  HACK. Guessing the UTI.
      //
      
      completion(filename, @"public.jpeg");
      [filename release];
      [completion release];
    });
  });
}

////////////////////////////////////////////////////////////////////////////////
//
//  Get the image title.
//

- (NSString *)title {
  
  return [self.photoProperties objectForKey:@"title"];
}

@end
