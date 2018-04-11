//
//  UIViewController+Lee.h
//  LeeKit
//
//  Created by Lee on 2018/3/8.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Lee)

/** 获取和自身处于同一个UINavigationController里的上一个UIViewController */
@property(nullable, nonatomic, weak, readonly) UIViewController *lee_previousViewController;

/**
 *  当前 viewController 是否是被以 present 的方式显示的，是则返回 YES，否则返回 NO
 *  @warning 对于被放在 UINavigationController 里显示的 UIViewController，如果 self 是 self.navigationController 的第一个 viewController，则如果 self.navigationController 是被 present 起来的，那么 self.lee_isPresented = self.navigationController.lee_isPresented = YES。利用这个特性，可以方便地给 navigationController 的第一个界面的左上角添加关闭按钮。
 */
- (BOOL)lee_isPresented;

/**
 *  获取当前controller里的最高层可见viewController（可见的意思是还会判断self.view.window是否存在）
 *
 *  @return 当前controller里的最高层可见viewController
 */
- (nullable UIViewController *)lee_visibleViewControllerIfExist;

/**
 *  是否应该响应一些UI相关的通知，例如 UIKeyboardNotification、UIMenuControllerNotification等，因为有可能当前界面已经被切走了（push到其他界面），但仍可能收到通知，所以在响应通知之前都应该做一下这个判断
 */
- (BOOL)lee_isViewLoadedAndVisible;

/**
 *  UINavigationBar 在 self.view 坐标系里的 maxY，一般用于 self.view.subviews 布局时参考用
 *  @warning 注意由于使用了坐标系转换的计算，所以要求在 self.view.window 存在的情况下使用才可以，因此请勿在 viewDidLoad 内使用，建议在 viewDidLayoutSubviews、viewWillAppear: 里使用。
 *  @warning 如果不存在 UINavigationBar，则返回 0
 */
@property(nonatomic, assign, readonly) CGFloat lee_navigationBarMaxYInViewCoordinator;

/**
 *  底部 UITabBar 在 self.view 坐标系里的占位高度，一般用于 self.view.subviews 布局时参考用
 *  @warning 注意由于使用了坐标系转换的计算，所以要求在 self.view.window 存在的情况下使用才可以，因此请勿在 viewDidLoad 内使用，建议在 viewDidLayoutSubviews、viewWillAppear: 里使用。
 *  @warning 如果不存在 UITabBar，则返回 0
 */
@property(nonatomic, assign, readonly) CGFloat lee_tabBarSpacingInViewCoordinator;

@end

@interface UIViewController (Runtime)

/**
 *  判断当前类是否有重写某个指定的 UIViewController 的方法
 *  @param selector 要判断的方法
 *  @return YES 表示当前类重写了指定的方法，NO 表示没有重写，使用的是 UIViewController 默认的实现
 */
- (BOOL)lee_hasOverrideUIKitMethod:(_Nonnull SEL)selector;
@end
