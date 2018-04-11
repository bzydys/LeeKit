//
//  UINavigationController+NavigationBarTransition.m
//  LeeKit
//
//  Created by Lee on 2018/3/5.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "UINavigationController+NavigationBarTransition.h"
#import "UINavigationBar+Transition.h"
#import "LeeNavigationControllerDelegate.h"
#import "UIImage+Lee.h"

#define IOS_VERSION ([[[UIDevice currentDevice] systemVersion] floatValue])
@interface _LeeTransitionNavigationBar: UINavigationBar

@end

@implementation _LeeTransitionNavigationBar

-(void)layoutSubviews{
    [super layoutSubviews];
    if (IOS_VERSION >= 11.0) {
        // iOS 11 以前，自己 init 的 navigationBar，它的 backgroundView 默认会一直保持与 navigationBar 的高度相等，但 iOS 11 Beta 1-5 里，自己 init 的 navigationBar.backgroundView.height 默认一直是 44，所以才加上这个兼容
        UIView *backgroundView = [self valueForKey:@"backgroundView"];
        backgroundView.frame = self.bounds;
    }
}

@end

@interface UIViewController (NavigationBarTransition)

/// 用来模仿真的navBar的，在转场过程中存在的一条假navBar
@property (nonatomic, strong) _LeeTransitionNavigationBar *transitionNavigationBar;

/// 是否要把真的navBar隐藏
@property (nonatomic, assign) BOOL prefersNavigationBarBackgroundViewHidden;

/// 原始的clipsToBounds
@property(nonatomic, assign) BOOL originClipsToBounds;

/// 原始containerView的背景色
@property(nonatomic, strong) UIColor *originContainerViewBackgroundColor;

/// .m文件里自己赋值和使用。因为有些特殊情况下viewDidAppear之后，有可能还会调用到viewWillLayoutSubviews，导致原始的navBar隐藏，所以用这个属性做个保护。
@property (nonatomic, assign) BOOL lockTransitionNavigationBar;

/** 是否响应 LeeNavigationControllerDelegate */
- (BOOL)lee_respondLeeNavigationControllerDelegate;

/// 添加假的navBar
- (void)addTransitionNavigationBarIfNeeded;

@end

@implementation UIViewController (NavigationBarTransition)
+ (void)load {
    //hook一些生命周期的方法
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        ReplaceMethod(class, @selector(viewWillLayoutSubviews), @selector(NavigationBarTransition_viewWillLayoutSubviews));
        ReplaceMethod(class, @selector(viewWillAppear:), @selector(NavigationBarTransition_viewWillAppear:));
        ReplaceMethod(class, @selector(viewDidAppear:), @selector(NavigationBarTransition_viewDidAppear:));
        ReplaceMethod(class, @selector(viewDidDisappear:), @selector(NavigationBarTransition_viewDidDisappear:));
    });
}

- (void)NavigationBarTransition_viewWillAppear:(BOOL)animated {
    // 放在最前面，留一个时机给业务可以覆盖
    [self renderNavigationStyleInViewController:self animated:animated];
    [self NavigationBarTransition_viewWillAppear:animated];
}

- (void)NavigationBarTransition_viewDidAppear:(BOOL)animated {
    if (self.transitionNavigationBar) {
        [UIViewController replaceStyleForNavigationBar:self.transitionNavigationBar withNavigationBar:self.navigationController.navigationBar];
        [self removeTransitionNavigationBar];
        self.lockTransitionNavigationBar = YES;
        
        id <UIViewControllerTransitionCoordinator> transitionCoordinator = self.transitionCoordinator;
        [transitionCoordinator containerView].backgroundColor = self.originContainerViewBackgroundColor;
        self.view.clipsToBounds = self.originClipsToBounds;
    }
    self.prefersNavigationBarBackgroundViewHidden = NO;
    [self NavigationBarTransition_viewDidAppear:animated];
}

- (void)NavigationBarTransition_viewDidDisappear:(BOOL)animated {
    if (self.transitionNavigationBar) {
        [self removeTransitionNavigationBar];
        self.lockTransitionNavigationBar = NO;
        
        self.view.clipsToBounds = self.originClipsToBounds;
    }
    [self NavigationBarTransition_viewDidDisappear:animated];
}

