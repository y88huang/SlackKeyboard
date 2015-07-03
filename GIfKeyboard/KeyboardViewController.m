//
//  KeyboardViewController.m
//  GIfKeyboard
//
//  Created by Ken Huang on 2015-04-27.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import "KeyboardViewController.h"
#import "ImageCollectionViewCell.h"
#import "GifManager.h"
#import "Gif.h"
#import "Masonry.h"
#import "SearchKeyboardView.h"
#import "UIColor+Flat.h"
#import "SettingManager.h"
#import "KeyboardStyle.h"
#import "ShareView.h"
#import "TrendingImageManager.h"
#import "AnimatedImageManager.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+Gif.h"
#import "AnimatedGIFImageSerialization.h"
#import "PersistentStoreManager.h"
#import "NSDate+util.h"

const static CGFloat kButtonPanelHeight = 35.0f;
const static CGFloat kButtonPadding = 4.0f;
const static CGFloat kButtonWidth = 40.0f;

@interface KeyboardViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, SearchKeybardViewProtocol>
@property (nonatomic, strong) UIButton *nextKeyboardButton;
@property (nonatomic, strong) UIButton *searchGifButton;
@property (nonatomic, strong) UIButton *trendingGifButton;
@property (nonatomic, strong) UIButton *customGifButton;
@property (nonatomic, strong) UIImageView *giphyBanner;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *animatedGIFs;

@property (nonatomic, strong) SearchKeyboardView *kbView;

@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (nonatomic, strong) UIView *bottomPanel;
@property (nonatomic, strong) UILabel *keywordLabel;
@property (nonatomic, strong) KeyboardStyle *style;
@property (nonatomic, strong) ShareView *shareView;
@property (nonatomic, strong) UIImage *placeHolderImage;

@end

@implementation KeyboardViewController
{
    UIView *_firstRow;
    UIView *_secondRow;
    UIView *_thirdRow;
    UIView *_fourthRow;
    CGFloat _expandedHeight;
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    // Add custom view sizing constraints here

    if (CGRectGetHeight(self.view.frame) == 0.0f || CGRectGetWidth(self.view.frame) == 0.0f) {
        return;
    }
    [self.inputView removeConstraint:self.heightConstraint];

    self.heightConstraint = [NSLayoutConstraint constraintWithItem:self.inputView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant: _expandedHeight];
    self.heightConstraint.priority = 990;
    [self.inputView addConstraint: self.heightConstraint];
    
    [self.giphyBanner mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.top.equalTo(self.view.mas_top);
        make.width.equalTo(@(30.0f));
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-kButtonPanelHeight);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.giphyBanner.mas_right);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-kButtonPanelHeight);
    }];
    
    [self.kbView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.top.equalTo(self.view.mas_top);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-kButtonPanelHeight);
    }];
    
    [self.bottomPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
        make.top.equalTo(self.collectionView.mas_bottom);
    }];
    
    [self setupBottomPanelConstrains];
    [self.shareView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.collectionView);
        make.left.equalTo(self.giphyBanner.mas_right);
        make.top.equalTo(self.giphyBanner.mas_top);
    }];
    [self.collectionView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [PersistentStoreManager sharedInstance];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    self.animatedGIFs = [[NSMutableArray alloc] initWithCapacity:10];
    // Perform custom UI setup here
    [[SettingManager sharedInstance] updateSetting];
    self.style = [[SettingManager sharedInstance] keyboardSetting];
    [self setupGiphyBanner];
    [self setupCollectionView];
    [self setupKeyBoardView];
    [self setupBottomPanel];
    _expandedHeight = 216.0;
    self.view.backgroundColor = [UIColor blackColor];
    [self setupShareView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateViewConstraints];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchTrendingGifs];
}

