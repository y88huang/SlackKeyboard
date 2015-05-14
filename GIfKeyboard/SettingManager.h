//
//  SettingManager.h
//  SlackGifKeyboard
//
//  Created by Ken Huang on 2015-05-13.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KeyboardStyle;
@interface SettingManager : NSObject

+ (instancetype)sharedInstance;

- (KeyboardStyle *)keyboardSetting;

- (void)updateSetting;

@end
