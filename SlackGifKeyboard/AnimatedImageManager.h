//
//  AnimatedImageManager.h
//  SlackGifKeyboard
//
//  Created by Ken Huang on 2015-06-02.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnimatedImageManager : NSObject

+ (instancetype)sharedInstance;
- (NSString *)exportImages:(NSArray *)images;
- (NSArray *)getLocalImages;
- (NSArray *)getGifs;

@end