- (void)NavigationBarTransition_viewWillLayoutSubviews {
    
    id <UIViewControllerTransitionCoordinator> transitionCoordinator = self.transitionCoordinator;
    UIViewController *fromViewController = [transitionCoordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionCoordinator viewControllerForKey:UITransitionContextToViewControllerKey];
    
    BOOL isCurrentToViewController = (self == self.navigationController.viewControllers.lastObject && self == toViewController);
    BOOL isPushingViewContrller = [self.navigationController.viewControllers containsObject:fromViewController];
    
    if (isCurrentToViewController && !self.lockTransitionNavigationBar) {
        
        BOOL shouldCustomNavigationBarTransition = NO;
        
        if (!self.transitionNavigationBar) {
            
            if (isPushingViewContrller) {
                if ([toViewController canCustomNavigationBarTransitionWhenPushAppearing] ||
                    [fromViewController canCustomNavigationBarTransitionWhenPushDisappearing]) {
                    shouldCustomNavigationBarTransition = YES;
                }
            } else {
                if ([toViewController canCustomNavigationBarTransitionWhenPopAppearing] ||
                    [fromViewController canCustomNavigationBarTransitionWhenPopDisappearing]) {
                    shouldCustomNavigationBarTransition = YES;
                }
            }
            
            if (shouldCustomNavigationBarTransition) {
                if (self.navigationController.navigationBar.translucent) {
                    // 如果原生bar是半透明的，需要给containerView加个背景色，否则有可能会看到下面的默认黑色背景色
                    toViewController.originContainerViewBackgroundColor = [transitionCoordinator containerView].backgroundColor;
                    [transitionCoordinator containerView].backgroundColor = [self containerViewBackgroundColor];
                }
                fromViewController.originClipsToBounds = fromViewController.view.clipsToBounds;
                toViewController.originClipsToBounds = toViewController.view.clipsToBounds;
                fromViewController.view.clipsToBounds = NO;
                toViewController.view.clipsToBounds = NO;
                [self addTransitionNavigationBarIfNeeded];
                [self resizeTransitionNavigationBarFrame];
                self.navigationController.navigationBar.transitionNavigationBar = self.transitionNavigationBar;
                self.prefersNavigationBarBackgroundViewHidden = YES;
            }
        }
    }
    
    [self NavigationBarTransition_viewWillLayoutSubviews];
}

