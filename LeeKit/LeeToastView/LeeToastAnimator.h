//
//  LeeToastAnimator.h
//  LeeKit
//
//  Created by Lee on 2018/3/12.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LeeToastView;

/**
 * `QMUIToastAnimatorDelegate`是所有`QMUIToastAnimator`或者其子类必须遵循的协议，是整个动画过程实现的地方。
 */
@protocol LeeToastAnimatorDelegate<NSObject>

@required
- (void)showWithCompletion:(void (^)(BOOL finished))completion;
- (void)hideWithCompletion:(void (^)(BOOL finished))completion;
- (BOOL)isShowing;
- (BOOL)isAnimating;

@end

typedef NS_ENUM(NSInteger, LeeToastAnimationType) {
    LeeToastAnimationTypeFade      = 0,
    LeeToastAnimationTypeZoom,
    LeeToastAnimationTypeSlide
};

/**
 * `LeeToastAnimator`可以让你通过实现一些协议来自定义ToastView显示和隐藏的动画。你可以继承`LeeToastAnimator`，然后实现`LeeToastAnimatorDelegate`中的方法，即可实现自定义的动画。LeeToastAnimator默认也提供了几种type的动画：1、LeeToastAnimationTypeFade；2、LeeToastAnimationTypeZoom；3、LeeToastAnimationTypeSlide；
 */
@interface LeeToastAnimator : NSObject <LeeToastAnimatorDelegate>

/**
 * 初始化方法，请务必使用这个方法来初始化。
 *
 * @param toastView 要使用这个animator的LeeToastView实例。
 */
- (instancetype)initWithToastView:(LeeToastView *)toastView NS_DESIGNATED_INITIALIZER;

/**
 * 获取初始化传进来的LeeToastView。
 */
@property(nonatomic, weak, readonly) LeeToastView *toastView;

/**
 * 指定LeeToastAnimator做动画的类型type。此功能暂时未实现，目前所有动画类型都是LeeToastAnimationTypeFade。
 */
@property(nonatomic, assign) LeeToastAnimationType animationType;

@end
