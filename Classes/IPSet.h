//
//  IPSet.h
//  ipad-portfolio
//
//  The "set" (or "gallery") is a collection of photo pages.
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
#import "IPPhoto.h"
#import "IPPage.h"
#import "IPPasteboardObject.h"

//
//  A set is a collection of pages.
//

#define kIPSetTitle                 @"title"
#define kIPSetPages                 @"pages"
#define kIPSetThumbnailFilename     @"thumbnailFilename"
#define kIPSetUTI                   @"org.brians-brain.pholio.set"

@class IPPortfolio;
@interface IPSet : NSObject <NSCoding, NSCopying, IPPasteboardObjectDelegate> {
    @private
    NSString *title_;
    NSMutableArray *pages_;
    IPPortfolio *parent_;
}

//
//  The title of the set.
//

@property (nonatomic, copy) NSString *title;

//
//  The filename of the image that is the thumbnail for this set.
//

@property (nonatomic, readonly) NSString *thumbnailFilename;

//
//  The actual thumbnail image for this set.
//

@property (nonatomic, readonly) UIImage *thumbnail;

//
//  The pages that comprise the set.
//

@property (nonatomic, retain) NSMutableArray *pages;

//
//  And the parent portfolio.
//

@property (nonatomic, assign) IPPortfolio *parent;

//
//  Convenience constructor.
//

+ (IPSet *)setWithPages:(IPPage *)firstPage, ...;

//
//  Key-value compliance for the |pages| collection.
//

-(NSUInteger)countOfPages;
-(IPPage *)objectInPagesAtIndex:(NSUInteger)index;
-(void)insertObject:(IPPage *)page inPagesAtIndex:(NSUInteger) index;
-(void)removeObjectFromPagesAtIndex:(NSUInteger)index;
-(void)appendPage:(IPPage *)page;

//
//  Deletes all of the image files contained in the set hierarchy.
//  Used for cleaning up.
//

-(void)deletePhotoFiles;

//
//  Notify the set that one of the images in it has changed. This may trigger
//  the thumbnail for the set to be changed. This is intended to be called
//  from the IPPhoto object itself, reaching up through the object hierarchy
//  on a change.
//

- (void)photoInSetHasChanged:(IPPhoto *)photo;

@end
