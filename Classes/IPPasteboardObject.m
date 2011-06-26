//
//  IPPasteboardObject.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 5/4/11.
//  Copyright 2011 Brian's Brain. All rights reserved.
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

#import "IPPasteboardObject.h"

#define kIPPasteboardObjectDelegate     @"IPPasteboardObjectDelegate"
#define kIPPasteboardObjectDictionary   @"IPPasteboardObjectDictionary"

@implementation IPPasteboardObject

@synthesize modelObject = modelObject_;
@synthesize imageDataDictionary = imageDataDictionary_;

////////////////////////////////////////////////////////////////////////////////
//
//  Init -- make sure we have |imageDataDictionary|.
//

- (id)init {
  
  self = [super init];
  if (self != nil) {
    
    imageDataDictionary_ = [[NSMutableDictionary alloc] init];
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release all retained properties.
//

- (void)dealloc {
  
  [modelObject_ release];
  [imageDataDictionary_ release];
  [super dealloc];
}

#pragma mark - NSCoding

////////////////////////////////////////////////////////////////////////////////
//
//  Unpack the object from an archive. Let |modelObject| know when this is done.
//

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super init];
  if (self != nil) {
    self.modelObject = [aDecoder decodeObjectForKey:kIPPasteboardObjectDelegate];
    self.imageDataDictionary = [aDecoder decodeObjectForKey:kIPPasteboardObjectDictionary];
  }
  [self.modelObject pasteboardObjectDidUnarchive:self];
  return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Pack the object into an archive. Let |modelObject| know beforehand.
//

- (void)encodeWithCoder:(NSCoder *)aCoder {

  [self.modelObject pasteboardObjectWillArchive:self];
  [aCoder encodeObject:self.modelObject forKey:kIPPasteboardObjectDelegate];
  [aCoder encodeObject:self.imageDataDictionary forKey:kIPPasteboardObjectDictionary];
}

@end
