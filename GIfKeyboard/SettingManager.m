//
//  SettingManager.m
//  SlackGifKeyboard
//
//  Created by Ken Huang on 2015-05-13.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import "SettingManager.h"
#import "KeyboardStyle.h"
#import "Constant.h"
#import "UIColor+Flat.h"

@interface SettingManager()

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) KeyboardStyle *style;

@end

@implementation SettingManager

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self fetchAllSettings];
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t token;
    static SettingManager *manager = nil;
    dispatch_once(&token, ^{
        manager = [[SettingManager alloc] init];
    });
    return manager;
}

- (void)updateSetting
{
    [self fetchAllSettings];
}

- (void)fetchAllSettings
{
    self.url = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:kGroupIdentifier];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfURL: [self.url URLByAppendingPathComponent:kSettingFileName]];
    NSData *data = dict[@"ThemeSetting"];
    KeyboardStyle *style = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    self.style = style ? style : [[KeyboardStyle alloc] initWithName:@"Pink" previewImageName:nil themeColor:[UIColor pomegranate] tintColor:[UIColor alizarin]];
}

- (KeyboardStyle *)keyboardSetting
{
    return self.style;
}

@end