- (void)fetchTrendingGifs
{
    __weak typeof(self) weakSelf = self;
    [[GifManager sharedManager] getTrendingGifonSuccess:^(NSArray *gifs, id responseObject) {
        typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.animatedGIFs removeAllObjects];
        [strongSelf.animatedGIFs addObjectsFromArray:gifs];
        [strongSelf.collectionView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

#pragma mark -
#pragma mark - setup code

- (void)setupShareView
{
    self.shareView = [[ShareView alloc] init];
    self.shareView.hidden = YES;
    [self.collectionView addSubview:self.shareView];
}

- (void)setupKeywordLabel
{
    self.keywordLabel = [[UILabel alloc] init];
    self.keywordLabel.textColor = [UIColor whiteColor];
    self.keywordLabel.font = [UIFont fontWithName:@"Avenir-Black" size:20.0f];
    self.keywordLabel.text = @"#Trending 25";
    [self.bottomPanel addSubview:self.keywordLabel];
}

- (void)setupGiphyBanner
{
    self.giphyBanner = [[UIImageView alloc] init];
    self.giphyBanner.image = [UIImage imageNamed:@"giphy_verticle.gif"];
    [self.view addSubview:self.giphyBanner];
}

- (void)setupBottomPanel
{
    self.bottomPanel = [[UIView alloc] init];
    self.bottomPanel.backgroundColor = self.style.themeColor;
    [self.view addSubview:self.bottomPanel];
    
    [self setupNextKey];
    [self setupSearchKey];
    [self setupTrendingKey];
    [self setupCustomGifButton];
    [self setupKeywordLabel];
}

- (void)setupKeyBoardView
{
    self.kbView = [[SearchKeyboardView alloc] initWithStyle:self.style];
    self.kbView.hidden = YES;
    self.kbView.delegate = self;
    [self.view addSubview:self.kbView];
}

- (void)setupSearchKey
{
    self.searchGifButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.searchGifButton.backgroundColor = [UIColor sunFlower];
    self.searchGifButton.layer.cornerRadius = 4.0f;
    [self.searchGifButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [self.searchGifButton setTintColor:[UIColor whiteColor]];
    self.searchGifButton.imageEdgeInsets = UIEdgeInsetsMake(0.0f, 7.0f , 0.0, 7.0f);
    [self.searchGifButton addTarget:self action:@selector(searchForGif:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomPanel addSubview: self.searchGifButton];
}

- (void)setupNextKey
{
    self.nextKeyboardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.nextKeyboardButton.backgroundColor = [UIColor airbnbPink];
    [self.nextKeyboardButton setImage:[UIImage imageNamed:@"nextKeyboard"] forState:UIControlStateNormal];
    [self.nextKeyboardButton setTintColor:[UIColor whiteColor]];
    self.nextKeyboardButton.imageEdgeInsets = UIEdgeInsetsMake(0.0f, 5.0f , 0.0, 5.0f);
    self.nextKeyboardButton.layer.cornerRadius = 4.0f;
    [self.nextKeyboardButton addTarget:self action:@selector(advanceToNextInputMode) forControlEvents:UIControlEventTouchUpInside];
    
    [self.bottomPanel addSubview:self.nextKeyboardButton];
}

- (void)setupTrendingKey
{
    self.trendingGifButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.trendingGifButton.backgroundColor = [UIColor turquoise];
    [self.trendingGifButton setImage:[UIImage imageNamed:@"Trend"] forState:UIControlStateNormal];
    [self.trendingGifButton setTintColor:[UIColor whiteColor]];
    [self.trendingGifButton addTarget:self action:@selector(showTrendingGifs:) forControlEvents:UIControlEventTouchUpInside];
    self.trendingGifButton.layer.cornerRadius = 4.0f;
    [self.bottomPanel addSubview:self.trendingGifButton];
}

- (void)setupCustomGifButton
{
    self.customGifButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.customGifButton.backgroundColor = [UIColor peterRiver];
    [self.customGifButton setTintColor:[UIColor whiteColor]];
    [self.customGifButton addTarget:self action:@selector(showCustomGifs:) forControlEvents:UIControlEventTouchUpInside];
    self.customGifButton.layer.cornerRadius = 4.0f;
    [self.customGifButton setImage:[UIImage imageNamed:@"DIY_Logo"] forState:UIControlStateNormal];
    [self.customGifButton setContentEdgeInsets:UIEdgeInsetsMake(2.0, 5.0, 2.0, 5.0)];
    [self.bottomPanel addSubview:self.customGifButton];
}

- (void)setupCollectionView
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressOnCollectionView:)];
    longGesture.minimumPressDuration = 2.0f;
    [self.collectionView addGestureRecognizer:longGesture];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = self.style.tintColor;
    [self.collectionView registerClass:[ImageCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.view addSubview:self.collectionView];
}

- (void)setupBottomPanelConstrains
{
    [self.nextKeyboardButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomPanel.mas_top).with.offset(kButtonPadding);
        make.left.equalTo(self.bottomPanel.mas_left).with.offset(kButtonPadding);
        make.bottom.equalTo(self.bottomPanel.mas_bottom).with.offset(-kButtonPadding);
        make.width.equalTo(@(kButtonWidth));
    }];
    
    [self.searchGifButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nextKeyboardButton.mas_right).with.offset(10.0f);
        make.top.equalTo(self.bottomPanel.mas_top).with.offset(kButtonPadding);
        make.bottom.equalTo(self.bottomPanel.mas_bottom).with.offset(-kButtonPadding);
        make.width.equalTo(@(kButtonWidth));
    }];
    
    [self.trendingGifButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomPanel.mas_top).with.offset(kButtonPadding);
        make.left.equalTo(self.searchGifButton.mas_right).with.offset(10.0f);
        make.bottom.equalTo(self.bottomPanel.mas_bottom).with.offset(-kButtonPadding);
        make.width.equalTo(@(kButtonWidth));
    }];
    
    [self.customGifButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomPanel.mas_top).with.offset(kButtonPadding);
        make.left.equalTo(self.trendingGifButton.mas_right).with.offset(10.0f);
        make.bottom.equalTo(self.bottomPanel.mas_bottom).with.offset(-kButtonPadding);
        make.width.equalTo(@(kButtonWidth));
    }];
    
    [self.keywordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomPanel.mas_right);
        make.top.equalTo(self.bottomPanel.mas_top);
        make.bottom.equalTo(self.bottomPanel.mas_bottom);
        make.left.equalTo(self.customGifButton.mas_right).with.offset(10.0);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)textWillChange:(id<UITextInput>)textInput {
    // The app is about to change the document's contents. Perform any preparation here.
}

