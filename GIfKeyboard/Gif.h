//
//  Gif.h
//  SlackGifKeyboard
//
//  Created by Ken Huang on 2015-04-27.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Gif : NSObject

@property (nonatomic, copy) NSURL *gifURL;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSURL *smallGifURL;

@end
