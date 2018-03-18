//
//  LeeTips.h
//  LeeKit
//
//  Created by Lee on 2018/3/13.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "LeeToastView.h"

/// 默认的 parentView
#define DefaultTipsParentView [[[UIApplication sharedApplication] delegate] window]

/**
 * 简单封装了 LeeToastView，支持弹出纯文本、loading、succeed、error、info 等五种 tips。如果这些接口还满足不了业务的需求，可以通过 LeeTips 的分类自行添加接口。
 * 注意用类方法显示 tips 的话，会导致父类的 willShowBlock 无法正常工作，具体请查看 willShowBlock 的注释。
 * @see [LeeToastView willShowBlock]
 */

@interface LeeTips : LeeToastView

/// 实例方法：需要自己addSubview，hide之后不会自动removeFromSuperView
NS_ASSUME_NONNULL_BEGIN
- (void)showLoading;
- (void)showLoading:(nullable NSString *)text;
- (void)showLoadingHideAfterDelay:(NSTimeInterval)delay;
- (void)showLoading:(nullable NSString *)text hideAfterDelay:(NSTimeInterval)delay;
- (void)showLoading:(nullable NSString *)text detailText:(nullable NSString *)detailText;
- (void)showLoading:(nullable NSString *)text detailText:(nullable NSString *)detailText hideAfterDelay:(NSTimeInterval)delay;

- (void)showWithText:(nullable NSString *)text;
- (void)showWithText:(nullable NSString *)text hideAfterDelay:(NSTimeInterval)delay;
- (void)showWithText:(nullable NSString *)text detailText:(nullable NSString *)detailText;
- (void)showWithText:(nullable NSString *)text detailText:(nullable NSString *)detailText hideAfterDelay:(NSTimeInterval)delay;

- (void)showSucceed:(nullable NSString *)text;
- (void)showSucceed:(nullable NSString *)text hideAfterDelay:(NSTimeInterval)delay;
- (void)showSucceed:(nullable NSString *)text detailText:(nullable NSString *)detailText;
- (void)showSucceed:(nullable NSString *)text detailText:(nullable NSString *)detailText hideAfterDelay:(NSTimeInterval)delay;

- (void)showError:(nullable NSString *)text;
- (void)showError:(nullable NSString *)text hideAfterDelay:(NSTimeInterval)delay;
- (void)showError:(nullable NSString *)text detailText:(nullable NSString *)detailText;
- (void)showError:(nullable NSString *)text detailText:(nullable NSString *)detailText hideAfterDelay:(NSTimeInterval)delay;

- (void)showInfo:(nullable NSString *)text;
- (void)showInfo:(nullable NSString *)text hideAfterDelay:(NSTimeInterval)delay;
- (void)showInfo:(nullable NSString *)text detailText:(nullable NSString *)detailText;
- (void)showInfo:(nullable NSString *)text detailText:(nullable NSString *)detailText hideAfterDelay:(NSTimeInterval)delay;

/// 类方法：主要用在局部一次性使用的场景，hide之后会自动removeFromSuperView

+ (LeeTips *)createTipsToView:(UIView *)view;

+ (LeeTips *)showLoadingInView:(UIView *)view;
+ (LeeTips *)showLoading:(nullable NSString *)text inView:(UIView *)view;
+ (LeeTips *)showLoadingInView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;
+ (LeeTips *)showLoading:(nullable NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;
+ (LeeTips *)showLoading:(nullable NSString *)text detailText:(nullable NSString *)detailText inView:(UIView *)view;
+ (LeeTips *)showLoading:(nullable NSString *)text detailText:(nullable NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;

+ (LeeTips *)showWithText:(nullable NSString *)text;
+ (LeeTips *)showWithText:(nullable NSString *)text detailText:(nullable NSString *)detailText;
+ (LeeTips *)showWithText:(nullable NSString *)text inView:(UIView *)view;
+ (LeeTips *)showWithText:(nullable NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;
+ (LeeTips *)showWithText:(nullable NSString *)text detailText:(nullable NSString *)detailText inView:(UIView *)view;
+ (LeeTips *)showWithText:(nullable NSString *)text detailText:(nullable NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;

+ (LeeTips *)showSucceed:(nullable NSString *)text;
+ (LeeTips *)showSucceed:(nullable NSString *)text detailText:(nullable NSString *)detailText;
+ (LeeTips *)showSucceed:(nullable NSString *)text inView:(UIView *)view;
+ (LeeTips *)showSucceed:(nullable NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;
+ (LeeTips *)showSucceed:(nullable NSString *)text detailText:(nullable NSString *)detailText inView:(UIView *)view;
+ (LeeTips *)showSucceed:(nullable NSString *)text detailText:(nullable NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;

+ (LeeTips *)showError:(nullable NSString *)text;
+ (LeeTips *)showError:(nullable NSString *)text detailText:(nullable NSString *)detailText;
+ (LeeTips *)showError:(nullable NSString *)text inView:(UIView *)view;
+ (LeeTips *)showError:(nullable NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;
+ (LeeTips *)showError:(nullable NSString *)text detailText:(nullable NSString *)detailText inView:(UIView *)view;
+ (LeeTips *)showError:(nullable NSString *)text detailText:(nullable NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;

+ (LeeTips *)showInfo:(nullable NSString *)text;
+ (LeeTips *)showInfo:(nullable NSString *)text detailText:(nullable NSString *)detailText;
+ (LeeTips *)showInfo:(nullable NSString *)text inView:(UIView *)view;
+ (LeeTips *)showInfo:(nullable NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;
+ (LeeTips *)showInfo:(nullable NSString *)text detailText:(nullable NSString *)detailText inView:(UIView *)view;
+ (LeeTips *)showInfo:(nullable NSString *)text detailText:(nullable NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;

/// 隐藏 tips
+ (void)hideAllTipsInView:(UIView *)view;
+ (void)hideAllTips;


NS_ASSUME_NONNULL_END
@end
