//
//  UIControl+Lee.m
//  LeeKit
//
//  Created by Lee on 2018/3/6.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "UIControl+Lee.h"
#import <objc/runtime.h>

static inline void ReplaceMethod(Class _class, SEL _originSelector, SEL _newSelector) {
    Method oriMethod = class_getInstanceMethod(_class, _originSelector);
    Method newMethod = class_getInstanceMethod(_class, _newSelector);
    BOOL isAddedMethod = class_addMethod(_class, _originSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (isAddedMethod) {
        class_replaceMethod(_class, _newSelector, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    } else {
        method_exchangeImplementations(oriMethod, newMethod);
    }
}

@interface UIControl ()

@property(nonatomic,assign) BOOL canSetHighlighted;
@property(nonatomic,assign) NSInteger touchEndCount;

@end

@implementation UIControl (Lee)

static char kAssociatedObjectKey_automaticallyAdjustTouchHighlightedInScrollView;
- (void)setLee_automaticallyAdjustTouchHighlightedInScrollView:(BOOL)lee_automaticallyAdjustTouchHighlightedInScrollView {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_automaticallyAdjustTouchHighlightedInScrollView, @(lee_automaticallyAdjustTouchHighlightedInScrollView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)lee_automaticallyAdjustTouchHighlightedInScrollView {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_automaticallyAdjustTouchHighlightedInScrollView)) boolValue];
}

static char kAssociatedObjectKey_canSetHighlighted;
- (void)setCanSetHighlighted:(BOOL)canSetHighlighted {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_canSetHighlighted, [NSNumber numberWithBool:canSetHighlighted], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)canSetHighlighted {
    return (BOOL)[objc_getAssociatedObject(self, &kAssociatedObjectKey_canSetHighlighted) boolValue];
}

static char kAssociatedObjectKey_touchEndCount;
- (void)setTouchEndCount:(NSInteger)touchEndCount {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_touchEndCount, @(touchEndCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)touchEndCount {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_touchEndCount) integerValue];
}

static char kAssociatedObjectKey_outsideEdge;
- (void)setLee_outsideEdge:(UIEdgeInsets)lee_outsideEdge {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_outsideEdge, [NSValue valueWithUIEdgeInsets:lee_outsideEdge], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIEdgeInsets)lee_outsideEdge {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_outsideEdge) UIEdgeInsetsValue];
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class clz = [self class];
        ReplaceMethod(clz, @selector(touchesBegan:withEvent:), @selector(lee_touchesBegan:withEvent:));
        ReplaceMethod(clz, @selector(touchesMoved:withEvent:), @selector(lee_touchesMoved:withEvent:));
        ReplaceMethod(clz, @selector(touchesCancelled:withEvent:), @selector(lee_touchesCancelled:withEvent:));
        ReplaceMethod(clz, @selector(touchesEnded:withEvent:), @selector(lee_touchesEnded:withEvent:));
        ReplaceMethod(clz, @selector(pointInside:withEvent:), @selector(lee_pointInside:withEvent:));
        ReplaceMethod(clz, @selector(setHighlighted:), @selector(lee_setHighlighted:));
    });
}

- (void)lee_setHighlighted:(BOOL)highlighted {
    [self lee_setHighlighted:highlighted];
    if (self.lee_setHighlightedBlock) {
        self.lee_setHighlightedBlock(highlighted);
    }
}

- (void)lee_touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.touchEndCount = 0;
    if (self.lee_automaticallyAdjustTouchHighlightedInScrollView) {
        self.canSetHighlighted = YES;
        [self lee_touchesBegan:touches withEvent:event];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.canSetHighlighted) {
                [self setHighlighted:YES];
            }
        });
    } else {
        [self lee_touchesBegan:touches withEvent:event];
    }
}

- (void)lee_touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.lee_automaticallyAdjustTouchHighlightedInScrollView) {
        self.canSetHighlighted = NO;
        [self lee_touchesMoved:touches withEvent:event];
    } else {
        [self lee_touchesMoved:touches withEvent:event];
    }
}

- (void)lee_touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.lee_automaticallyAdjustTouchHighlightedInScrollView) {
        self.canSetHighlighted = NO;
        if (self.touchInside) {
            [self setHighlighted:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 如果延迟时间太长，会导致快速点击两次，事件会触发两次
                // 对于 3D Touch 的机器，如果点击按钮的时候在按钮上停留事件稍微长一点点，那么 touchesEnded 会被调用两次
                // 把 super touchEnded 放到延迟里调用会导致长按无法触发点击，先这么改，再想想怎么办。// [self lee_touchesEnded:touches withEvent:event];
                [self sendActionsForAllTouchEventsIfCan];
                if (self.highlighted) {
                    [self setHighlighted:NO];
                }
            });
        } else {
            [self setHighlighted:NO];
        }
    } else {
        [self lee_touchesEnded:touches withEvent:event];
    }
}

- (void)lee_touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.lee_automaticallyAdjustTouchHighlightedInScrollView) {
        self.canSetHighlighted = NO;
        [self lee_touchesCancelled:touches withEvent:event];
        if (self.highlighted) {
            [self setHighlighted:NO];
        }
    } else {
        [self lee_touchesCancelled:touches withEvent:event];
    }
}

- (BOOL)lee_pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (([event type] != UIEventTypeTouches)) {
        return [self lee_pointInside:point withEvent:event];
    }
    UIEdgeInsets lee_outsideEdge = self.lee_outsideEdge;
    CGRect boundsInsetOutsideEdge = CGRectMake(CGRectGetMinX(self.bounds) + lee_outsideEdge.left, CGRectGetMinY(self.bounds) + lee_outsideEdge.top, CGRectGetWidth(self.bounds) - lee_outsideEdge.left - lee_outsideEdge.right, CGRectGetHeight(self.bounds) - lee_outsideEdge.top - lee_outsideEdge.bottom);
    return CGRectContainsPoint(boundsInsetOutsideEdge, point);
}

// 这段代码需要以一个独立的方法存在，因为一旦有坑，外面可以直接通过runtime调用这个方法
// 但，不要开放到.h文件里，理论上外面不应该用到它
- (void)sendActionsForAllTouchEventsIfCan {
    self.touchEndCount += 1;
    if (self.touchEndCount == 1) {
        [self sendActionsForControlEvents:UIControlEventAllTouchEvents];
    }
}

- (void)setLee_setHighlightedBlock:(void (^)(BOOL))lee_setHighlightedBlock {
    objc_setAssociatedObject(self, @selector(lee_setHighlightedBlock), lee_setHighlightedBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(BOOL))lee_setHighlightedBlock {
    return objc_getAssociatedObject(self, _cmd);
}

@end