- (void)textDidChange:(id<UITextInput>)textInput {
    // The app has just changed the document's contents, the document context has been updated.
    
    UIColor *textColor = nil;
    if (self.textDocumentProxy.keyboardAppearance == UIKeyboardAppearanceDark) {

        textColor = [UIColor whiteColor];
    } else {
        textColor = [UIColor blackColor];
    }
    [self.nextKeyboardButton setTitleColor:textColor forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark - UICollectionView Delegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(150.0f, floorf(CGRectGetHeight(collectionView.bounds) / 2.0f));
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    NSInteger index = indexPath.section * 2 + indexPath.row;
    Gif *gif = self.animatedGIFs[index];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    if ([gif.smallGifURL isFileURL])
    {
        NSData *data = [NSData dataWithContentsOfURL:gif.smallGifURL];
        UIImage *image = [UIImage sd_animatedGIFWithData:data];
        UIImage *image2 = [image sd_animatedImageByScalingAndCroppingToSize:CGSizeMake(150.0f, CGRectGetHeight(collectionView.bounds) / 2.0f)];
        cell.imageView.image = image2;
    }else{
        [cell.imageView setImageWithURL:gif.smallGifURL];
    }
    
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Gif *gif = self.animatedGIFs[indexPath.section * 2 + indexPath.row];
    if (![gif.gifURL isFileURL])
    {
        [self.textDocumentProxy insertText:[gif.gifURL absoluteString]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[TrendingImageManager sharedInstance] addCountForGifURL:[gif.gifURL absoluteString]];
        });
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return (section + 1) * 2 <= self.animatedGIFs.count ? 2 : 1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.animatedGIFs.count / 2 + (self.animatedGIFs.count % 2);
}

