//
//  IPPage.h
//  ipad-portfolio
//
//  Created by Brian Dewey on 8/5/10.
//  Copyright 2010 Brian's Brain. All rights reserved.
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
#import "IPPasteboardObject.h"

//
//  Model class: A single page of a photo set. More than one photo
//  may go on a page.
//

#define kIPPageUTI                  @"org.brians-brain.pholio.page"
#define kIPPagePhotos               @"photos"

@class IPSet;
@class IPPhoto;
@interface IPPage : NSObject <NSCoding, NSCopying, IPPasteboardObjectDelegate> {
@private
  NSMutableArray *photos_;
  IPSet *parent_;
}

//
//  These are the photos that go on this page.
//

@property (nonatomic, retain) NSMutableArray *photos;

//
//  Pointer to our parent.
//

@property (nonatomic, assign) IPSet *parent;

//
//  Helper...
//

+ (IPPage *)pageWithPhoto:(IPPhoto *)photo;

//
//  Helper...
//

+ (IPPage *)pageWithImage:(UIImage *)image;

+ (IPPage *)pageWithImage:(UIImage *)image andTitle:(NSString *)title;

+ (IPPage *)pageWithFilename:(NSString *)filename andTitle:(NSString *)title;

//
//  Helper method to get a value from one of the child photos.
//

-(NSString *)valueForKeyPath:(NSString *)keyPath forPhoto:(NSUInteger)index;

//
//  Helper method to set a value for one of the child photos.
//

-(void)setValue:(id)value forKeyPath:(NSString *)keyPath forPhoto:(NSUInteger)index;

//
//  Deletes all of the photo files for all photos contained on this page.
//  Part of cleanup.
//

-(void)deletePhotoFiles;

//
//  How many photos on the page.
//

-(NSUInteger)countOfPhotos;

//
//  Gets a photo by index.
//

-(IPPhoto *)objectInPhotosAtIndex:(NSUInteger)index;

//
//  Inserts a photo into the page.
//

-(void)insertObject:(IPPhoto *)photo inPhotosAtIndex:(NSUInteger) index;

//
//  Removes a photo from the page.
//

-(void)removeObjectFromPhotosAtIndex:(NSUInteger)index;


@end
