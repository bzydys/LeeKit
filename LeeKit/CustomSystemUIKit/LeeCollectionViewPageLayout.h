//
//  LeeCollectionViewPageLayout.h
//  LeeKit
//
//  Created by Lee on 2018/3/8.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LeeCollectionViewPageLayoutStyle) {
    LeeCollectionViewPageLayoutStyleDefault, // 普通模式，水平滑动
    LeeCollectionViewPageLayoutStyleScale   // 缩放模式，两边的item会小一点，逐渐向中间放大
};

@interface LeeCollectionViewPageLayout : UICollectionViewFlowLayout

-(instancetype)initWithStyle:(LeeCollectionViewPageLayoutStyle)style NS_DESIGNATED_INITIALIZER;

@property(nonatomic, assign, readonly) LeeCollectionViewPageLayoutStyle  style;

/**
 *  规定超过这个滚动速度就强制翻页，从而使翻页更容易触发。默认为 0.4
 */
@property(nonatomic, assign) CGFloat velocityForEnsurePageDown;
/**
 *  是否支持一次滑动可以滚动多个 item，默认为 YES
 */
@property(nonatomic, assign) BOOL allowMutipleItemScroll;

/**
 *  规定了当支持一次滑动允许滚动多个 item 的时候，滑动速度要达到多少才会滚动多个 item，默认为 0.7
 *
 *  仅当 allowsMultipleItemScroll 为 YES 时生效
 */
@property(nonatomic, assign) CGFloat mutipleItemScrollVelocityLimit;

@end

@interface LeeCollectionViewPageLayout (ScaleStyle)

/**
 *  中间那张卡片基于初始大小的缩放倍数，默认为 1.0
 */
@property(nonatomic, assign) CGFloat maximumScale;

/**
 *  除了中间之外的其他卡片基于初始大小的缩放倍数，默认为 0.9
 */
@property(nonatomic, assign) CGFloat minimumScale;

@end
