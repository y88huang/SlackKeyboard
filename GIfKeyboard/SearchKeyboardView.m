//
//  SearchKeyboardView.m
//  SlackGifKeyboard
//
//  Created by Ken Huang on 2015-04-29.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import "SearchKeyboardView.h"
#import "Masonry.h"
#import "UIColor+Flat.h"
#import "SettingManager.h"
#import "KeyboardStyle.h"

const static CGFloat kButtonPadding = 5.0f;

@implementation SearchKeyboardView
{
    UILabel *_textField;
    UIView *_firstRow;
    UIView *_secondRow;
    UIView *_thirdRow;
    UIView *_fourthRow;
    NSArray *_containers;
    
    UIButton *_capButton;
    UIButton *_deleteButton;
    UIButton *_spaceButton;
    UIButton *_returnButton;
    UIButton *_nextButton;
    KeyboardStyle *_style;
    NSArray *_alphabeticalKeys;
    BOOL _isUpperCase;
}

- (instancetype)initWithStyle:(KeyboardStyle *)style
{
    _style = style;
    self = [self initWithFrame:CGRectZero];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isUpperCase = YES;
        self.backgroundColor = _style.themeColor;
        _firstRow = [[UIView alloc] init];
        _secondRow = [[UIView alloc] init];
        _thirdRow = [[UIView alloc] init];
        _fourthRow = [[UIView alloc] init];
        _containers = @[_firstRow, _secondRow, _thirdRow, _fourthRow];
        _textField = [[UILabel alloc] initWithFrame:CGRectZero];
        _textField.backgroundColor = [UIColor whiteColor];
        _textField.textColor = [UIColor darkGrayColor];
        _textField.text = @"";
        [self addSubview:_textField];
        [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.mas_right);
            make.top.equalTo(self.mas_top);
            make.height.equalTo(self.mas_height).dividedBy(_containers.count + 1);
        }];
        
        for (UIView *view in _containers) {
            [self addSubview:view];
        }
        [self setupKeyboardView];
    }
    return self;
}

- (NSArray *)createButtons:(NSArray *)titles
{
    NSMutableArray *buttons = [[NSMutableArray alloc] initWithCapacity:titles.count];
    for (NSString *title in titles)
    {
        UIButton *button = [self createButton:title];
        [buttons addObject:button];
    }
    return buttons;
}

- (UIButton *)createButton:(NSString *)title
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.backgroundColor = [UIColor whiteColor];
    [button setTitleColor:_style.tintColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"Avenir" size:20.0f];
    [button addTarget:self action:@selector(keyPressed:) forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 4.0f;
    return button;
}

- (void)addKeyConstrainsToButtons:(NSArray *)buttons onView:(UIView *)view
{
    [buttons enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL *stop) {
        [obj mas_makeConstraints:^(MASConstraintMaker *make) {
            if (idx == 0)
            {
                if (view == _firstRow)
                {
                    make.left.equalTo(view.mas_left).with.offset(10.0f);
                }
                else if (view == _secondRow)
                {
                    make.left.equalTo(view.mas_left).with.offset(15.0f);
                }
                else if (view == _thirdRow)
                {
                    make.left.equalTo(view.mas_left).with.offset(15.0f);
                }
                else if (view == _fourthRow)
                {
                    make.left.equalTo(view.mas_left).with.offset(15.0f);
                }
            }
            else
            {
                UIButton *leftButton = buttons[idx - 1];
                make.left.equalTo(leftButton.mas_right).with.offset(kButtonPadding);
            }
            make.bottom.equalTo(view.mas_bottom).with.offset(-kButtonPadding);
            make.width.equalTo(view.mas_width).dividedBy(buttons.count + 2);
            make.top.equalTo(view.mas_top).with.offset(kButtonPadding);
        }];
    }];
}

