//
//  ShareView.h
//  SlackGifKeyboard
//
//  Created by Ken Huang on 2015-05-24.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareView : UIView

@property (nonatomic, copy) NSString *text;

- (void)showWithText:(NSString *)text;
- (void)showWithText:(NSString *)text seconds:(NSInteger)seconds;

@end
