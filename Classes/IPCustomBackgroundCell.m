//
//  IPCustomBackgroundCell.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 5/9/11.
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

#import "IPCustomBackgroundCell.h"
#import "UIImage+Resize.h"


#define kThumbnailSize        35
#define kRoundedEdge          5

@interface IPCustomBackgroundCell ()

@property (nonatomic, retain) UIImageView *thumbnailImageView;

- (void)getThumbnailForImageNamed:(NSString *)image completion:(void (^)(UIImage *))completion;

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPCustomBackgroundCell

@synthesize imageName = imageName_;
@dynamic title;
@dynamic disclosureIndicator;
@dynamic checkmark;
@synthesize thumbnailImageView = thumbnailImageView_;

////////////////////////////////////////////////////////////////////////////////
//
//  Initializer.
//

- (id)initWithCellIdentifier:(NSString *)cellIdentifier {
  
  self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
  return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release all retained properties.
//

- (void)dealloc {
  
  [imageName_ release];
  [thumbnailImageView_ release];
  [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Gets an image from |imageName|, resizes it, and then passes the resized image
//  to the completion routine on the main thread.
//
//  ASSUMPTION: |imageName| is a file name of an image *without* a path
//  (e.g., it will come from the bundle by default). There is a thumbnail version
//  of the file that follows this pattern: "file.jpg" --> "file-thumb.jpg".
//  This routine will load the "-thumb.jpg" file.
//  
//

- (void)getThumbnailForImageNamed:(NSString *)imageName completion:(void (^)(UIImage *))completion {
  
  dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  
  //
  //  Need to copy the completion routine so we can access it from the background
  //  thread.
  //
  
  completion = [completion copy];
  
  dispatch_async(defaultQueue, ^(void) {
    
    //
    //  In the background, load & resize the image.
    //
    
    NSString *thumbName = [imageName stringByDeletingPathExtension];
    thumbName = [NSString stringWithFormat:@"%@-thumb.jpg", thumbName];
    UIImage *image = [UIImage imageNamed:thumbName];
    image = [image thumbnailImage:kThumbnailSize 
                transparentBorder:1 
                     cornerRadius:kRoundedEdge 
             interpolationQuality:kCGInterpolationHigh];
    
    //
    //  Call the completion on the main thread.
    //
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
      
      completion(image);
      [completion release];
    });
  });
}

////////////////////////////////////////////////////////////////////////////////
//
//  When setting |imageName|, also need to update the image...
//

- (void)setImageName:(NSString *)imageName {
  
  [imageName_ autorelease];
  imageName_ = [imageName copy];
  
  [self getThumbnailForImageNamed:imageName completion:^(UIImage *image) {

    [self.thumbnailImageView removeFromSuperview];
    self.thumbnailImageView = [[[UIImageView alloc] initWithImage:image] autorelease];

    //
    //  Right-align |thumbnailImageView|.
    //
    
    CGFloat rightMargin = 40;
    CGFloat x = self.bounds.size.width - image.size.width - rightMargin;
    CGFloat y = (self.bounds.size.height - image.size.height) / 2;
    [self addSubview:self.thumbnailImageView];
    self.thumbnailImageView.frame = CGRectMake(x, y, image.size.width, image.size.height);

    //
    //  Need to relayout after adding the image, as |imageView| won't be in 
    //  the cell by default.
    //
    
    [self setNeedsLayout];
  }];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Get the title from |textLabel|. 
//

- (NSString *)title {
  
  return self.textLabel.text;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Set the title in |textLabel|.
//

- (void)setTitle:(NSString *)title {
  
  self.textLabel.text = title;
}

////////////////////////////////////////////////////////////////////////////////
//
//  |disclosureIndicator| == YES means that the cell accessory type must be 
//  UITableViewCellAccessoryDisclosureIndicator.
//

- (void)setDisclosureIndicator:(BOOL)disclosureIndicator {
  
  if (disclosureIndicator) {
    
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
  } else {
    
    self.accessoryType = UITableViewCellAccessoryNone;
  }
}

////////////////////////////////////////////////////////////////////////////////

- (BOOL)disclosureIndicator {
  
  return (self.accessoryType == UITableViewCellAccessoryDisclosureIndicator);
}

////////////////////////////////////////////////////////////////////////////////
//
//  |checkmark| == YES means the cell accessory type must be 
//  UITableViewCellAccessoryCheckmark.
//

- (void)setCheckmark:(BOOL)checkmark {
  
  if (checkmark) {
    
    self.accessoryType = UITableViewCellAccessoryCheckmark;
    
  } else {
    
    self.accessoryType = UITableViewCellAccessoryNone;
  }
}

////////////////////////////////////////////////////////////////////////////////

- (BOOL)checkmark {
  
  return (self.accessoryType == UITableViewCellAccessoryCheckmark);
}

@end
