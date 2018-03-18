//
//  LeeNavigationControllerDelegate.h
//  LeeKit
//
//  Created by Lee on 2018/3/5.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  若某些 UIViewController 实现了 LeeNavigationControllerDelegate，则在 LeeNavigationController 里显示时，可以很方便地控制 viewController 之间的样式切换（例如状态栏、导航栏等），不用在每个 viewController 的 viewWillAppear: 或viewWillDisappear: 里面单独控制。
 */

@protocol LeeNavigationControllerDelegate <NSObject>

@required
/// 是否需要将状态栏改为浅色文字，默认为宏StatusbarStyleLightInitially的值
/// @warning 需在项目的 Info.plist 文件内设置字段 “View controller-based status bar appearance” 的值为 NO 才能生效，如果不设置，或者值为 YES，则请使用系统提供的 - preferredStatusBarStyle 方法
- (BOOL)shouldSetStatusBarStyleLight;

/// 设置每个界面导航栏的显示/隐藏，为了减少对项目的侵入性，默认不开启这个接口的功能，只有当 shouldCustomNavigationBarTransitionIfBarHiddenable 返回 YES 时才会开启此功能。如果需要全局开启，那么就在 Controller 基类里面返回 YES；如果是老项目并不想全局使用此功能，那么则可以在单独的界面里面开启。
- (BOOL)preferredNavigationBarHidden;

@optional

/**
 *  在 self.navigationController 进行以下 4 个操作前，相应的 viewController 的 willPopInNavigationControllerWithAnimated: 方法会被调用：
 *  1. popViewControllerAnimated:
 *  2. popToViewController:animated:
 *  3. popToRootViewControllerAnimated:
 *  4. setViewControllers:animated:
 *
 *  此时 self 仍存在于 self.navigationController.viewControllers 堆栈内。
 *
 *  在 ARC 环境下，viewController 可能被放在 autorelease 池中，因此 viewController 被pop后不一定立即被销毁，所以一些对实时性要求很高的内存管理逻辑可以写在这里（而不是写在dealloc内）
 *
 *  @warning 不要尝试将 willPopInNavigationControllerWithAnimated: 视为点击返回按钮的回调，因为导致 viewController 被 pop 的情况不止点击返回按钮这一途径。系统的返回按钮是无法添加回调的，只能使用自定义的返回按钮。
 */
- (void)willPopInNavigationControllerWithAnimated:(BOOL)animated;

/**
 *  在 self.navigationController 进行以下 4 个操作后，相应的 viewController 的 didPopInNavigationControllerWithAnimated: 方法会被调用：
 *  1. popViewControllerAnimated:
 *  2. popToViewController:animated:
 *  3. popToRootViewControllerAnimated:
 *  4. setViewControllers:animated:
 *
 *  @warning 此时 self 已经不在 viewControllers 数组内
 */
- (void)didPopInNavigationControllerWithAnimated:(BOOL)animated;

/**
 *  当通过 setViewControllers:animated: 来修改 viewController 的堆栈时，如果参数 viewControllers.lastObject 与当前的 self.viewControllers.lastObject 不相同，则意味着会产生界面的切换，这种情况系统会自动调用两个切换的界面的生命周期方法，但如果两者相同，则意味着并不会产生界面切换，此时之前就已经在显示的那个 viewController 的 viewWillAppear:、viewDidAppear: 并不会被调用，那如果用户确实需要在这个时候修改一些界面元素，则找不到一个时机。所以这个方法就是提供这样一个时机给用户修改界面元素。
 */
-(void)viewControllerKeepingAppearWhenSetViewControllersWithAnimated:(BOOL)animated;
/// 设置titleView的tintColor
- (nullable UIColor *)titleViewTintColor;

/// 设置导航栏的背景图，默认为NavBarBackgroundImage
- (nullable UIImage *)navigationBarBackgroundImage;

/// 设置导航栏底部的分隔线图片，默认为NavBarShadowImage，必须在navigationBar设置了背景图后才有效
- (nullable UIImage *)navigationBarShadowImage;

/// 设置当前导航栏的UIBarButtonItem的tintColor，默认为NavBarTintColor
- (nullable UIColor *)navigationBarTintColor;

/// 设置系统返回按钮title，如果返回nil则使用系统默认的返回按钮标题
- (nullable NSString *)backBarButtonItemTitleWithPreviousViewController:(nullable UIViewController *)viewController;

/**
 *  设置当前导航栏是否需要使用自定义的 push/pop transition 效果，默认返回NO。<br/>
 *  因为系统的UINavigationController只有一个navBar，所以会导致在切换controller的时候，如果两个controller的navBar状态不一致（包括backgroundImage、shadowImage、barTintColor等等），就会导致在刚要切换的瞬间，navBar的状态都立马变成下一个controller所设置的样式了，为了解决这种情况，给出了一个方案，有四个方法可以决定你在转场的时候要不要使用自定义的navBar来模仿真实的navBar。具体方法如下：
 *  @see UINavigationController+NavigationBarTransition.h
 */
- (BOOL)shouldCustomNavigationBarTransitionWhenPushAppearing;
/**
 *  同上
 *  @see UINavigationController+NavigationBarTransition.h
 */
- (BOOL)shouldCustomNavigationBarTransitionWhenPushDisappearing;

/**
 *  同上
 *  @see UINavigationController+NavigationBarTransition.h
 */
- (BOOL)shouldCustomNavigationBarTransitionWhenPopAppearing;

/**
 *  同上
 *  @see UINavigationController+NavigationBarTransition.h
 */
- (BOOL)shouldCustomNavigationBarTransitionWhenPopDisappearing;
/**
 *  自定义navBar效果过程中UINavigationController的containerView的背景色
 *  @see UINavigationController+NavigationBarTransition.h
 */
- (nullable UIColor *)containerViewBackgroundColorWhenTransitioning;

/**
 *  当切换界面时，如果不同界面导航栏的显示状态不同，可以通过 shouldCustomNavigationBarTransitionIfBarHiddenable 设置是否需要接管导航栏的显示和隐藏。从而不需要在各自的界面的 viewWillappear 和 viewWillDisappear 里面去管理导航栏的状态。
 *  @see UINavigationController+NavigationBarTransition.h
 *  @see preferredNavigationBarHidden
 */
- (BOOL)shouldCustomNavigationBarTransitionIfBarHiddenable;

@end
