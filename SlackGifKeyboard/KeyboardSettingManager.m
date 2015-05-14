//
//  KeyboardSettingManager.m
//  SlackGifKeyboard
//
//  Created by Ken Huang on 2015-05-12.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import "KeyboardSettingManager.h"
#import "KeyboardStyle.h"
#import "UIColor+Flat.h"
#import "Constant.h"

@interface KeyboardSettingManager()

@property (nonatomic, strong) NSArray *styles;
@property (nonatomic, strong) NSURL *url;
@end
@implementation KeyboardSettingManager

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        KeyboardStyle *stylePink = [[KeyboardStyle alloc] initWithName:@"Pink" previewImageName:nil themeColor:[UIColor pomegranate] tintColor:[UIColor alizarin]];
        KeyboardStyle *styleYellow = [[KeyboardStyle alloc] initWithName:@"Yellow" previewImageName:nil themeColor:[UIColor pumpkin] tintColor:[UIColor carrot]];
        KeyboardStyle *stylePurple = [[KeyboardStyle alloc] initWithName:@"Purple" previewImageName:nil themeColor:[UIColor wisteria] tintColor:[UIColor amethyst]];
        self.styles = @[stylePink, styleYellow, stylePurple];
        
        self.url = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:kGroupIdentifier];
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static KeyboardSettingManager *manager = nil;
    dispatch_once(&once, ^{
        manager = [[KeyboardSettingManager alloc] init];
    });
    return manager;
}

- (NSArray *)getDefaultStyleOptions
{
    return self.styles;
}

- (void)saveSytleSetting:(KeyboardStyle *)style
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:style];
    [self saveObject:data withKey:@"ThemeSetting"];
}

- (void)saveObject:(id)aObject withKey:(NSString *)aKey
{
    NSDictionary *dict = @{aKey: aObject};
    NSURL *fileURL = [self.url URLByAppendingPathComponent:kSettingFileName];
    [dict writeToURL:fileURL atomically:YES];
}

@end
