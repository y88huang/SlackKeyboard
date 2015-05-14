//
//  GifManager.m
//  SlackGifKeyboard
//
//  Created by Ken Huang on 2015-04-27.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import "GifManager.h"
#import "Gif.h"
@implementation GifManager

+ (instancetype)sharedManager
{
    static dispatch_once_t token;
    static GifManager *manager = nil;
    dispatch_once(&token, ^{
        manager = [GifManager manager];
    });
    return manager;
}

- (void)getTrendingGifonSuccess:(void (^)(NSArray *gifs, id responseObject))sucess
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [self GET:@"http://api.giphy.com/v1/gifs/trending?api_key=dc6zaTOxFJmzC" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:10];
        NSArray *data = responseObject[@"data"];
        for (NSDictionary *dict in data)
        {
            Gif *gif = [[Gif alloc] init];
            NSDictionary *images = dict[@"images"];
            NSString *url = images[@"downsized"][@"url"];
            NSString *downSized = images[@"fixed_height_downsampled"][@"url"];
            gif.gifURL = url;
            gif.smallGifURL = downSized;
            [array addObject:gif];
        }
        if (sucess)
        {
            sucess(array, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure)
        {
            failure(operation, error);
        }
    }];
}

- (void)getGifWithKeyword:(NSString *)keyword onSuccess:(void (^)(NSArray *gifs, id responseObject))sucess
                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [self GET:@"http://api.giphy.com/v1/gifs/search" parameters:@{@"api_key": @"dc6zaTOxFJmzC",
                                                                                          @"q": keyword
                                                                                          }
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:10];
        NSArray *data = responseObject[@"data"];
        for (NSDictionary *dict in data)
        {
            Gif *gif = [[Gif alloc] init];
            NSDictionary *images = dict[@"images"];
            NSString *url = images[@"downsized"][@"url"];
            NSString *downSized = images[@"fixed_height_downsampled"][@"url"];
            gif.gifURL = url;
            gif.smallGifURL = downSized;
            [array addObject:gif];
        }
        if (sucess)
        {
            sucess(array, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure)
        {
            failure(operation, error);
        }
    }];
}

@end
