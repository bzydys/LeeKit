//
//  UIImage+corner.m
//  LeeKit
//
//  Created by Lee on 2018/2/20.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "UIImage+corner.h"
#import <objc/runtime.h>

@implementation UIImage (corner)

static char kAssociatedObjectKey_lee_borderColor;
- (void)setLee_borderColor:(UIColor *)lee_borderColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_lee_borderColor, lee_borderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)lee_borderColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_lee_borderColor);
}

static char kAssociatedObjectKey_lee_borderWidth;
- (void)setLee_borderWidth:(CGFloat)lee_borderWidth {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_lee_borderWidth, @(lee_borderWidth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)lee_borderWidth {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_lee_borderWidth)) floatValue];
}

static char kAssociatedObjectKey_lee_pathWidth;
- (void)setLee_pathWidth:(CGFloat)lee_pathWidth {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_lee_pathWidth, @(lee_pathWidth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)lee_pathWidth {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_lee_pathWidth)) floatValue];
}

static char kAssociatedObjectKey_lee_pathColor;
- (void)setLee_pathColor:(UIColor *)lee_pathColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_lee_pathColor, lee_pathColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)lee_pathColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_lee_pathColor);
}

-(UIImage *)lee_clipToSize:(CGSize)size{
    return [self lee_clipToSize:size shouldScale:YES];
}

-(UIImage *)lee_clipToSize:(CGSize)size shouldScale:(BOOL)scale{
    return [self lee_clipToSize:size cornerRadius:0 cornerType:UIRectCornerAllCorners backgroundColor:[UIColor whiteColor] shouldScale:scale isCircle:NO];
}

-(UIImage *)lee_clipToSize:(CGSize)size cornerRadius:(CGFloat)radius{
    return [self lee_clipToSize:size cornerRadius:radius backgroundColor:[UIColor whiteColor] shouldScale:YES];
}

-(UIImage *)lee_clipToSize:(CGSize)size cornerRadius:(CGFloat)radius backgroundColor:(UIColor *)backgroundColor shouldScale:(BOOL)scale{
    return [self lee_clipToSize:size cornerRadius:radius cornerType:UIRectCornerAllCorners backgroundColor:backgroundColor       shouldScale:scale isCircle:NO];
}

-(UIImage *)lee_clipToSize:(CGSize)size cornerRadius:(CGFloat)radius cornerType:(UIRectCorner)type backgroundColor:(UIColor *)backgroundColor shouldScale:(BOOL)scale{
    return [self lee_clipToSize:size cornerRadius:radius cornerType:type     backgroundColor:backgroundColor       shouldScale:scale isCircle:NO];
}

-(UIImage *)lee_clipToSize:(CGSize)size cornerRadius:(CGFloat)radius cornerType:(UIRectCorner)type{
    return [self lee_clipToSize:size cornerRadius:radius cornerType:type backgroundColor:[UIColor whiteColor] shouldScale:YES];
}

-(UIImage *)lee_clipCircleToSize:(CGSize)size backgroundColor:(UIColor *)backgroundColor shouldScale:(BOOL)scale{
    return [self lee_clipToSize:size cornerRadius:0 cornerType:UIRectCornerAllCorners     backgroundColor:backgroundColor       shouldScale:scale isCircle:YES];
}

-(UIImage *)lee_clipCircleToSize:(CGSize)size{
    return [self lee_clipCircleToSize:size backgroundColor:[UIColor whiteColor] shouldScale:YES];
}

+(UIImage *)lee_imageWithColor:(UIColor *)color size:(CGSize)size cornerRadius:(CGFloat)cornerRadius{
    return [self lee_imageWithColor:color size:size cornerRadius:cornerRadius backgroundColor:[UIColor whiteColor]];
}

+(UIImage *)lee_imageWithColor:(UIColor *)color size:(CGSize)size cornerRadius:(CGFloat)cornerRadius backgroundColor:(UIColor *)backgroundColor{
    return [self lee_imageWithColor:color size:size cornerRadius:cornerRadius backgroundColor:backgroundColor borderColor:nil borderWidth:0];
}