#pragma mark Helpers
- (void)showKeyboard
{
    _expandedHeight = 280.0f;
    self.kbView.hidden = NO;
    [self.view setNeedsUpdateConstraints];
}

- (void)hideKeyboard
{
    if (self.kbView.hidden)
    {
        return;
    }
    _expandedHeight = 216.0f;
    self.kbView.hidden = YES;
    [self.view setNeedsUpdateConstraints];
}

- (void)advanceToNextInputMode
{
    [super advanceToNextInputMode];
}

#pragma mark -
#pragma mark - button selector
- (void)searchForGif:(UIButton *)sender
{
    [self showKeyboard];
}

- (void)showTrendingGifs:(UIButton *)sender
{
    [self hideKeyboard];
    self.keywordLabel.text = @"#Trending 20";
    self.shareView.hidden = YES;
    [self fetchTrendingGifs];
}

- (void)showCustomGifs:(UIButton *)sender
{
    NSArray *images = [[AnimatedImageManager sharedInstance] getGifs];
    self.keywordLabel.text = @"DIY Gifs";
    [self hideKeyboard];
    [self.animatedGIFs removeAllObjects];
    [self.animatedGIFs addObjectsFromArray:images];
    if (images.count == 0)
    {
        self.shareView.text = @"You don't have any custom gif yet, bro";
        self.shareView.hidden = NO;
    }
    [self.collectionView reloadData];
}

- (void)didLongPressOnCollectionView:(UILongPressGestureRecognizer *)sender
{
    self.shareView.frame = self.collectionView.bounds;
    switch (sender.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            self.shareView.hidden = NO;
            CGPoint location = [sender locationInView:self.collectionView];
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            if ([cell isKindOfClass:[ImageCollectionViewCell class]])
            {
                ImageCollectionViewCell *imageCell = (ImageCollectionViewCell *)cell;
                if (imageCell.imageView.image)
                {
                    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
                    pasteBoard.image = imageCell.imageView.image;
                    
                    UIImage *image = imageCell.imageView.image;
                    
                    NSLog(@"size is %@",  [NSValue valueWithCGSize:image.size]);
                    NSData *data = [AnimatedGIFImageSerialization animatedGIFDataWithImage:image error:nil];
                    [pasteBoard setData:data forPasteboardType:@"com.compuserve.gif"];
                    NSLog(@"Suceed!");
                    data = nil;
                }
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
            self.shareView.hidden = YES;
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark - keyboardView Delegate
- (void)keyboard:(SearchKeyboardView *)keyboard didFinishSearchingWithKeyword:(NSString *)keyword
{
    [self hideKeyboard];
    if ([keyword length] == 0)
    {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[GifManager sharedManager] getGifWithKeyword:keyword onSuccess:^(NSArray *gifs, id responseObject) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.animatedGIFs removeAllObjects];
        strongSelf.keywordLabel.text = [NSString stringWithFormat:@"#%@",keyword];
        [strongSelf.animatedGIFs addObjectsFromArray:gifs];
        [strongSelf.collectionView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [weakSelf.shareView showWithText:@"No Internet Connection"];
    }];
}

- (void)keyboard:(SearchKeyboardView *)keyboard didInsertCharWithKeyboard:(NSString *)charString
{
    [self.textDocumentProxy insertText:charString];
}

- (void)didDeleteCharWithKeyboard:(SearchKeyboardView *)keyboard
{
    [self.textDocumentProxy deleteBackward];
}

@end
