//
//  UITabBar+Lee.m
//  LeeKit
//
//  Created by Lee on 2018/3/7.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "UITabBar+Lee.h"
#import "UITabBarItem+Lee.h"
#import <objc/runtime.h>

static void inline ReplaceMethod(Class _class, SEL _originSelector, SEL _newSelector) {
    Method oriMethod = class_getInstanceMethod(_class, _originSelector);
    Method newMethod = class_getInstanceMethod(_class, _newSelector);
    BOOL isAddedMethod = class_addMethod(_class, _originSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (isAddedMethod) {
        class_replaceMethod(_class, _newSelector, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    } else {
        method_exchangeImplementations(oriMethod, newMethod);
    }
}

@interface UITabBar()

@property(nonatomic, assign) BOOL canItemRespondDoubleTouch;
@property(nonatomic, assign) NSInteger lastTouchedTabBarItemViewIndex;
@property(nonatomic, assign) NSInteger tabBarItemViewTouchCount;

@end

@implementation UITabBar (Lee)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ReplaceMethod([self class], @selector(setItems:animated:), @selector(lee_setItems:animated:));
        ReplaceMethod([self class], @selector(setSelectedItem:), @selector(lee_setSelectedItem:));
    });
}

-(void)lee_setItems:(NSArray<UITabBarItem *> *)items animated:(BOOL)animated{
    [self lee_setItems:items animated:animated];
    for (UITabBarItem *item in items) {
        UIControl *itemView = item.lee_barButton;
        [itemView addTarget:self action:@selector(handleTabBarItemViewEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)lee_setSelectedItem:(UITabBarItem *)selectedItem {
    NSInteger olderSelectedIndex = self.selectedItem ? [self.items indexOfObject:self.selectedItem] : -1;
    [self lee_setSelectedItem:selectedItem];
    NSInteger newerSelectedIndex = [self.items indexOfObject:selectedItem];
    // 只有双击当前正在显示的界面的 tabBarItem，才能正常触发双击事件
    self.canItemRespondDoubleTouch = olderSelectedIndex == newerSelectedIndex;
}

- (void)handleTabBarItemViewEvent:(UIControl *)itemView {
    //可能存在双击，继续下一步判断
    if (!self.canItemRespondDoubleTouch) {
        return;
    }
    if(!self.selectedItem.doubleTapBlock){
        return;
    }
    // 如果一定时间后仍未触发双击，则废弃当前的点击状态
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self revertTabBarItemTouch];
    });
    NSInteger selectedIndex = [self.items indexOfObject:self.selectedItem];
    //第一次点击
    if (self.lastTouchedTabBarItemViewIndex == -1) {
        self.lastTouchedTabBarItemViewIndex = selectedIndex;
    }else if (self.lastTouchedTabBarItemViewIndex != selectedIndex){
        //此时点击了别的item
        [self revertTabBarItemTouch];
        self.lastTouchedTabBarItemViewIndex = selectedIndex;
        return;
    }
    self.tabBarItemViewTouchCount++;
    if (self.tabBarItemViewTouchCount == 2) {
        // 第二次点击了相同的 tabBarItem，触发双击事件
        UITabBarItem *item = self.items[selectedIndex];
        if (item.doubleTapBlock) {
            item.doubleTapBlock(item, selectedIndex);
        }
        //响应事件以后马上复位
        [self revertTabBarItemTouch];
    }
}

-(void)revertTabBarItemTouch{
    self.lastTouchedTabBarItemViewIndex = -1;
    self.tabBarItemViewTouchCount = 0;
}


#pragma mark - Swizzle Property Getter/Setter

static char kAssociatedObjectKey_canItemRespondDoubleTouch;
- (void)setCanItemRespondDoubleTouch:(BOOL)canItemRespondDoubleTouch {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_canItemRespondDoubleTouch, @(canItemRespondDoubleTouch), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)canItemRespondDoubleTouch {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_canItemRespondDoubleTouch)) boolValue];
}

static char kAssociatedObjectKey_lastTouchedTabBarItemViewIndex;
- (void)setLastTouchedTabBarItemViewIndex:(NSInteger)lastTouchedTabBarItemViewIndex {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_lastTouchedTabBarItemViewIndex, @(lastTouchedTabBarItemViewIndex), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)lastTouchedTabBarItemViewIndex {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_lastTouchedTabBarItemViewIndex)) integerValue];
}

static char kAssociatedObjectKey_tabBarItemViewTouchCount;
- (void)setTabBarItemViewTouchCount:(NSInteger)tabBarItemViewTouchCount {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_tabBarItemViewTouchCount, @(tabBarItemViewTouchCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)tabBarItemViewTouchCount {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_tabBarItemViewTouchCount)) integerValue];
}


@end
