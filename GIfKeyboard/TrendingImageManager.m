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
        
        NSURL *url = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:kGroupIdentifier];
        manager.url = [url URLByAppendingPathComponent:kUserImageTrending];
    });
    return manager;
}

- (void)addCountForGifURL:(NSString *)url
{
    if (!url)
    {
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfURL: self.url];
    
    if (!dict)
    {
        dict = [[NSMutableDictionary alloc] init];
    }
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

- (NSArray *)getRecentImages
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfURL: self.url];
    NSArray *keyList = dict.allKeys;
    return keyList;
}

@end
