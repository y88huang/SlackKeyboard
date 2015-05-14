//
//  GifManager.h
//  SlackGifKeyboard
//
//  Created by Ken Huang on 2015-04-27.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@interface GifManager : AFHTTPRequestOperationManager

+ (instancetype)sharedManager;

//- (void)getTrendingGifonSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))sucess
//                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)getTrendingGifonSuccess:(void (^)(NSArray *gifs, id responseObject))sucess
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)getGifWithKeyword:(NSString *)keyword onSuccess:(void (^)(NSArray *gifs, id responseObject))sucess
                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
@end
