//
//  UINavigationController+NavigationBarTransition.h
//  LeeKit
//
//  Created by Lee on 2018/3/5.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  因为系统的UINavigationController只有一个navBar，所以会导致在切换controller的时候，如果两个controller的navBar状态不一致（包括backgroundImgae、shadowImage、barTintColor等等），就会导致在刚要切换的瞬间，navBar的状态都立马变成下一个controller所设置的样式了，为了解决这种情况，给出了一个方案，有四个方法可以决定你在转场的时候要不要使用自定义的navBar来模仿真实的navBar。
 */

@interface UINavigationController (NavigationBarTransition)

@end

@interface UINavigationController (UISubclassingHooks)
/**
 *  每个界面Controller在即将展示的时候被调用，在`UINavigationController`的方法`navigationController:willShowViewController:animated:`中会自动被调用，同时因为如果把一个界面dismiss后回来此时并不会调用`navigationController:willShowViewController`，所以需要在`viewWillAppear`里面也会调用一次。
 */
- (void)willShowViewController:(nonnull UIViewController *)viewController animated:(BOOL)animated NS_REQUIRES_SUPER;

/**
 *  同上
 */
- (void)didShowViewController:(nonnull UIViewController *)viewController animated:(BOOL)animated NS_REQUIRES_SUPER;
@end
