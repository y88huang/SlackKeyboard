//
//  KeyboardStyle.h
//  SlackGifKeyboard
//
//  Created by Ken Huang on 2015-05-12.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface KeyboardStyle : NSObject<NSCoding>

@property (nonatomic, copy) NSString *styleName;
@property (nonatomic, copy) NSString *previewImageName;
@property (nonatomic, strong) UIColor *themeColor;
@property (nonatomic, strong) UIColor *tintColor;

- (instancetype)initWithName:(NSString *)styleName
            previewImageName:(NSString *)imageName
                  themeColor:(UIColor *)themeColor
                   tintColor:(UIColor *)tintColor;

@end
