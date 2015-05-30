//
//  TrendingImageManager.h
//  SlackGifKeyboard
//
//  Created by Ken Huang on 2015-05-29.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrendingImageManager : NSObject

+ (instancetype)sharedInstance;

- (NSArray *)getRecentImages;
- (void)addCountForGifURL:(NSString *)url;
@end
