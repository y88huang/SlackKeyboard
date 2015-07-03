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
#import "FlatUIKit.h"
#import "AFNetworkReachabilityManager.h"

const static CGFloat kButtonPadding = 5.0f;

@implementation SearchKeyboardView
{
    UILabel *_textField;
    UIView *_firstRow;
    UIView *_secondRow;
    UIView *_thirdRow;
    UIView *_fourthRow;
    NSArray *_containers;
    
    FUIButton *_capButton;
    FUIButton *_deleteButton;
    FUIButton *_spaceButton;
    FUIButton *_returnButton;
    FUIButton *_nextButton;
    KeyboardStyle *_style;
    NSArray *_alphabeticalKeys;
    NSArray *_buttons;
    
    BOOL _isUpperCase;
}

- (instancetype)initWithStyle:(KeyboardStyle *)style
{
    _style = style;
    self = [self initWithFrame:CGRectZero];
    return self;
}

- (UIColor *)lighterColorForColor:(UIColor *)color byDegree:(CGFloat)degree
{
    CGFloat r, g, b, a;
    if ([color getRed:&r green:&g blue:&b alpha: &a]){
        return [UIColor colorWithRed:MAX(r - degree , 0.0f)
                               green:MAX(g - degree, 0.0f)
                                blue:MAX(b - degree, 0.0f)
                               alpha:a];
    }
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeReachability:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
        _isUpperCase = YES;
        self.backgroundColor = [self lighterColorForColor:_style.tintColor byDegree:0.4f];
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
        _textField.layer.borderColor = _style.themeColor.CGColor;
        _textField.layer.borderWidth = 3.0f;
        _textField.layer.cornerRadius = 4.0f;
        _textField.textAlignment = NSTextAlignmentCenter;
        
        for (UIView *view in _containers) {
            [self addSubview:view];
        }
        [self setupKeyboardView];
    }
    return self;
}

- (void)didChangeReachability:(NSNotification *)notification
{
    AFNetworkReachabilityStatus status = [notification.userInfo[@"AFNetworkingReachabilityNotificationStatusItem"] integerValue];
    switch (status)
    {
        case AFNetworkReachabilityStatusNotReachable:
            NSLog(@"WTF");
            _textField.text = @"No Internet connection, use as normal keyboard";
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
        case AFNetworkReachabilityStatusReachableViaWiFi:
            _textField.text = @"";
            break;
        default:
            break;
    }
}

- (void)updateConstraints
{
    [super updateConstraints];
    [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.top.equalTo(self.mas_top);
        make.height.equalTo(self.mas_height).dividedBy(_containers.count + 1);
    }];
    
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
        
        NSArray *row = _buttons[idx];
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
    FUIButton *button = [FUIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.buttonColor = _style.tintColor;
    button.titleLabel.font = [UIFont fontWithName:@"Avenir" size:20.0f];
    [button addTarget:self action:@selector(keyPressed:) forControlEvents:UIControlEventTouchUpInside];
//    button.layer.cornerRadius = 4.0f;
    button.cornerRadius = 6.0f;
    button.shadowColor = _style.themeColor;
    button.shadowHeight = 3.0f;
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
    
    _capButton.imageName = @"uppercase";
    _capButton.imageEdgeInsets = UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f);
    
    _deleteButton.imageName = @"Back";
    _deleteButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 5.0f, 10.0f, 5.0f);
    
    _nextButton.imageName = @"Cancel";
    
    _nextButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 20.0f, 10.0f, 20.0f);
    
    _returnButton.backgroundColor = [UIColor clearColor];
    
    _buttons = @[firstRow, secondRow, thirdRow, fourthRow];
}

- (void)keyPressed:(UIButton *)sender
{
    BOOL reachable = [AFNetworkReachabilityManager sharedManager].reachable;
    NSString *title = [sender titleForState:UIControlStateNormal];
    
    if (sender == _returnButton)
    {
        [_textField resignFirstResponder];
        [self.delegate keyboard:self didFinishSearchingWithKeyword:_textField.text];
    }
    else if (sender == _deleteButton)
    {
        if (reachable) {
            if ([_textField.text length] > 0)
            {
                _textField.text = [_textField.text substringToIndex:[_textField.text length] - 1];
            }
        }
        else
        {
            [self.delegate didDeleteCharWithKeyboard:self];
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
        if (reachable)
        {
            _textField.text = [_textField.text stringByAppendingString:@" "];
        }
        else
        {
            [self.delegate keyboard:self didInsertCharWithKeyboard:@" "];
        }
       
    }
    else if (sender == _nextButton)
    {
        [_textField resignFirstResponder];
        [self.delegate keyboard:self didFinishSearchingWithKeyword:@""];
    }
    else
    {
        if (reachable)
        {
            _textField.text = [_textField.text stringByAppendingString:title];
        } else {
            [self.delegate keyboard:self didInsertCharWithKeyboard:title];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