- (void)setupKeyboardView
{
    NSArray *firstRow = [self createButtons:@[@"Q", @"W", @"E", @"R",@"T", @"Y", @"U",@"I",@"O", @"P"]];
    NSArray *secondRow = [self createButtons:@[@"A", @"S", @"D", @"F", @"G", @"H", @"J", @"K", @"L"]];
    NSArray *thirdRow = [self createButtons:@[@"CAP", @"Z", @"X", @"C", @"V", @"B", @"N", @"M", @"<-"]];
    NSArray *fourthRow = [self createButtons:@[@"", @"SPACE", @"RTN"]];
    
    _alphabeticalKeys = [NSArray arrayWithArray:firstRow];
    _alphabeticalKeys = [_alphabeticalKeys arrayByAddingObjectsFromArray:secondRow];
    _alphabeticalKeys = [_alphabeticalKeys arrayByAddingObjectsFromArray:thirdRow];
    
    _deleteButton = [thirdRow lastObject];
    _spaceButton = fourthRow[1];
    _returnButton = [fourthRow lastObject];
    _nextButton = [fourthRow firstObject];
    _capButton = [thirdRow firstObject];
    
    [_capButton setImage:[UIImage imageNamed:@"uppercase"] forState:UIControlStateNormal];
    [_capButton setTintColor:[UIColor airbnbPink]];
    _capButton.imageEdgeInsets = UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f);
    
    [_deleteButton setImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
    [_deleteButton setTintColor:[UIColor airbnbPink]];
    _deleteButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 5.0f, 10.0f, 5.0f);
    
    [_nextButton setImage:[UIImage imageNamed:@"Cancel"] forState:UIControlStateNormal];
    [_nextButton setTintColor:[UIColor airbnbPink]];
    _nextButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 20.0f, 10.0f, 20.0f);
    NSArray *buttons = @[firstRow, secondRow, thirdRow, fourthRow];
    
    [_containers enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(self.mas_height).dividedBy(_containers.count + 1);
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.mas_right);
            if (idx == 0)
            {
                make.top.equalTo(_textField.mas_bottom);
            }
            else
            {
                UIView *last = _containers[idx - 1];
                make.top.equalTo(last.mas_bottom);
            }
        }];
        
        NSArray *row = buttons[idx];
        for (UIButton *button in row)
        {
            [view addSubview:button];
        }
        if (_fourthRow == view)
        {
            [_nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_fourthRow.mas_left).with.offset(15.0f);
                make.top.equalTo(_fourthRow.mas_top).with.offset(kButtonPadding);
                make.bottom.equalTo(_fourthRow.mas_bottom).with.offset(-kButtonPadding);
                make.width.equalTo(_fourthRow.mas_width).dividedBy(6.0f);
            }];
            
            [_returnButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(_fourthRow.mas_right).with.offset(-15.0f);
                make.top.equalTo(_fourthRow.mas_top).with.offset(kButtonPadding);
                make.bottom.equalTo(_fourthRow.mas_bottom).with.offset(-kButtonPadding);
                make.width.equalTo(_fourthRow.mas_width).dividedBy(6.0f);
            }];
            
            [_spaceButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_nextButton.mas_right).with.offset(kButtonPadding);
                make.right.equalTo(_returnButton.mas_left).with.offset(-kButtonPadding);
                make.top.equalTo(_fourthRow.mas_top).with.offset(kButtonPadding);
                make.bottom.equalTo(_fourthRow.mas_bottom).with.offset(-kButtonPadding);
            }];
        }
        else
        {
            [self addKeyConstrainsToButtons:row onView:view];
        }
    }];
}

- (void)keyPressed:(UIButton *)sender
{
    NSString *title = [sender titleForState:UIControlStateNormal];
    
    if (sender == _returnButton)
    {
        [_textField resignFirstResponder];
        [self.delegate keyboard:self didFinishSearchingWithKeyword:_textField.text];
    }
    else if (sender == _deleteButton)
    {
        if ([_textField.text length] > 0)
        {
            _textField.text = [_textField.text substringToIndex:[_textField.text length] - 1];
        }
    }
    else if (sender == _capButton)
    {
        _isUpperCase = !_isUpperCase;
        for (UIButton *button in _alphabeticalKeys) {
            NSString *title = button.titleLabel.text;
            NSString *modifiedTitle = _isUpperCase ? [title uppercaseString] : [title lowercaseString];
            [button setTitle:modifiedTitle forState:UIControlStateNormal];
        }
    }
    else if (sender == _spaceButton)
    {
        _textField.text = [_textField.text stringByAppendingString:@" "];
    }
    else if (sender == _nextButton)
    {
        [_textField resignFirstResponder];
        [self.delegate keyboard:self didFinishSearchingWithKeyword:@""];
    }
    else
    {
        _textField.text = [_textField.text stringByAppendingString:title];
    }
}

@end
