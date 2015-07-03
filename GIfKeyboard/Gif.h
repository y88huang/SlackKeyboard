//
//  Gif.h
//  SlackGifKeyboard
//
//  Created by Ken Huang on 2015-04-27.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelObject.h"

@interface Gif : ModelObject

@property (nonatomic, copy) NSURL *gifURL;
@property (nonatomic, copy) NSURL *smallGifURL;
@property (nonatomic, strong) NSDate *date;

@end
