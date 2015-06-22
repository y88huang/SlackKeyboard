//
//  ShareView.m
//  SlackGifKeyboard
//
//  Created by Ken Huang on 2015-05-24.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import "ShareView.h"

@interface ShareView ()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIVisualEffectView *effectView;
@end

@implementation ShareView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.label = [[UILabel alloc] initWithFrame:frame];
        self.label.text = @"Now you can paste the gif through the clipboard";
        self.label.textColor = [UIColor whiteColor];
        self.label.font = [UIFont fontWithName:@"Avenir-Black" size:30.0f];
        self.label.numberOfLines = 0;
        self.label.lineBreakMode = NSLineBreakByWordWrapping;
        self.label.textAlignment = NSTextAlignmentCenter;
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        self.effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        [self.effectView addSubview:self.label];
        [self addSubview:self.effectView];
    }
    return self;
}

- (void)setText:(NSString *)text
{
    _text = text;
    self.label.text = _text;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.effectView.frame = self.bounds;
    self.label.frame = self.effectView.bounds;
}

- (void)showWithText:(NSString *)text
{
    self.text = text;
    self.hidden = NO;
}

- (void)showWithText:(NSString *)text seconds:(NSInteger)seconds
{
    self.text = text;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.hidden = YES;
    });
}

@end
