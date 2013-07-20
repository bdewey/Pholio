//
//  IPPhotoScrollViewCell.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 7/20/13.
//  Copyright (c) 2013 Brian's Brain. All rights reserved.
//

#import "IPPhotoScrollViewCell.h"
#import "IPPhotoScrollView.h"

@implementation IPPhotoScrollViewCell

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    _photoScrollView = [[IPPhotoScrollView alloc] initWithFrame:self.bounds];
    _photoScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:_photoScrollView];
  }
  return self;
}

@end
