//
//  ImageTrendingViewController.m
//  SlackGifKeyboard
//
//  Created by Ken Huang on 2015-05-29.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import "ImageTrendingViewController.h"
#import "TrendingImageManager.h"
#import "ImageCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "UIColor+Flat.h"

@interface ImageTrendingViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation ImageTrendingViewController{
    NSArray *_images;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout: layout];
    [self.view addSubview:self.collectionView];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor belizeHole];
    [self.collectionView registerClass:[ImageCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *button = [UIButton new];
    [button addTarget:self action:@selector(didPressCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0.0f, CGRectGetHeight(self.view.bounds) - 60.0f, CGRectGetWidth(self.view.bounds), 60.0f);
    button.backgroundColor = [UIColor airbnbPink];
    [button setTitle:@"Close" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"Avenir-Black" size:40.0f];
    [self.view insertSubview:button aboveSubview:self.collectionView];
    _images = [[TrendingImageManager sharedInstance] getRecentImages];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didPressCloseButton:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];

    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:_images[indexPath.row]] placeholderImage:nil];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((CGRectGetWidth(collectionView.bounds) - 10.0f) / 2.0f, 200.0f);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _images.count;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(40.0f, 0.0f, 0.0, 0.0f);
}

@end
