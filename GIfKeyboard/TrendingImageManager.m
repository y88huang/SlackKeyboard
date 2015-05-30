//
//  TrendingImageManager.m
//  SlackGifKeyboard
//
//  Created by Ken Huang on 2015-05-29.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import "TrendingImageManager.h"
#import "Constant.h"

@interface TrendingImageManager ()

@property (nonatomic, strong) NSURL *url;
@end

@implementation TrendingImageManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t token;
    static TrendingImageManager *manager = nil;
    dispatch_once(&token, ^{
        manager = [[TrendingImageManager alloc] init];
        manager.url = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:kGroupIdentifier];
    });
    return manager;
}

- (void)addCountForGifURL:(NSString *)url
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfURL: [self.url URLByAppendingPathComponent:kUserImageTrending]];
    NSNumber *count = dict[url];
    if (count)
    {
        NSNumber *incremented = @([count integerValue] + 1);
        dict[url] = incremented;
    }
    else
    {
        dict[url] = @1;
    }
    [dict writeToURL:self.url atomically:YES];
}

@end
