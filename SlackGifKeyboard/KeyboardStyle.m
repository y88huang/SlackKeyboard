//
//  KeyboardStyle.m
//  SlackGifKeyboard
//
//  Created by Ken Huang on 2015-05-12.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import "KeyboardStyle.h"

static NSString *const kStyleNameKey = @"kStyleName";
static NSString *const kStyleImageKey = @"kStyleImageKey";
static NSString *const kStyleTintColorKey = @"kStyleTintColorKey";
static NSString *const kStyleThemeColorKey = @"kStyleThemeColorKey";

@implementation KeyboardStyle

- (instancetype)initWithName:(NSString *)styleName
            previewImageName:(NSString *)imageName
                  themeColor:(UIColor *)themeColor
                   tintColor:(UIColor *)tintColor
{
    self = [super init];
    if (self)
    {
        self.themeColor = themeColor;
        self.tintColor = tintColor;
        self.styleName = styleName;
        self.previewImageName = @"image";
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject: _styleName forKey:kStyleNameKey];
    [aCoder encodeObject: _previewImageName forKey:kStyleImageKey];
    [aCoder encodeObject: _tintColor forKey:kStyleTintColorKey];
    [aCoder encodeObject: _themeColor forKey:kStyleThemeColorKey];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        _styleName = [aDecoder decodeObjectForKey:kStyleNameKey];
        _previewImageName = [aDecoder decodeObjectForKey:kStyleImageKey];
        _tintColor = [aDecoder decodeObjectForKey:kStyleTintColorKey];
        _themeColor = [aDecoder decodeObjectForKey:kStyleThemeColorKey];
    }
    return self;
}

@end