- (void)addTransitionNavigationBarIfNeeded {
    
    if (!self.view.window || !self.navigationController.navigationBar) {
        return;
    }
    
    UINavigationBar *originBar = self.navigationController.navigationBar;
    _LeeTransitionNavigationBar *customBar = [[_LeeTransitionNavigationBar alloc] init];
    
    if (customBar.barStyle != originBar.barStyle) {
        customBar.barStyle = originBar.barStyle;
    }
    if (customBar.translucent != originBar.translucent) {
        customBar.translucent = originBar.translucent;
    }
    if (![customBar.barTintColor isEqual:originBar.barTintColor]) {
        customBar.barTintColor = originBar.barTintColor;
    }
    UIImage *backgroundImage = [originBar backgroundImageForBarMetrics:UIBarMetricsDefault];
    if (backgroundImage && CGSizeEqualToSize(backgroundImage.size, CGSizeZero)) {
        // 假设这里的图片时通过`[UIImage new]`这种形式创建的，那么会navBar会奇怪地显示为系统默认navBar的样式。不知道为什么 navController 设置自己的 navBar 为 [UIImage new] 却没事，所以这里做个保护。
        backgroundImage = [UIImage lee_imageWithColor:[UIColor clearColor]];
    }
    [customBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    [customBar setShadowImage:originBar.shadowImage];
    
    self.transitionNavigationBar = customBar;
    [self resizeTransitionNavigationBarFrame];
    
    if (!self.navigationController.navigationBarHidden) {
        [self.view addSubview:self.transitionNavigationBar];
    }
}

- (void)resizeTransitionNavigationBarFrame {
    if (!self.view.window) {
        return;
    }
    UIView *backgroundView = [self.navigationController.navigationBar valueForKey:@"backgroundView"];
    CGRect rect = [backgroundView.superview convertRect:backgroundView.frame toView:self.view];
    self.transitionNavigationBar.frame = rect;
}

- (UIColor *)containerViewBackgroundColor {
    UIColor *backgroundColor = [UIColor whiteColor];
    if ([self lee_respondLeeNavigationControllerDelegate]) {
        UIViewController<LeeNavigationControllerDelegate> *vc = (UIViewController<LeeNavigationControllerDelegate> *)self;
        if ([vc respondsToSelector:@selector(containerViewBackgroundColorWhenTransitioning)]) {
            backgroundColor = [vc containerViewBackgroundColorWhenTransitioning];
        }
    }
    return backgroundColor;
}

- (BOOL)canCustomNavigationBarTransitionWhenPopDisappearing {
    if ([self respondCustomNavigationBarTransitionWhenPopDisappearing]) {
        UIViewController<LeeNavigationControllerDelegate> *vc = (UIViewController<LeeNavigationControllerDelegate> *)self;
        return [vc shouldCustomNavigationBarTransitionWhenPopDisappearing];
    }
    return NO;
}

- (BOOL)respondCustomNavigationBarTransitionWhenPopDisappearing {
    BOOL respondPopDisappearing = NO;
    if ([self lee_respondLeeNavigationControllerDelegate]) {
        UIViewController<LeeNavigationControllerDelegate> *vc = (UIViewController<LeeNavigationControllerDelegate> *)self;
        if ([vc respondsToSelector:@selector(shouldCustomNavigationBarTransitionWhenPopDisappearing)]) {
            respondPopDisappearing = YES;
        }
    }
    return respondPopDisappearing;
}

- (BOOL)canCustomNavigationBarTransitionWhenPopAppearing {
    if ([self respondCustomNavigationBarTransitionWhenPopAppearing]) {
        UIViewController<LeeNavigationControllerDelegate> *vc = (UIViewController<LeeNavigationControllerDelegate> *)self;
        return [vc shouldCustomNavigationBarTransitionWhenPopAppearing];
    }
    return NO;
}

- (BOOL)respondCustomNavigationBarTransitionWhenPopAppearing {
    BOOL respondPopAppearing = NO;
    if ([self lee_respondLeeNavigationControllerDelegate]) {
        UIViewController<LeeNavigationControllerDelegate> *vc = (UIViewController<LeeNavigationControllerDelegate> *)self;
        if ([vc respondsToSelector:@selector(shouldCustomNavigationBarTransitionWhenPopAppearing)]) {
            respondPopAppearing = YES;
        }
    }
    return respondPopAppearing;
}


- (BOOL)canCustomNavigationBarTransitionWhenPushDisappearing {
    if ([self respondCustomNavigationBarTransitionWhenPushDisappearing]) {
        UIViewController<LeeNavigationControllerDelegate> *vc = (UIViewController<LeeNavigationControllerDelegate> *)self;
        return [vc shouldCustomNavigationBarTransitionWhenPushDisappearing];
    }
    return NO;
}

- (BOOL)respondCustomNavigationBarTransitionWhenPushDisappearing {
    BOOL respondPushDisappearing = NO;
    if ([self lee_respondLeeNavigationControllerDelegate]) {
        UIViewController<LeeNavigationControllerDelegate> *vc = (UIViewController<LeeNavigationControllerDelegate> *)self;
        if ([vc respondsToSelector:@selector(shouldCustomNavigationBarTransitionWhenPushDisappearing)]) {
            respondPushDisappearing = YES;
        }
    }
    return respondPushDisappearing;
}


// 该 viewController 实现自定义 navBar 动画的协议的返回值

- (BOOL)canCustomNavigationBarTransitionWhenPushAppearing {
    if ([self respondCustomNavigationBarTransitionWhenPushAppearing]) {
        UIViewController<LeeNavigationControllerDelegate> *vc = (UIViewController<LeeNavigationControllerDelegate> *)self;
        return [vc shouldCustomNavigationBarTransitionWhenPushAppearing];
    }
    return NO;
}

// 该 viewController 是否实现自定义 navBar 动画的协议

- (BOOL)respondCustomNavigationBarTransitionWhenPushAppearing {
    BOOL respondPushAppearing = NO;
    if ([self lee_respondLeeNavigationControllerDelegate]) {
        UIViewController<LeeNavigationControllerDelegate> *vc = (UIViewController<LeeNavigationControllerDelegate> *)self;
        if ([vc respondsToSelector:@selector(shouldCustomNavigationBarTransitionWhenPushAppearing)]) {
            respondPushAppearing = YES;
        }
    }
    return respondPushAppearing;
}


- (void)removeTransitionNavigationBar {
    if (!self.transitionNavigationBar) {
        return;
    }
    [self.transitionNavigationBar removeFromSuperview];
    self.transitionNavigationBar = nil;
}

+ (void)replaceStyleForNavigationBar:(UINavigationBar *)navbarA withNavigationBar:(UINavigationBar *)navbarB {
    navbarB.barStyle = navbarA.barStyle;
    navbarB.barTintColor = navbarA.barTintColor;
    [navbarB setBackgroundImage:[navbarA backgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
    [navbarB setShadowImage:navbarA.shadowImage];
}


-(void)renderNavigationStyleInViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 针对一个 container view controller 里面包含了若干个 view controller，这总情况里面的 view controller 也会相应这个 render 方法，这样就会覆盖 container view controller 的设置，所以应该规避这种情况。
    if (viewController != viewController.navigationController.topViewController) {
        return;
    }

    if (viewController.lee_respondLeeNavigationControllerDelegate) {
        UIViewController<LeeNavigationControllerDelegate> *vc = (UIViewController<LeeNavigationControllerDelegate> *)viewController;
        // 控制界面的状态栏颜色
        if ([vc shouldSetStatusBarStyleLight]) {
            if ([[UIApplication sharedApplication] statusBarStyle] < UIStatusBarStyleLightContent) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
#pragma clang diagnostic pop
                
            }
        }else{
            if ([[UIApplication sharedApplication] statusBarStyle] >= UIStatusBarStyleLightContent) {
                
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
#pragma clang diagnostic pop
            }
        }

        // 显示/隐藏 导航栏
        if ([vc canCustomNavigationBarTransitionIfBarHiddenable]) {
            if ([vc hideNavigationBarWhenTransitioning]) {
                if (!viewController.navigationController.isNavigationBarHidden) {
                    [viewController.navigationController setNavigationBarHidden:YES animated:animated];
                }
            } else {
                if (viewController.navigationController.isNavigationBarHidden) {
                    [viewController.navigationController setNavigationBarHidden:NO animated:animated];
                }
            }
        }
        
        // 不能直接return，否则当navBar再次出现的时候可能样式不正确，这里说的再次出现有可能不是由b本类控制的，而是自己手动触发
        // if (viewController.navigationController.isNavigationBarHidden) return;
        
        // 导航栏的背景
        if ([vc respondsToSelector:@selector(navigationBarBackgroundImage)]) {
            UIImage *backgroundImage = [vc navigationBarBackgroundImage];
            [viewController.navigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
        } else {
            [viewController.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        }
        
        // 导航栏底部的分隔线
        if ([vc respondsToSelector:@selector(navigationBarShadowImage)]) {
            UIImage *shadowImage = [vc navigationBarShadowImage];
            [viewController.navigationController.navigationBar setShadowImage:shadowImage];
        } else {
            [viewController.navigationController.navigationBar setShadowImage:[UIImage new]];
        }
        
        // 导航栏上控件的主题色
        if ([vc respondsToSelector:@selector(navigationBarTintColor)]) {
            UIColor *tintColor = [vc navigationBarTintColor];
            viewController.navigationController.navigationBar.tintColor = tintColor;
        } else {
            viewController.navigationController.navigationBar.tintColor = nil;
        }
        
    }

}

- (BOOL)canCustomNavigationBarTransitionIfBarHiddenable {
    if ([self respondCustomNavigationBarTransitionIfBarHiddenable]) {
        UIViewController<LeeNavigationControllerDelegate> *vc = (UIViewController<LeeNavigationControllerDelegate> *)self;
        return [vc shouldCustomNavigationBarTransitionIfBarHiddenable];
    }
    return NO;
}

- (BOOL)respondCustomNavigationBarTransitionIfBarHiddenable {
    BOOL respondIfBarHiddenable = NO;
    if ([self lee_respondLeeNavigationControllerDelegate]) {
        UIViewController<LeeNavigationControllerDelegate> *vc = (UIViewController<LeeNavigationControllerDelegate> *)self;
        if ([vc respondsToSelector:@selector(shouldCustomNavigationBarTransitionIfBarHiddenable)]) {
            respondIfBarHiddenable = YES;
        }
    }
    return respondIfBarHiddenable;
}

- (BOOL)lee_respondLeeNavigationControllerDelegate {
    return [[self class] conformsToProtocol:@protocol(LeeNavigationControllerDelegate)];
}

- (BOOL)hideNavigationBarWhenTransitioning {
    if ([self respondCustomNavigationBarTransitionWithBarHiddenState]) {
        UIViewController<LeeNavigationControllerDelegate> *vc = (UIViewController<LeeNavigationControllerDelegate> *)self;
        BOOL hidden = [vc preferredNavigationBarHidden];
        return hidden;
    }
    return NO;
}

- (BOOL)respondCustomNavigationBarTransitionWithBarHiddenState {
    BOOL respondWithBarHidden = NO;
    if ([self lee_respondLeeNavigationControllerDelegate]) {
        UIViewController<LeeNavigationControllerDelegate> *vc = (UIViewController<LeeNavigationControllerDelegate> *)self;
        if ([vc respondsToSelector:@selector(preferredNavigationBarHidden)]) {
            respondWithBarHidden = YES;
        }
    }
    return respondWithBarHidden;
}

#pragma mark - Setter / Getter

- (BOOL)lockTransitionNavigationBar {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setLockTransitionNavigationBar:(BOOL)lockTransitionNavigationBar {
    objc_setAssociatedObject(self, @selector(lockTransitionNavigationBar), [[NSNumber alloc] initWithBool:lockTransitionNavigationBar], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UINavigationBar *)transitionNavigationBar {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTransitionNavigationBar:(UINavigationBar *)transitionNavigationBar {
    objc_setAssociatedObject(self, @selector(transitionNavigationBar), transitionNavigationBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)prefersNavigationBarBackgroundViewHidden {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setPrefersNavigationBarBackgroundViewHidden:(BOOL)prefersNavigationBarBackgroundViewHidden {
    [[self.navigationController.navigationBar valueForKey:@"backgroundView"] setHidden:prefersNavigationBarBackgroundViewHidden];
    objc_setAssociatedObject(self, @selector(prefersNavigationBarBackgroundViewHidden), [[NSNumber alloc] initWithBool:prefersNavigationBarBackgroundViewHidden], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)originClipsToBounds {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setOriginClipsToBounds:(BOOL)originClipsToBounds {
    objc_setAssociatedObject(self, @selector(originClipsToBounds), [[NSNumber alloc] initWithBool:originClipsToBounds], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)originContainerViewBackgroundColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setOriginContainerViewBackgroundColor:(UIColor *)originContainerViewBackgroundColor {
    objc_setAssociatedObject(self, @selector(originContainerViewBackgroundColor), originContainerViewBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}



@end



@implementation UINavigationController (NavigationBarTransition)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = [self class];
        ReplaceMethod(cls, @selector(pushViewController:animated:), @selector(NavigationBarTransition_pushViewController:animated:));
        ReplaceMethod(cls, @selector(popViewControllerAnimated:), @selector(NavigationBarTransition_popViewControllerAnimated:));
        ReplaceMethod(cls, @selector(popToViewController:animated:), @selector(NavigationBarTransition_popToViewController:animated:));
        ReplaceMethod(cls, @selector(popToRootViewControllerAnimated:), @selector(NavigationBarTransition_popToRootViewControllerAnimated:));
    });
}

- (void)NavigationBarTransition_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    if (!disappearingViewController) {
        return [self NavigationBarTransition_pushViewController:viewController animated:animated];
    }
    
    BOOL shouldCustomNavigationBarTransition = NO;
    if ([disappearingViewController canCustomNavigationBarTransitionWhenPushDisappearing]) {
        shouldCustomNavigationBarTransition = YES;
    }
    if (!shouldCustomNavigationBarTransition && [viewController canCustomNavigationBarTransitionWhenPushAppearing]) {
        shouldCustomNavigationBarTransition = YES;
    }
    if (shouldCustomNavigationBarTransition) {
        [disappearingViewController addTransitionNavigationBarIfNeeded];
        disappearingViewController.prefersNavigationBarBackgroundViewHidden = YES;
    }
    
    return [self NavigationBarTransition_pushViewController:viewController animated:animated];
}

- (UIViewController *)NavigationBarTransition_popViewControllerAnimated:(BOOL)animated {
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    UIViewController *appearingViewController = self.viewControllers.count >= 2 ? self.viewControllers[self.viewControllers.count - 2] : nil;
    if (!disappearingViewController) {
        return [self NavigationBarTransition_popViewControllerAnimated:animated];
    }
    [self handlePopViewControllerNavigationBarTransitionWithDisappearViewController:disappearingViewController appearViewController:appearingViewController];
    
    return [self NavigationBarTransition_popViewControllerAnimated:animated];
}

- (NSArray<UIViewController *> *)NavigationBarTransition_popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    UIViewController *appearingViewController = viewController;
    NSArray<UIViewController *> *poppedViewControllers = [self NavigationBarTransition_popToViewController:viewController animated:animated];
    if (poppedViewControllers) {
        [self handlePopViewControllerNavigationBarTransitionWithDisappearViewController:disappearingViewController appearViewController:appearingViewController];
    }
    return poppedViewControllers;
}

- (NSArray<UIViewController *> *)NavigationBarTransition_popToRootViewControllerAnimated:(BOOL)animated {
    NSArray<UIViewController *> *poppedViewControllers = [self NavigationBarTransition_popToRootViewControllerAnimated:animated];
    if (self.viewControllers.count > 1) {
        UIViewController *disappearingViewController = self.viewControllers.lastObject;
        UIViewController *appearingViewController = self.viewControllers.firstObject;
        if (poppedViewControllers) {
            [self handlePopViewControllerNavigationBarTransitionWithDisappearViewController:disappearingViewController appearViewController:appearingViewController];
        }
    }
    return poppedViewControllers;
}

- (void)handlePopViewControllerNavigationBarTransitionWithDisappearViewController:(UIViewController *)disappearViewController appearViewController:(UIViewController *)appearViewController {
    BOOL shouldCustomNavigationBarTransition = NO;
    if ([disappearViewController canCustomNavigationBarTransitionWhenPopDisappearing]) {
        shouldCustomNavigationBarTransition = YES;
    }
    if (appearViewController && !shouldCustomNavigationBarTransition && [appearViewController canCustomNavigationBarTransitionWhenPopAppearing]) {
        shouldCustomNavigationBarTransition = YES;
    }
    if (shouldCustomNavigationBarTransition) {
        [disappearViewController addTransitionNavigationBarIfNeeded];
        if (appearViewController.transitionNavigationBar) {
            // 假设从A→B→C，其中A设置了bar的样式，B跟随A所以B里没有设置bar样式的代码，C又把样式改为另一种，此时从C返回B时，由于B没有设置bar的样式的代码，所以bar的样式依然会保留C的，这就错了，所以每次都要手动改回来才保险
            [UIViewController replaceStyleForNavigationBar:appearViewController.transitionNavigationBar withNavigationBar:self.navigationBar];
        }
        disappearViewController.prefersNavigationBarBackgroundViewHidden = YES;
    }
}


@end

