//
//  UINavigationBar+Transition.m
//  LeeKit
//
//  Created by Lee on 2018/3/5.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "UINavigationBar+Transition.h"

@implementation UINavigationBar (Transition)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        ReplaceMethod(class, @selector(setShadowImage:), @selector(NavigationBarTransition_setShadowImage:));
        ReplaceMethod(class, @selector(setBarTintColor:), @selector(NavigationBarTransition_setBarTintColor:));
        ReplaceMethod(class, @selector(setBackgroundImage:forBarMetrics:), @selector(NavigationBarTransition_setBackgroundImage:forBarMetrics:));
    });
}

- (void)NavigationBarTransition_setShadowImage:(UIImage *)image {
    [self NavigationBarTransition_setShadowImage:image];
    if (self.transitionNavigationBar) {
        self.transitionNavigationBar.shadowImage = image;
    }
}

- (void)NavigationBarTransition_setBarTintColor:(UIColor *)tintColor {
    [self NavigationBarTransition_setBarTintColor:tintColor];
    if (self.transitionNavigationBar) {
        self.transitionNavigationBar.barTintColor = self.barTintColor;
    }
}
- (void)NavigationBarTransition_setBackgroundImage:(UIImage *)backgroundImage forBarMetrics:(UIBarMetrics)barMetrics {
    [self NavigationBarTransition_setBackgroundImage:backgroundImage forBarMetrics:barMetrics];
    if (self.transitionNavigationBar) {
        [self.transitionNavigationBar setBackgroundImage:backgroundImage forBarMetrics:barMetrics];
    }
}

static char transitionNavigationBarKey;
- (void)setTransitionNavigationBar:(UINavigationBar *)transitionNavigationBar {
    objc_setAssociatedObject(self, &transitionNavigationBarKey, transitionNavigationBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UINavigationBar *)transitionNavigationBar {
    return objc_getAssociatedObject(self, &transitionNavigationBarKey);
}

@end
