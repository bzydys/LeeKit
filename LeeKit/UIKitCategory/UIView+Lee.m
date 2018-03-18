//
//  UIView+Lee.m
//  LeeKit
//
//  Created by Lee on 2018/3/8.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "UIView+Lee.h"
#import <objc/runtime.h>
#import "UIImage+Lee.h"

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

@implementation UIView (Lee)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ReplaceMethod([self class], @selector(initWithFrame:), @selector(lee_initWithFrame:));
        ReplaceMethod([self class], @selector(initWithCoder:), @selector(lee_initWithCoder:));
        ReplaceMethod([self class], @selector(layoutSublayersOfLayer:), @selector(lee_layoutSublayersOfLayer:));
    });
}

-(instancetype)lee_initWithFrame:(CGRect)frame{
    [self lee_initWithFrame:frame];
    [self setDefaultStyle];
    return self;
}

- (instancetype)lee_initWithCoder:(NSCoder *)aDecoder {
    [self lee_initWithCoder:aDecoder];
    [self setDefaultStyle];
    return self;
}

-(void)lee_layoutSublayersOfLayer:(CALayer *)layer{
    [self lee_layoutSublayersOfLayer:layer];
    if ((!self.lee_borderLayer && self.lee_borderPosition == LeeBorderViewPositionNone) || (!self.lee_borderLayer && self.lee_borderWidth == 0)) {
        return;
    }
    
    if (self.lee_borderLayer && self.lee_borderPosition == LeeBorderViewPositionNone && !self.lee_borderLayer.path) {
        return;
    }
    
    if (self.lee_borderLayer && self.lee_borderWidth == 0 && self.lee_borderLayer.lineWidth == 0) {
        return;
    }
    
    if (!self.lee_borderLayer) {
        self.lee_borderLayer = [CAShapeLayer layer];
        [self.layer addSublayer:self.lee_borderLayer];
    }
    
    self.lee_borderLayer.frame = self.bounds;
    
    CGFloat borderWidth = self.lee_borderWidth;
    self.lee_borderLayer.lineWidth = borderWidth;
    self.lee_borderLayer.strokeColor = self.lee_borderColor.CGColor;
    self.lee_borderLayer.lineDashPhase = self.lee_dashPhase;
    if (self.lee_dashPattern) {
        self.lee_borderLayer.lineDashPattern = self.lee_dashPattern;
    }
    
    UIBezierPath *path = nil;
    if (self.lee_borderPosition != LeeBorderViewPositionNone) {
        path = [UIBezierPath bezierPath];
    }
    
    if (self.lee_borderPosition & LeeBorderViewPositionTop) {
        [path moveToPoint:CGPointMake(0, borderWidth / 2)];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds), borderWidth / 2)];
    }
    
    if (self.lee_borderPosition & LeeBorderViewPositionLeft) {
        [path moveToPoint:CGPointMake(borderWidth / 2, 0)];
        [path addLineToPoint:CGPointMake(borderWidth / 2, CGRectGetHeight(self.bounds) - 0)];
    }
    
    if (self.lee_borderPosition & LeeBorderViewPositionBottom) {
        [path moveToPoint:CGPointMake(0, CGRectGetHeight(self.bounds) - borderWidth / 2)];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - borderWidth / 2)];
    }
    
    if (self.lee_borderPosition & LeeBorderViewPositionRight) {
        [path moveToPoint:CGPointMake(CGRectGetWidth(self.bounds) - borderWidth / 2, 0)];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) - borderWidth / 2, CGRectGetHeight(self.bounds))];
    }
    
    self.lee_borderLayer.path = path.CGPath;
}

- (void)setDefaultStyle {
    self.lee_borderWidth = 1;
    self.lee_borderColor = [UIColor colorWithRed:222/255.0 green:224/255.0 blue:226/255.0 alpha:1];
}

