//
//  LeeNavigationController.h
//  LeeKit
//
//  Created by Lee on 2018/3/5.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LeeNavigationController : UINavigationController<UINavigationControllerDelegate>

@end

@interface LeeNavigationController (UISubclassingHooks)

/**
 *  每个界面Controller在即将展示的时候被调用，在`UINavigationController`的方法`navigationController:willShowViewController:animated:`中会自动被调用，同时因为如果把一个界面dismiss后回来此时并不会调用`navigationController:willShowViewController`，所以需要在`viewWillAppear`里面也会调用一次。
 */
- (void)willShowViewController:(nonnull UIViewController *)viewController animated:(BOOL)animated NS_REQUIRES_SUPER;

/**
 *  同上
 */
- (void)didShowViewController:(nonnull UIViewController *)viewController animated:(BOOL)animated NS_REQUIRES_SUPER;

@end
