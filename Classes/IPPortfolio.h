//
//  IPPortfolio.h
//  ipad-portfolio
//
//  The portfolio is the complete collection of photo galleries that you want
//  to show off.
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
#import "IPSet.h"
#import "IPUserDefaults.h"

//
//  A portfolio is a collection of photosets. It's the reason
//  this application exists -- the root of the whole hierarchy.
//

#define kIPPortfolioTitle           @"title"
#define kIPPortfolioSets            @"sets"
#define kIPPortfolioBackgroundImageName @"backgroundImageName"
#define kIPPortfolioNavigationColor @"navigationColor"
#define kIPPortfolioFontColor       @"fontColor"
#define kIPPortfolioTitleFont       @"titleFont"
#define kIPPortfolioTextFont        @"textFont"
#define kIPPortfolioVersion         @"version"
#define kIPPortfolioImageOptimizationVersion @"imageOptimizationVersion"
#define kIPPortfolioLayoutStyle     @"layoutStyle"

//
//  The different kinds of portfolio layouts we support.
//

typedef enum {
  IPPortfolioLayoutStyleTiles,
  IPPortfolioLayoutStyleStacks
} IPPortfolioLayoutStyle;

#define kIPPortfolioTitleFontSize   (20.0)

//
//  Post this notification when the model changes.
//

#define IPPortfolioChanged          @"IPPortfolioChanged"

@interface IPPortfolio : NSObject <NSCopying, NSCoding> {
@private
  NSString *title_;
  NSMutableArray *sets_;
  NSString *backgroundImageName_;
  UIColor *fontColor_;
  NSInteger version_;
}

//
//  The portfolio title.
//

@property (nonatomic, copy) NSString *title;

//
//  All of the sets ("galleries") in the portfolio.
//

@property (nonatomic, strong) NSMutableArray *sets;

//
//  The background image.
//

@property (nonatomic, copy) NSString *backgroundImageName;

//
//  The color for the navigation bar.
//

@property (nonatomic, strong) UIColor *navigationColor;

//
//  Sets a nav bar color if and only if one has not already been set.
//  Returns YES if changed.
//

- (BOOL)setDefaultNavigationColor:(UIColor *)navigationColor;

//
//  The color for the set title & captions.
//

@property (nonatomic, strong) UIColor *fontColor;

//
//  The font for displaying titles.
//

@property (nonatomic, strong) UIFont *titleFont;
- (BOOL)setDefaultTitleFont:(UIFont *)titleFont;

//
//  The font for displaying all other text.
//

@property (nonatomic, strong) UIFont *textFont;
- (BOOL)setDefaultTextFont:(UIFont *)textFont;

//
//  The portfolio layout style.
//

@property (nonatomic, assign) IPPortfolioLayoutStyle layoutStyle;

//
//  The version number of this portfolio. Gets incremented on each save.
//

@property (nonatomic, readonly) NSInteger version;

//
//  The version number of the optimization algorithm applied to each photo.
//

@property (nonatomic, assign) NSUInteger imageOptimizationVersion;

//
//  Where portfolios are saved by default.
//

+(NSString *)defaultPortfolioPath;

//
//  Loads a portfolio.
//

+(IPPortfolio *)loadPortfolioFromPath:(NSString *)portfolioPath;

//
//  Convenience constructor.
//

+ (IPPortfolio *)portfolioWithSets:(IPSet *)firstSet, ...;

//
//  Saves the portfolio.
//

-(void)savePortfolioToPath:(NSString *)portfolioPath;

//
//  Looks for new pictures in the data directory and adds them to a new set
//  if they are found.
//

- (IPSet *)setWithFoundPictures;

//
//  Looks for new pictures asynchronously, then calls the completion block
//  on the main thread with the resulting set.
//

- (void)lookForFoundPicturesAsyncWithCompletion:(void(^)(IPSet *foundSet))completion;

//
//  Key-value compliance for the |sets| collection:
//

-(NSUInteger)countOfSets;
-(IPSet *)objectInSetsAtIndex:(NSUInteger)index;
-(void)insertObject:(IPSet *)set inSetsAtIndex:(NSUInteger)index;
-(void)removeObjectFromSetsAtIndex:(NSUInteger)index;
-(void)appendSet:(IPSet *)set;

@end
