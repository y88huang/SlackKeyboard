//
//  GifManager.m
//  SlackGifKeyboard
//
//  Created by Ken Huang on 2015-04-27.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import "GifManager.h"
#import "Gif.h"
#import "PersistentStoreManager.h"
#import "CoreDataStack.h"
#import "NSDate+util.h"
#import "Feed.h"

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
    NSString *url = @"http://api.giphy.com/v1/gifs/trending?api_key=dc6zaTOxFJmzC";

    Feed *feed = [Feed findOrCreateFeedWithUrl:url inContext:[[[PersistentStoreManager sharedInstance] stack] backgroundManagedObjectContext]];
    if (feed.gifs.count)
    {
        sucess([feed.gifs allObjects], nil);
        return;
    }
    
    [self GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        __block NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:10];
        __block NSArray *data = responseObject[@"data"];
        NSDate *date = [NSDate date];
        for (NSDictionary *dict in data)
        {
            Gif *gif = [Gif insertNewObjectIntoContext: [[PersistentStoreManager sharedInstance] stack].backgroundManagedObjectContext];
            NSDictionary *images = dict[@"images"];
            NSString *url = images[@"downsized"][@"url"];
            NSString *downSized = images[@"fixed_height_downsampled"][@"url"];
            gif.gifURL = [NSURL URLWithString: url];
            gif.smallGifURL = [NSURL URLWithString: downSized];
            gif.date = date;
            [array addObject:gif];
        }
        __block NSError *error = nil;
        [[PersistentStoreManager sharedInstance] performBlockInBackground:^(NSManagedObjectContext *context) {
            feed.gifs = [NSSet setWithArray:array];
            [context save: &error];
        }];
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
            gif.gifURL = [NSURL URLWithString: url];
            gif.smallGifURL = [NSURL URLWithString: downSized];
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
