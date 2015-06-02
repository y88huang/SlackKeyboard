//
//  AnimatedImageManager.m
//  SlackGifKeyboard
//
//  Created by Ken Huang on 2015-06-02.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import "AnimatedImageManager.h"
#import "Constant.h"

@interface AnimatedImageManager()

@property (nonatomic, strong) NSURL *url;

@end

@implementation AnimatedImageManager

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.url = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:kGroupIdentifier];
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static AnimatedImageManager *manager = nil;
    dispatch_once(&once, ^{
        manager = [[AnimatedImageManager alloc] init];
    });
    return manager;
}

@end
