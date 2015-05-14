//
//  KeyboardSettingManager.h
//  SlackGifKeyboard
//
//  Created by Ken Huang on 2015-05-12.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KeyboardStyle;
@interface KeyboardSettingManager : NSObject

+ (instancetype)sharedInstance;
- (NSArray *)getDefaultStyleOptions;
- (void)saveSytleSetting:(KeyboardStyle *)style;

@end
