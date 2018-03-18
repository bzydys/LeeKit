//
//  LeeCollectionViewPageLayout.m
//  LeeKit
//
//  Created by Lee on 2018/3/8.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "LeeCollectionViewPageLayout.h"

@interface LeeCollectionViewPageLayout () {
    CGFloat _maximumScale;
    CGFloat _minimumScale;
    CGSize _finalItemSize;
}

@end

@implementation LeeCollectionViewPageLayout (ScaleStyle)

- (CGFloat)maximumScale {
    return _maximumScale;
}

- (void)setMaximumScale:(CGFloat)maximumScale {
    _maximumScale = maximumScale;
}

- (CGFloat)minimumScale {
    return _minimumScale;
}

- (void)setMinimumScale:(CGFloat)minimumScale {
    _minimumScale = minimumScale;
}

@end



@implementation LeeCollectionViewPageLayout

- (instancetype)initWithStyle:(LeeCollectionViewPageLayoutStyle)style {
    if (self = [super init]) {
        _style = style;
        self.velocityForEnsurePageDown = 0.4;
        self.allowMutipleItemScroll = YES;
        self.mutipleItemScrollVelocityLimit = 0.7;
        self.maximumScale = 1.0;
        self.minimumScale = 0.94;
        self.minimumInteritemSpacing = 0;
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}

- (instancetype)init {
    return [self initWithStyle:LeeCollectionViewPageLayoutStyleDefault];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self init];
}

-(void)prepareLayout{
    [super prepareLayout];
    //如果实现了layout的delegate
    CGSize itemSize = self.itemSize;
    id<UICollectionViewDelegateFlowLayout> layoutDelegate = (id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate;
    if ([layoutDelegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
        itemSize = [layoutDelegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    }
    self.sectionInset = UIEdgeInsetsMake(self.sectionInset.top, CGRectGetWidth(self.collectionView.frame)/2.0 - itemSize.width/2.0, self.sectionInset.bottom, CGRectGetWidth(self.collectionView.frame)/2.0 - itemSize.width/2.0);
    _finalItemSize = itemSize;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    if (self.style == LeeCollectionViewPageLayoutStyleScale) {
        return YES;
    }
    return [super shouldInvalidateLayoutForBoundsChange:newBounds];
}

-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    if (self.style == LeeCollectionViewPageLayoutStyleDefault) {
        return [super layoutAttributesForElementsInRect:rect];
    }
    NSArray<UICollectionViewLayoutAttributes *> *resultAttributes = [[NSArray alloc] initWithArray:[super layoutAttributesForElementsInRect:rect] copyItems:YES];
    CGFloat offset = CGRectGetMidX(self.collectionView.bounds);// 当前滚动位置的可视区域的中心点
    CGFloat distanceForMinimumScale = _finalItemSize.width + self.minimumLineSpacing;
    CGFloat distanceForMaximumScale = 0.0;
    for (UICollectionViewLayoutAttributes *attributes in resultAttributes) {
        CGFloat scale = 0;
        CGFloat distance = fabs(offset - attributes.center.x);
        if (distance >= distanceForMinimumScale) {
            scale = self.minimumScale;
        } else if (distance == distanceForMaximumScale) {
            scale = self.maximumScale;
        } else {
            scale = self.minimumScale + (distanceForMinimumScale - distance) * (self.maximumScale - self.minimumScale) / (distanceForMinimumScale - distanceForMaximumScale);
        }
        attributes.transform3D = CATransform3DMakeScale(scale, scale, 1);
        attributes.zIndex = 1;
    }
    return resultAttributes;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
#ifdef DEBUG
    NSLog(@"proposedContentOffset:%@   contentOffSet:%@", NSStringFromCGPoint(proposedContentOffset), NSStringFromCGPoint(self.collectionView.contentOffset));
#endif
    CGFloat itemSpacing = _finalItemSize.width + self.minimumLineSpacing;
    
    if (!self.allowMutipleItemScroll || fabs(velocity.x) <= fabs(self.mutipleItemScrollVelocityLimit)) {
        // 只滚动一页
        if (fabs(velocity.x) > self.velocityForEnsurePageDown) {
            // 为了更容易触发翻页，这里主动增加滚动位置
            BOOL scrollingToRight = proposedContentOffset.x < self.collectionView.contentOffset.x;
            //(itemSpacing / 2)保证最多滑动一页
            proposedContentOffset = CGPointMake(self.collectionView.contentOffset.x + (itemSpacing / 2) * (scrollingToRight ? -1 : 1), self.collectionView.contentOffset.y);
        } else {
            proposedContentOffset = self.collectionView.contentOffset;
        }
    }
    
    //round取整数个条目
    proposedContentOffset.x = round(proposedContentOffset.x / itemSpacing) * itemSpacing;
    
    return proposedContentOffset;
}



@end
