//
//  ViewController.m
//  SlackGifKeyboard
//
//  Created by Ken Huang on 2015-04-27.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import "SettingViewController.h"
#import "Masonry.h"
#import "UIColor+Flat.h"
#import "KeyboardSettingViewController.h"

typedef NS_ENUM(NSInteger, SlackKeyboardConfig)
{
    SlackKeyboardSetting,
    SlackKeyboardTrending,
    SlackKeyboardDIY
};

@interface SettingViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *flatColors;
@property (nonatomic, strong) NSArray *titles;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableView];
    self.flatColors = @[[UIColor carrot], [UIColor alizarin], [UIColor nephritis]];
    self.titles = @[@"Setting", @"Trending", @"DIY"];
}

- (void)setupTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.tableView];
//    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.view.mas_left);
//        make.right.equalTo(self.view.mas_right);
//        make.top.equalTo(self.view.mas_top);
//        make.bottom.equalTo(self.view.mas_bottom);
//    }];
    self.tableView.frame = self.view.bounds;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titles.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ceil(CGRectGetHeight(tableView.bounds) / 3.0f);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = [UIFont fontWithName:@"Avenir-Black" size:40.0f];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = self.titles[indexPath.row];
    cell.backgroundColor = self.flatColors[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case SlackKeyboardSetting:
        {
            KeyboardSettingViewController *settingController = [[KeyboardSettingViewController alloc] init];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:settingController animated:YES completion:nil];
            });
        }
            break;
        case SlackKeyboardTrending:
        {
            
        }
            break;
        case SlackKeyboardDIY:
        {
            
        }
            break;
    }
}

@end
