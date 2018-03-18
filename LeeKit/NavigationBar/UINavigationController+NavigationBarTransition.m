////
////  UINavigationController+NavigationBarTransition.m
////  LeeKit
////
////  Created by Lee on 2018/3/5.
////  Copyright © 2018年 Lee. All rights reserved.
////
//
//#import "UINavigationController+NavigationBarTransition.h"
//#import "UINavigationBar+Transition.h"
//#import "LeeNavigationControllerDelegate.h"
//
//#define IOS_VERSION ([[[UIDevice currentDevice] systemVersion] floatValue])
//@interface _LeeTransitionNavigationBar: UINavigationBar
//
//@end
//
//@implementation _LeeTransitionNavigationBar
//
//-(void)layoutSubviews{
//    [super layoutSubviews];
//    if (IOS_VERSION >= 11.0) {
//        // iOS 11 以前，自己 init 的 navigationBar，它的 backgroundView 默认会一直保持与 navigationBar 的高度相等，但 iOS 11 Beta 1-5 里，自己 init 的 navigationBar.backgroundView.height 默认一直是 44，所以才加上这个兼容
//        UIView *backgroundView = [self valueForKey:@"backgroundView"];
//        backgroundView.frame = self.bounds;
//    }
//}
//
//@end
//
//@interface UIViewController (NavigationBarTransition)
//
///// 用来模仿真的navBar的，在转场过程中存在的一条假navBar
//@property (nonatomic, strong) _LeeTransitionNavigationBar *transitionNavigationBar;
//
///// 是否要把真的navBar隐藏
//@property (nonatomic, assign) BOOL prefersNavigationBarBackgroundViewHidden;
//
///// 原始的clipsToBounds
//@property(nonatomic, assign) BOOL originClipsToBounds;
//
///// 原始containerView的背景色
//@property(nonatomic, strong) UIColor *originContainerViewBackgroundColor;
//
///// .m文件里自己赋值和使用。因为有些特殊情况下viewDidAppear之后，有可能还会调用到viewWillLayoutSubviews，导致原始的navBar隐藏，所以用这个属性做个保护。
//@property (nonatomic, assign) BOOL lockTransitionNavigationBar;
//
///** 是否响应 LeeNavigationControllerDelegate */
//- (BOOL)lee_respondLeeNavigationControllerDelegate;
//
///// 添加假的navBar
//- (void)addTransitionNavigationBarIfNeeded;
//
//@end
//
//@implementation UIViewController (NavigationBarTransition)
//+ (void)load {
//    //hook一些生命周期的方法
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        Class class = [self class];
//        ReplaceMethod(class, @selector(viewWillLayoutSubviews), @selector(NavigationBarTransition_viewWillLayoutSubviews));
//        ReplaceMethod(class, @selector(viewWillAppear:), @selector(NavigationBarTransition_viewWillAppear:));
//        ReplaceMethod(class, @selector(viewDidAppear:), @selector(NavigationBarTransition_viewDidAppear:));
//        ReplaceMethod(class, @selector(viewDidDisappear:), @selector(NavigationBarTransition_viewDidDisappear:));
//    });
//}
//
//- (void)NavigationBarTransition_viewWillAppear:(BOOL)animated {
//    // 放在最前面，留一个时机给业务可以覆盖
//    [self renderNavigationStyleInViewController:self animated:animated];
//    [self NavigationBarTransition_viewWillAppear:animated];
//}
//
//-(void)renderNavigationStyleInViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    // 针对一个 container view controller 里面包含了若干个 view controller，这总情况里面的 view controller 也会相应这个 render 方法，这样就会覆盖 container view controller 的设置，所以应该规避这种情况。
//    if (viewController != viewController.navigationController.topViewController) {
//        return;
//    }
//
//    if (viewController.lee_respondLeeNavigationControllerDelegate) {
//        UIViewController<LeeNavigationControllerDelegate> *vc = (UIViewController<LeeNavigationControllerDelegate> *)viewController;
//        // 控制界面的状态栏颜色
//        if ([vc shouldSetStatusBarStyleLight]) {
//            if ([[UIApplication sharedApplication] statusBarStyle] < UIStatusBarStyleLightContent) {
//                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//            }
//        }else{
//            if ([[UIApplication sharedApplication] statusBarStyle] >= UIStatusBarStyleLightContent) {
//                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
//            }
//        }
//
//        // 显示/隐藏 导航栏
//        if ([vc respondsToSelector:@selector(shouldCustomNavigationBarTransitionIfBarHiddenable)]) {
//            if ([vc shouldCustomNavigationBarTransitionIfBarHiddenable]) {
//
//            }
//        }
//    }
//
//}
//
//@end
//
//
//
//@implementation UINavigationController (NavigationBarTransition)
//
//@end

