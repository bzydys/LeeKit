//
//  UIViewController+Lee.m
//  LeeKit
//
//  Created by Lee on 2018/3/8.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "UIViewController+Lee.h"
#import <objc/runtime.h>

@interface UIViewController()
@property(nonatomic, strong) UINavigationBar *transitionNavigationBar;// by molice 对应 UIViewController (NavigationBarTransition) 里的 transitionNavigationBar，为了让这个属性在这里可以被访问到，有点 hack
@end

@implementation UIViewController (Lee)


void lee_loadViewIfNeeded (id current_self, SEL current_cmd) {
    // 主动调用 self.view，从而触发 loadView，以模拟 iOS 9.0 以下的系统 loadViewIfNeeded 行为
    [((UIViewController *)current_self) view];
}

+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![[UIViewController class] instancesRespondToSelector:@selector(loadViewIfNeeded)]) {
            Class metaclass = [UIViewController class];
            class_addMethod(metaclass, @selector(loadViewIfNeeded), (IMP)lee_loadViewIfNeeded, "v@:");
        }
    });
}

- (BOOL)lee_isPresented {
    UIViewController *viewController = self;
    if (self.navigationController) {
        if (self.navigationController.viewControllers.firstObject != self) {
            return NO;
        }
        viewController = self.navigationController;
    }
    BOOL result = viewController.presentingViewController.presentedViewController == viewController;
    return result;
}

- (UIViewController *)lee_previousViewController {
    if (self.navigationController.viewControllers && self.navigationController.viewControllers.count > 1 && self.navigationController.topViewController == self) {
        NSUInteger count = self.navigationController.viewControllers.count;
        return (UIViewController *)[self.navigationController.viewControllers objectAtIndex:count - 2];
    }
    return nil;
}

- (UIViewController *)lee_visibleViewControllerIfExist {
    
    if (self.presentedViewController) {
        return [self.presentedViewController lee_visibleViewControllerIfExist];
    }
    
    if ([self isKindOfClass:[UINavigationController class]]) {
        return [((UINavigationController *)self).visibleViewController lee_visibleViewControllerIfExist];
    }
    
    if ([self isKindOfClass:[UITabBarController class]]) {
        return [((UITabBarController *)self).selectedViewController lee_visibleViewControllerIfExist];
    }
    
    if ([self isViewLoaded] && self.view.window) {
        return self;
    } else {
        NSLog(@"lee_visibleViewControllerIfExist:，找不到可见的viewController。self = %@, self.view = %@, self.view.window = %@", self, [self isViewLoaded] ? self.view : nil, [self isViewLoaded] ? self.view.window : nil);
        return nil;
    }
}

- (BOOL)lee_isViewLoadedAndVisible {
    return self.isViewLoaded && self.view.window;
}

- (CGFloat)lee_navigationBarMaxYInViewCoordinator {
    if (!self.isViewLoaded) {
        return 0;
    }
    
    UINavigationBar *navigationBar = !self.navigationController.navigationBarHidden && self.navigationController.navigationBar ? self.navigationController.navigationBar : ([self respondsToSelector:@selector(transitionNavigationBar)] && self.transitionNavigationBar ? self.transitionNavigationBar : nil);
    
    if (!navigationBar) {
        return 0;
    }
    
    CGRect navigationBarFrameInView = [self.view convertRect:navigationBar.frame fromView:navigationBar.superview];
    CGRect navigationBarFrame = CGRectIntersection(self.view.bounds, navigationBarFrameInView);
    
    CGFloat result = CGRectGetMaxY(navigationBarFrame);
    return result;
}


- (CGFloat)lee_tabBarSpacingInViewCoordinator {
    if (!self.isViewLoaded) {
        return 0;
    }
    if (!self.tabBarController.tabBar || self.tabBarController.tabBar.hidden) {
        return 0;
    }
    CGRect tabBarFrame = CGRectIntersection(self.view.bounds, [self.view convertRect:self.tabBarController.tabBar.frame fromView:self.tabBarController.tabBar.superview]);
    
    
    CGFloat result = CGRectGetHeight(self.view.bounds) - CGRectGetMinY(tabBarFrame);
    return result;
}

@end


@implementation UIViewController (Runtime)

- (BOOL)lee_hasOverrideUIKitMethod:(SEL)selector {
    // 排序依照 Xcode Interface Builder 里的控件排序，但保证子类在父类前面
    NSMutableArray<Class> *viewControllerSuperclasses = [[NSMutableArray alloc] initWithObjects:
                                                         [UIImagePickerController class],
                                                         [UINavigationController class],
                                                         [UITableViewController class],
                                                         [UICollectionViewController class],
                                                         [UITabBarController class],
                                                         [UISplitViewController class],
                                                         [UIPageViewController class],
                                                         [UIViewController class],
                                                         nil];
    
    if (NSClassFromString(@"UIAlertController")) {
        [viewControllerSuperclasses addObject:[UIAlertController class]];
    }
    if (NSClassFromString(@"UISearchController")) {
        [viewControllerSuperclasses addObject:[UISearchController class]];
    }
    for (NSInteger i = 0, l = viewControllerSuperclasses.count; i < l; i++) {
        Class superclass = viewControllerSuperclasses[i];
        if ([self lee_hasOverrideMethod:selector ofSuperclass:superclass]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)lee_hasOverrideMethod:(SEL)selector ofSuperclass:(Class)superclass {
    if (![[self class] isSubclassOfClass:superclass]) {
        return NO;
    }
    
    if (![superclass instancesRespondToSelector:selector]) {
        return NO;
    }
    
    Method superclassMethod = class_getInstanceMethod(superclass, selector);
    Method instanceMethod = class_getInstanceMethod([self class], selector);
    if (!instanceMethod || instanceMethod == superclassMethod) {
        return NO;
    }
    return YES;
}

@end
