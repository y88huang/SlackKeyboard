//
//  SearchKeyboardView.h
//  SlackGifKeyboard
//
//  Created by Ken Huang on 2015-04-29.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SearchKeyboardView;
@class KeyboardStyle;

@protocol SearchKeybardViewProtocol <NSObject>

- (void)keyboard:(SearchKeyboardView *)keyboard didFinishSearchingWithKeyword:(NSString *)keyword;
- (void)keyboard:(SearchKeyboardView *)keyboard didInsertCharWithKeyboard:(NSString *)charString;
- (void)didDeleteCharWithKeyboard:(SearchKeyboardView *)keyboard;

@end

@interface SearchKeyboardView : UIView

@property (nonatomic, weak) id<SearchKeybardViewProtocol> delegate;

- (instancetype)initWithStyle:(KeyboardStyle *)style;

@end
