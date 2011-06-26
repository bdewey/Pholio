//
//  IPPhotoTilingManager.h
//  ipad-portfolio
//
//  Created by Brian Dewey on 6/24/11.
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

//
//  This is a callback that gets called each time a scale level is tiled
//  for a photo.
//

typedef void (^IPPhotoTilingCompletion)(CGFloat scale);

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@class IPPhoto;
@interface IPPhotoTilingManager : NSObject { }

//
//  The shared manager.
//

+ (IPPhotoTilingManager *)sharedManager;

//
//  Tile the photo. Call the completion routine when each scale level of the
//  photo gets completed.
//

- (void)asyncTilePhoto:(IPPhoto *)photo withCompletion:(IPPhotoTilingCompletion)completion;

@end
