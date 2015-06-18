//
//  FramSelectorLayout.m
//  SlackGifKeyboard
//
//  Created by Ken Huang on 2015-06-14.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import "FrameSelectorLayout.h"

@implementation FrameSelectorLayout

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.sectionInset = UIEdgeInsetsZero;
        self.minimumLineSpacing = 0.0f;
        self.minimumInteritemSpacing = 0.0f;
    }
    return self;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat horizontalOffset = proposedContentOffset.x;
    
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, CGRectGetWidth(self.collectionView.bounds), CGRectGetHeight(self.collectionView.bounds));
    
    NSArray *array = [super layoutAttributesForElementsInRect:targetRect];
    
    for (UICollectionViewLayoutAttributes *layoutAttributes in array) {
        CGFloat itemOffset = layoutAttributes.frame.origin.x;
        
        if (ABS(itemOffset - horizontalOffset) < ABS(offsetAdjustment))
        {
            offsetAdjustment = itemOffset - horizontalOffset;
        }
    }
    
    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}

@end
