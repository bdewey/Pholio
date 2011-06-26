//
//  IPPasteboardObject.h
//
//  This class puts part of the data model onto the pasteboard, and stores
//  images files referred to by the model into |imageDataDictionary|. This
//  lets me delete the corresponding object out of the model AND ITS FILES,
//  and the page/photo/set can still get recreated.
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

#import <Foundation/Foundation.h>

#define kIPPasteboardObjectUTI      @"org.brians-brain.pholio.IPPasteboardObject"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@protocol IPPasteboardObjectDelegate;
@interface IPPasteboardObject : NSObject<NSCoding> {
    
}

//
//  The piece of the model that we are archiving.
//

@property (nonatomic, retain) id<IPPasteboardObjectDelegate> modelObject;

//
//  A dictionary mapping file names to |NSData| objects containing the file
//  data.
//

@property (nonatomic, retain) NSMutableDictionary *imageDataDictionary;

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
//  Receives callbacks during archiving/unarchiving.
//

@protocol IPPasteboardObjectDelegate <NSObject>

//
//  The |modelObject| is about to go into an archive. This is the time to
//  pull out all of the image files and put them into |imageDataDictionary|.
//

- (void)pasteboardObjectWillArchive:(IPPasteboardObject *)pasteboardObject;

//
//  The |modelObject| just came out of an archive. Look for the corresponding
//  image data in |imageDataDictionary| and reconstitute the files.
//

- (void)pasteboardObjectDidUnarchive:(IPPasteboardObject *)pasteboardObject;

@end
