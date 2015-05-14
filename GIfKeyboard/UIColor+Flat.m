//
//  UIColor+Flat.m
//  KHDynamicProgressHUD
//
//  Created by Ken Huang on 2014-11-14.
//  Copyright (c) 2014 Ken Huang. All rights reserved.
//

#import "UIColor+Flat.h"

#define Color(R,G,B) [UIColor colorWithRed: R/255.0f green:G/255.0f blue:B/255.0f alpha:1.0f]

#define UIColorFromRGB(rgbValue) \
        [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                        green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
                        blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
                        alpha:1.0]

#define FLAT_COLORS @[UIColorFromRGB(0x1abc9c), \
                    UIColorFromRGB(0x1abc9c), \
                    UIColorFromRGB(0x3498db), \
                    UIColorFromRGB(0x9b59b6), \
                    UIColorFromRGB(0x34495e), \
                    UIColorFromRGB(0x16a085), \
                    UIColorFromRGB(0x27ae60), \
                    UIColorFromRGB(0x2980b9), \
                    UIColorFromRGB(0xf1c40f), \
                    UIColorFromRGB(0xe67e22), \
                    UIColorFromRGB(0xe74c3c), \
                    UIColorFromRGB(0xf39c12), \
                    UIColorFromRGB(0xd35400), \
                    UIColorFromRGB(0xc0392b)]

#define ARR_SIZE(arr) ( sizeof((arr)) / sizeof((arr[0])) )
static unsigned int colors[] = {0x1abc9c, 0x3498db, 0x9b59b6, 0x34495e, 0x16a085, 0x27ae60,
                           0x2980b9, 0xf1c40f, 0xe67e22, 0xe74c3c, 0xf39c12, 0xd35400,
                            0xc0392b};

@implementation UIColor (Flat)

+ (UIColor *)lightGrey
{
    return Color(246.0f, 247.0f, 246.0f);
}

+ (UIColor *)airbnbPink
{
    return Color(255.0f, 90.0f, 95.0f);
}

+ (UIColor *)turquoise
{
    return UIColorFromRGB(0x1abc9c);
}

+ (UIColor *)emerald
{
    return UIColorFromRGB(0x1abc9c);
}

+ (UIColor *)peterRiver
{
    return UIColorFromRGB(0x3498db);
}

+ (UIColor *)amethyst
{
    return UIColorFromRGB(0x9b59b6);
}

+ (UIColor *)wetAsphalt
{
    return UIColorFromRGB(0x34495e);
}

+ (UIColor *)greenSee
{
    return UIColorFromRGB(0x16a085);
}

+ (UIColor *)nephritis
{
    return UIColorFromRGB(0x27ae60);
}

+ (UIColor *)belizeHole
{
    return UIColorFromRGB(0x2980b9);
}

+ (UIColor *)sunFlower
{
    return UIColorFromRGB(0xf1c40f);
}

+ (UIColor *)carrot
{
    return UIColorFromRGB(0xe67e22);
}

+ (UIColor *)alizarin
{
    return UIColorFromRGB(0xe74c3c);
}

+ (UIColor *)flatOrange
{
    return UIColorFromRGB(0xf39c12);
}

+ (UIColor *)pumpkin
{
    return UIColorFromRGB(0xd35400);
}

+ (UIColor *)pomegranate
{
    return UIColorFromRGB(0xc0392b);
}

+ (UIColor *)randomFlatColor
{
    NSUInteger random = arc4random_uniform(ARR_SIZE(colors));
    return UIColorFromRGB(colors[random]);
}

@end