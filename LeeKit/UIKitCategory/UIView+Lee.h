//
//  UIView+Lee.h
//  LeeKit
//
//  Created by Lee on 2018/3/8.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, LeeBorderViewPosition) {
    LeeBorderViewPositionNone      = 0,
    LeeBorderViewPositionTop       = 1 << 0,
    LeeBorderViewPositionLeft      = 1 << 1,
    LeeBorderViewPositionBottom    = 1 << 2,
    LeeBorderViewPositionRight     = 1 << 3
};

/**
 *  UIView (Lee) 为 UIView 方便地显示某几个方向上的边框。
 *
 *  系统的默认实现里，要为 UIView 加边框一般是通过 view.layer 来实现，view.layer 会给四条边都加上边框，如果你只想为其中某几条加上边框就很麻烦，于是 UIView (lee_Border) 提供了 lee_borderPosition 来解决这个问题。
 *  @warning 注意如果你需要为 UIView 四条边都加上边框，请使用系统默认的 view.layer 来实现，而不要用 UIView (lee_Border)，会浪费资源，这也是为什么 LeeBorderViewPosition 不提供一个 LeeBorderViewPositionAll 枚举值的原因。
 */

@interface UIView (Lee)

/// 设置边框类型，支持组合，例如：`borderPosition = LeeBorderViewPositionTop|LeeBorderViewPositionBottom`
@property(nonatomic, assign) LeeBorderViewPosition lee_borderPosition;

/// 边框的大小，默认为PixelOne
@property(nonatomic, assign) CGFloat lee_borderWidth;

/// 边框的颜色，默认为UIColorSeparator
@property(nonatomic, strong) UIColor *lee_borderColor;

/// 虚线 : dashPhase默认是0，且当dashPattern设置了才有效
/// lee_dashPhase 表示虚线起始的偏移，lee_dashPattern 可以传一个数组，表示“lineWidth，lineSpacing，lineWidth，lineSpacing...”的顺序，至少传 2 个。
@property(nonatomic, assign) CGFloat lee_dashPhase;
@property(nonatomic, copy)   NSArray <NSNumber *> *lee_dashPattern;

/// border的layer
@property(nonatomic, strong, readonly) CAShapeLayer *lee_borderLayer;

@end

/**
 *  对 view.frame 操作的简便封装，注意 view 与 view 之间互相计算时，需要保证处于同一个坐标系内。
 */
@interface UIView (Lee_Layout)

/// 等价于 CGRectGetMinY(frame)
@property(nonatomic, assign) CGFloat lee_top;

/// 等价于 CGRectGetMinX(frame)
@property(nonatomic, assign) CGFloat lee_left;

/// 等价于 CGRectGetMaxY(frame)
@property(nonatomic, assign) CGFloat lee_bottom;

/// 等价于 CGRectGetMaxX(frame)
@property(nonatomic, assign) CGFloat lee_right;

/// 等价于 CGRectGetWidth(frame)
@property(nonatomic, assign) CGFloat lee_width;

/// 等价于 CGRectGetHeight(frame)
@property(nonatomic, assign) CGFloat lee_height;

/// 获取当前 view 在 superview 内水平居中时的 left
@property(nonatomic, assign, readonly) CGFloat lee_leftWhenCenterInSuperview;

/// 获取当前 view 在 superview 内垂直居中时的 top
@property(nonatomic, assign, readonly) CGFloat lee_topWhenCenterInSuperview;

@end

/**
 *  方便地将某个 UIView 截图并转成一个 UIImage，注意如果这个 UIView 本身做了 transform，也不会在截图上反映出来，截图始终都是原始 UIView 的截图。
 */
@interface UIView (Lee_Snapshotting)

- (UIImage *)lee_snapshotLayerImage;
- (UIImage *)lee_snapshotImageAfterScreenUpdates:(BOOL)afterScreenUpdates;
@end