+(UIImage *)lee_imageWithColor:(UIColor *)color size:(CGSize)size cornerRadius:(CGFloat)cornerRadius backgroundColor:(UIColor *)backgroundColor borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth{
    //开启图行上下文
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    if (cornerRadius == 0) {
        if (borderWidth > 0) {
            CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
            CGContextSetLineWidth(context, borderWidth);
            CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
            CGContextStrokeRect(context, CGRectMake(borderWidth/2, borderWidth/2, size.width - borderWidth, size.height - borderWidth));
        }else{
            CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
        }
    }else{
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width, size.height) byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
        CGContextAddPath(context, path.CGPath);
        if (borderWidth > 0) {
            CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
            CGContextSetLineWidth(context, borderWidth);
            CGContextDrawPath(context, kCGPathFillStroke);
        }else{
            CGContextDrawPath(context, kCGPathFill);
        }
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+(UIImage *)lee_imageWithColor:(UIColor *)color size:(CGSize)size{
    return [self lee_imageWithColor:color size:size cornerRadius:0];
}

-(UIImage *)lee_clipToSize:(CGSize)size cornerRadius:(CGFloat)radius cornerType:(UIRectCorner)type backgroundColor:(UIColor *)backgroundColor shouldScale:(BOOL)scale isCircle:(BOOL)isCircle{
    if (size.width <=0 || size.height <= 0) {
        return self;
    }
    CGSize resultSize = size;
    if (scale) {
        CGFloat x = MAX(size.width/self.size.width, size.height/self.size.height);
        resultSize = CGSizeMake(x * self.size.width, x * self.size.height);
    }
    CGRect targetRect = (CGRect){0,0,resultSize.width,resultSize.height};
    if (isCircle) {
        CGFloat width = MIN(resultSize.width, resultSize.height);
        targetRect = CGRectMake(0, 0, width, width);
    }
    CGFloat pathWidth = self.lee_pathWidth;
    CGFloat borderWidth = self.lee_borderWidth;
    if (pathWidth > 0 && borderWidth > 0 && (isCircle || radius == 0)) {
        UIGraphicsBeginImageContext(targetRect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (backgroundColor) {
            CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
            CGContextFillRect(context, targetRect);
        }
        
        UIColor *borderColor = self.lee_borderColor;
        UIColor *pathColor = self.lee_pathColor;
        
        CGRect rect = targetRect;
        CGRect rectImage = rect;
        rectImage.origin.x += pathWidth;
        rectImage.origin.y += pathWidth;
        rectImage.size.width -= pathWidth * 2.0;
        rectImage.size.height -= pathWidth * 2.0;
        
        if (isCircle) {
            CGContextAddEllipseInRect(context, rect);
        }else{
            CGContextAddRect(context, rect);
        }
        CGContextClip(context);
        [self drawInRect:rectImage];
        
        // 添加内线和外线
        rectImage.origin.x -= borderWidth / 2.0;
        rectImage.origin.y -= borderWidth / 2.0;
        rectImage.size.width += borderWidth;
        rectImage.size.height += borderWidth;
        
        rect.origin.x += borderWidth / 2.0;
        rect.origin.y += borderWidth / 2.0;
        rect.size.width -= borderWidth;
        rect.size.height -= borderWidth;
        
        CGContextSetStrokeColorWithColor(context, [borderColor CGColor]);
        CGContextSetLineWidth(context, borderWidth);
        
        if (isCircle) {
            CGContextStrokeEllipseInRect(context, rectImage);
            CGContextStrokeEllipseInRect(context, rect);
        } else if (radius == 0) {
            CGContextStrokeRect(context, rectImage);
            CGContextStrokeRect(context, rect);
        }
        
        float centerPathWidth = pathWidth - borderWidth * 2.0;
        if (centerPathWidth > 0) {
            CGContextSetLineWidth(context, centerPathWidth);
            CGContextSetStrokeColorWithColor(context, [pathColor CGColor]);
            
            rectImage.origin.x -= borderWidth / 2.0 + centerPathWidth / 2.0;
            rectImage.origin.y -= borderWidth / 2.0 + centerPathWidth / 2.0;
            rectImage.size.width += borderWidth + centerPathWidth;
            rectImage.size.height += borderWidth + centerPathWidth;
            
            if (isCircle) {
                CGContextStrokeEllipseInRect(context, rectImage);
            } else if (radius == 0) {
                CGContextStrokeRect(context, rectImage);
            }
        }
    }else if (pathWidth > 0 && borderWidth > 0 && radius > 0 && !isCircle) {
        UIGraphicsBeginImageContextWithOptions(targetRect.size,
                                               backgroundColor != nil,
                                               [UIScreen mainScreen].scale);
        if (backgroundColor) {
            [backgroundColor setFill];
            CGContextFillRect(UIGraphicsGetCurrentContext(), targetRect);
        }
        
        UIColor *borderColor = self.lee_borderColor;
        UIColor *pathColor = self.lee_pathColor;
        
        CGRect rect = targetRect;
        CGRect rectImage = rect;
        rectImage.origin.x += pathWidth;
        rectImage.origin.y += pathWidth;
        rectImage.size.width -= pathWidth * 2.0;
        rectImage.size.height -= pathWidth * 2.0;
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        [self drawInRect:rectImage];
        
        // 添加内线和外线
        rectImage.origin.x -= borderWidth / 2.0;
        rectImage.origin.y -= borderWidth / 2.0;
        rectImage.size.width += borderWidth;
        rectImage.size.height += borderWidth;
        
        rect.origin.x += borderWidth / 2.0;
        rect.origin.y += borderWidth / 2.0;
        rect.size.width -= borderWidth;
        rect.size.height -= borderWidth;
        
        CGContextSetStrokeColorWithColor(ctx, [borderColor CGColor]);
        CGContextSetLineWidth(ctx, borderWidth);
        
        CGFloat minusPath1 = pathWidth / 2;
        UIBezierPath *path1 = [UIBezierPath bezierPathWithRoundedRect:rectImage byRoundingCorners:type cornerRadii:CGSizeMake(radius - minusPath1, radius - minusPath1)];
        CGContextAddPath(ctx, path1.CGPath);
        
        UIBezierPath *path2 = [UIBezierPath bezierPathWithRoundedRect:rect
                                                    byRoundingCorners:radius
                                                          cornerRadii:CGSizeMake(radius + minusPath1 ,radius + minusPath1)];
        CGContextAddPath(ctx, path2.CGPath);
        CGContextStrokePath(ctx);
        
        float centerPathWidth = pathWidth - borderWidth * 2.0;
        if (centerPathWidth > 0) {
            CGContextSetLineWidth(ctx, centerPathWidth);
            CGContextSetStrokeColorWithColor(ctx, [pathColor CGColor]);
            
            rectImage.origin.x -= borderWidth / 2.0 + centerPathWidth / 2.0;
            rectImage.origin.y -= borderWidth / 2.0 + centerPathWidth / 2.0;
            rectImage.size.width += borderWidth + centerPathWidth;
            rectImage.size.height += borderWidth + centerPathWidth;
            
            UIBezierPath *path3 = [UIBezierPath bezierPathWithRoundedRect:rectImage
                                                        byRoundingCorners:radius
                                                              cornerRadii:CGSizeMake(radius, radius)];
            CGContextAddPath(ctx, path3.CGPath);
            CGContextStrokePath(ctx);
        }
    } else if (pathWidth <= 0 && borderWidth > 0 && (radius > 0 || isCircle)) {
        UIColor *borderColor = self.lee_borderColor;
        
        CGRect rect = targetRect;
        CGRect rectImage = rect;
        rectImage.origin.x += borderWidth / 2;
        rectImage.origin.y += borderWidth / 2;
        rectImage.size.width -= borderWidth;
        rectImage.size.height -= borderWidth;
        
        UIImage *image = [self _lee_scaleToSize:rectImage.size backgroundColor:backgroundColor];
        UIGraphicsBeginImageContextWithOptions(targetRect.size,
                                               NO,
                                               [UIScreen mainScreen].scale);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithPatternImage:image].CGColor);
        
        UIBezierPath *path1 = nil;
        if (!isCircle) {
            CGFloat minusPath1 = borderWidth / 2;
            path1 = [UIBezierPath bezierPathWithRoundedRect:rectImage
                                          byRoundingCorners:type
                                                cornerRadii:CGSizeMake(radius - minusPath1, radius - minusPath1)];
        } else {
            path1 = [UIBezierPath bezierPathWithRoundedRect:rectImage
                                          byRoundingCorners:type cornerRadii:CGSizeMake(rectImage.size.width / 2, rectImage.size.width / 2)];
        }
        
        CGContextSetStrokeColorWithColor(ctx, [borderColor CGColor]);
        CGContextSetLineWidth(ctx, borderWidth);
        CGContextAddPath(ctx, path1.CGPath);
        CGContextDrawPath(ctx, kCGPathFillStroke);
    } else {
        UIGraphicsBeginImageContextWithOptions(targetRect.size,
                                               backgroundColor != nil,
                                               [UIScreen mainScreen].scale);
        if (backgroundColor) {
            [backgroundColor setFill];
            CGContextFillRect(UIGraphicsGetCurrentContext(), targetRect);
        }
        
        if (isCircle) {
            CGContextAddPath(UIGraphicsGetCurrentContext(),
                             [UIBezierPath bezierPathWithRoundedRect:targetRect
                                                        cornerRadius:targetRect.size.width / 2].CGPath);
            CGContextClip(UIGraphicsGetCurrentContext());
        } else if (radius > 0) {
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:targetRect
                                                       byRoundingCorners:type
                                                             cornerRadii:CGSizeMake(radius, radius)];
            CGContextAddPath(UIGraphicsGetCurrentContext(), path.CGPath);
            CGContextClip(UIGraphicsGetCurrentContext());
        }
        
        [self drawInRect:targetRect];
    }
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return finalImage;
    
}

- (UIImage *)_lee_scaleToSize:(CGSize)size backgroundColor:(UIColor *)backgroundColor {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);
    
    if (backgroundColor) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
        CGContextAddRect(context, rect);
        CGContextDrawPath(context, kCGPathFillStroke); //根据坐标绘制路径
    }
    
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

@end