static char kAssociatedObjectKey_borderPosition;
- (void)setLee_borderPosition:(LeeBorderViewPosition)lee_borderPosition {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderPosition, @(lee_borderPosition), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (LeeBorderViewPosition)lee_borderPosition {
    return (LeeBorderViewPosition)[objc_getAssociatedObject(self, &kAssociatedObjectKey_borderPosition) unsignedIntegerValue];
}

static char kAssociatedObjectKey_borderWidth;
- (void)setLee_borderWidth:(CGFloat)lee_borderWidth {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderWidth, @(lee_borderWidth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (CGFloat)lee_borderWidth {
    return (CGFloat)[objc_getAssociatedObject(self, &kAssociatedObjectKey_borderWidth) floatValue];
}

static char kAssociatedObjectKey_borderColor;
- (void)setLee_borderColor:(UIColor *)lee_borderColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderColor, lee_borderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (UIColor *)lee_borderColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_borderColor);
}

static char kAssociatedObjectKey_dashPhase;
- (void)setLee_dashPhase:(CGFloat)lee_dashPhase {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_dashPhase, @(lee_dashPhase), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (CGFloat)lee_dashPhase {
    return (CGFloat)[objc_getAssociatedObject(self, &kAssociatedObjectKey_dashPhase) floatValue];
}

static char kAssociatedObjectKey_dashPattern;
- (void)setLee_dashPattern:(NSArray<NSNumber *> *)lee_dashPattern {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_dashPattern, lee_dashPattern, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (NSArray *)lee_dashPattern {
    return (NSArray<NSNumber *> *)objc_getAssociatedObject(self, &kAssociatedObjectKey_dashPattern);
}

static char kAssociatedObjectKey_borderLayer;
- (void)setLee_borderLayer:(CAShapeLayer *)lee_borderLayer {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderLayer, lee_borderLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CAShapeLayer *)lee_borderLayer {
    return (CAShapeLayer *)objc_getAssociatedObject(self, &kAssociatedObjectKey_borderLayer);
}

@end


@implementation UIView (Lee_Layout)

-(CGFloat)lee_top{
    return CGRectGetMinY(self.frame);
}

-(void)setLee_top:(CGFloat)lee_top{
    CGRect rect = self.frame;
    rect.origin.y = lee_top;
    self.frame = rect;
}

-(CGFloat)lee_left{
    return CGRectGetMinX(self.frame);
}

-(void)setLee_left:(CGFloat)lee_left{
    CGRect rect = self.frame;
    rect.origin.x = lee_left;
    self.frame = rect;
}

-(CGFloat)lee_bottom{
    return CGRectGetMaxY(self.frame);
}

-(void)setLee_bottom:(CGFloat)lee_bottom{
    CGRect rect = self.frame;
    rect.origin.y = lee_bottom - CGRectGetHeight(self.frame);
    self.frame = rect;
}

-(CGFloat)lee_right{
    return CGRectGetMaxX(self.frame);
}

-(void)setLee_right:(CGFloat)lee_right{
    CGRect rect = self.frame;
    rect.origin.x = lee_right - CGRectGetWidth(self.frame);
    self.frame = rect;
}

-(CGFloat)lee_width{
    return CGRectGetWidth(self.frame);
}

-(void)setLee_width:(CGFloat)lee_width{
    CGRect rect = self.frame;
    rect.size.width = lee_width;
    self.frame = rect;
}

-(CGFloat)lee_height{
    return CGRectGetHeight(self.frame);
}

-(void)setLee_height:(CGFloat)lee_height{
    CGRect rect = self.frame;
    rect.size.height = lee_height;
    self.frame = rect;
}

-(CGFloat)lee_leftWhenCenterInSuperview{
    return (CGRectGetWidth(self.superview.bounds) - CGRectGetWidth(self.frame))/2.0;
}

-(CGFloat)lee_topWhenCenterInSuperview{
    return (CGRectGetHeight(self.superview.bounds) - CGRectGetHeight(self.frame))/2.0;
}

@end

@implementation UIView (Lee_Snapshotting)

- (UIImage *)lee_snapshotLayerImage {
    return [UIImage lee_imageWithView:self];
}

- (UIImage *)lee_snapshotImageAfterScreenUpdates:(BOOL)afterScreenUpdates {
    return [UIImage lee_imageWithView:self afterScreenUpdates:afterScreenUpdates];
}

@end
