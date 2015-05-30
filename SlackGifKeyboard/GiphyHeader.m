//
//  GiphyHeader.m
//  SlackGifKeyboard
//
//  Created by Ken Huang on 2015-05-30.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import "GiphyHeader.h"

@implementation GiphyHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.imageView = [[UIImageView alloc] init];
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
}

@end
