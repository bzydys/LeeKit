//
//  UIView+corner.m
//  LeeKit
//
//  Created by Lee on 2018/2/26.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "UIView+corner.h"
#import "ImageClipedManager.h"
#import <objc/message.h>
#import "UIImage+corner.h"

@interface _CornerImage : NSObject

@property (nonatomic, strong) UIImage *leftUpImage;
@property (nonatomic, strong) UIImage *leftDownImage;
@property (nonatomic, strong) UIImage *rightUpImage;
@property (nonatomic, strong) UIImage *rightDownImage;

@end

@implementation _CornerImage

@end

@interface _CornerImageView : UIImageView

@end

@implementation _CornerImageView

@end

@interface _CornerBorderLayer : CAShapeLayer

@end

@implementation _CornerBorderLayer

@end

@interface ImageClipedManager (CornerImages)


@end

@implementation ImageClipedManager (CornerImages)

- (NSCache *)lee_sharedCornerImages {
    return [ImageClipedManager shared].sharedCache;
}

- (NSString *)lee_hashKeyWithColor:(UIColor *)color radius:(CGFloat)radius border:(CGFloat)border borderColor:(UIColor *)borderColor targetSize:(CGSize)targetSize {
    const CGFloat *colors = CGColorGetComponents(color.CGColor);
    NSUInteger count = CGColorGetNumberOfComponents(color.CGColor);
    
    NSMutableString *hashStr = [NSMutableString string];
    
    for (NSUInteger index = 0; index < count; index ++) {
        [hashStr appendString:[NSString stringWithFormat:@"%@", @(colors[index])]];
    }
    
    if (borderColor) {
        const CGFloat *colors = CGColorGetComponents(borderColor.CGColor);
        NSUInteger count = CGColorGetNumberOfComponents(borderColor.CGColor);
        
        for (NSUInteger index = 0; index < count; index ++) {
            [hashStr appendString:[NSString stringWithFormat:@"%@", @(colors[index])]];
        }
    }
    
    [hashStr appendString:[NSString stringWithFormat:@"%@", @(radius)]];
    [hashStr appendString:[NSString stringWithFormat:@"%@", @(border)]];
    
    if (targetSize.width > 0) {
        [hashStr appendString:[NSString stringWithFormat:@"%@", @(targetSize.width)]];
    }
    
    if (targetSize.height > 0) {
        [hashStr appendString:[NSString stringWithFormat:@"%@", @(targetSize.height)]];
    }
    
    return [NSString stringWithFormat:@"%@", @([hashStr hash])];
}


- (NSString *)lee_hashKeyWithColor:(UIColor *)color
                            radius:(CGFloat)radius
                            border:(CGFloat)border
                        targetSize:(CGSize)targetSize {
    return [self lee_hashKeyWithColor:color
                               radius:radius
                               border:border
                          borderColor:nil
                           targetSize:targetSize];
}

- (_CornerImage *)lee_cornerImageWithColor:(UIColor *)color
                                       radius:(CGFloat)radius
                                       border:(CGFloat)border
                                   targetSize:(CGSize)targetSize {
    NSString *key = [[ImageClipedManager shared] lee_hashKeyWithColor:color
                                                                  radius:radius
                                                                  border:border
                                                              targetSize:targetSize];
    
    _CornerImage *image = [[[ImageClipedManager shared] lee_sharedCornerImages] objectForKey:key];
    
    if (image == nil) {
        UIImage *cornerImage = nil;
        
        radius *= [UIScreen mainScreen].scale;
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef contextRef = CGBitmapContextCreate(NULL,
                                                        radius,
                                                        radius,
                                                        8,
                                                        4 * radius,
                                                        colorSpace,
                                                        kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrderDefault);
        
        if (contextRef) {
            CGContextSetFillColorWithColor(contextRef, color.CGColor);
            CGContextMoveToPoint(contextRef, radius, 0);
            CGContextAddLineToPoint(contextRef, 0, 0);
            CGContextAddLineToPoint(contextRef, 0, radius);
            CGContextAddArc(contextRef,
                            radius,
                            radius,
                            radius,
                            180 * (M_PI / 180.0f),
                            270 * (M_PI / 180.0f),
                            0);
            
            CGContextFillPath(contextRef);
            
            CGImageRef imageCG = CGBitmapContextCreateImage(contextRef);
            cornerImage = [UIImage imageWithCGImage:imageCG];
            
            CGContextRelease(contextRef);
            CGColorSpaceRelease(colorSpace);
            CGImageRelease(imageCG);
            
            CGImageRef imageRef = cornerImage.CGImage;
            
            UIImage *leftUpImage = [[UIImage alloc] initWithCGImage:imageRef
                                                              scale:[UIScreen mainScreen].scale
                                                        orientation:UIImageOrientationRight];
            UIImage *rightUpImage = [[UIImage alloc] initWithCGImage:imageRef
                                                               scale:[UIScreen mainScreen].scale
                                                         orientation:UIImageOrientationLeftMirrored];
            UIImage *rightDownImage = [[UIImage alloc] initWithCGImage:imageRef
                                                                 scale:[UIScreen mainScreen].scale
                                                           orientation:UIImageOrientationLeft];
            UIImage *leftDownImage = [[UIImage alloc] initWithCGImage:imageRef
                                                                scale:[UIScreen mainScreen].scale
                                                          orientation:UIImageOrientationUp];
            
            image = [[_CornerImage alloc] init];
            image.leftDownImage = leftDownImage;
            image.leftUpImage = leftUpImage;
            image.rightUpImage = rightUpImage;
            image.rightDownImage = rightDownImage;
            
            [[[ImageClipedManager shared] lee_sharedCornerImages] setObject:image forKey:key];
        }
    }
    
    return image;
}

@end

static const char *s_image_borderColorKey = "s_image_borderColorKey";
static const char *s_image_borderWidthKey = "s_image_borderWidthKey";
static const char *s_image_pathColorKey = "s_image_pathColorKey";
static const char *s_image_pathWidthKey = "s_image_pathWidthKey";
static const char *s_image_shouldRefreshCache = "s_image_shouldRefreshCache";

@implementation UIView (HYBImageCliped)

- (BOOL)shouldRefreshCache {
    NSNumber *shouldRefresh = objc_getAssociatedObject(self, s_image_shouldRefreshCache);
    
    if ([shouldRefresh respondsToSelector:@selector(boolValue)]) {
        return shouldRefresh.boolValue;
    }
    
    return NO;
}

- (void)setShouldRefreshCache:(BOOL)shouldRefreshCache {
    objc_setAssociatedObject(self,
                             s_image_shouldRefreshCache,
                             @(shouldRefreshCache),
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Border
- (CGFloat)lee_borderWidth {
    NSNumber *borderWidth = objc_getAssociatedObject(self, s_image_borderWidthKey);
    
    if ([borderWidth respondsToSelector:@selector(doubleValue)]) {
        return borderWidth.floatValue;
    }
    
    return 0;
}

- (void)setLee_borderWidth:(CGFloat)lee_borderWidth {
    objc_setAssociatedObject(self,
                             s_image_borderWidthKey,
                             @(lee_borderWidth),
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)lee_pathWidth {
    NSNumber *width = objc_getAssociatedObject(self, s_image_pathWidthKey);
    
    if ([width respondsToSelector:@selector(doubleValue)]) {
        return width.floatValue;
    }
    
    return 0;
}

- (void)setLee_pathWidth:(CGFloat)lee_pathWidth {
    objc_setAssociatedObject(self,
                             s_image_pathWidthKey,
                             @(lee_pathWidth),
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)lee_pathColor {
    UIColor *color = objc_getAssociatedObject(self, s_image_pathColorKey);
    
    if (color) {
        return color;
    }
    
    return [UIColor whiteColor];
}

- (void)setLee_pathColor:(UIColor *)lee_pathColor {
    objc_setAssociatedObject(self,
                             s_image_pathColorKey,
                             lee_pathColor,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (UIColor *)lee_borderColor {
    UIColor *color = objc_getAssociatedObject(self, s_image_borderColorKey);
    
    if (color) {
        return color;
    }
    
    return [UIColor lightGrayColor];
}

- (void)setLee_borderColor:(UIColor *)lee_borderColor {
    objc_setAssociatedObject(self,
                             s_image_borderColorKey,
                             lee_borderColor,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)lee_addCorner:(UIRectCorner)corner cornerRadius:(CGFloat)cornerRadius size:(CGSize)targetSize {
    [self lee_addCorner:corner cornerRadius:cornerRadius size:targetSize backgroundColor:nil];
}

- (void)lee_addCorner:(UIRectCorner)corner cornerRadius:(CGFloat)cornerRadius size:(CGSize)targetSize backgroundColor:(UIColor *)backgroundColor {
    NSDictionary *dict = @{@"corner" : @(corner),
                           @"cornerRadius" : @(cornerRadius),
                           @"backgroundColor": backgroundColor ?: [UIColor clearColor]};
    // 解决中文label添加圆角及边框出现奇怪现象的问题
    if ([self isKindOfClass:[UILabel class]]) {
        self.layer.masksToBounds = YES;
    }
    
    // 增加autolayout支持
    if (targetSize.width <= 0 || targetSize.height <= 0) {
        [self setNeedsLayout];
        [self performSelector:@selector(_private_addConnerWithDict:)
                   withObject:dict
                   afterDelay:0
                      inModes:@[NSRunLoopCommonModes]];
    } else {
        [self _private_addConnerWithDict:dict targetSize:targetSize];
    }
}

- (void)_private_addConnerWithDict:(NSDictionary *)dict {
    [self _private_addConnerWithDict:dict targetSize:self.bounds.size];
}

- (void)_private_addConnerWithDict:(NSDictionary *)dict targetSize:(CGSize)targetSize {
    if (targetSize.width <= 0 || targetSize.height <= 0) {
        NSLog(@"您未指定targetSize，且未能通过autolayout来获取到targetSize！");
        return;
    }
    
    UIRectCorner corner = [dict[@"corner"] integerValue];
    CGFloat cornerRadius = [dict[@"cornerRadius"] floatValue];
    UIColor *backgroundColor = dict[@"backgroundColor"];
    if (corner == UIRectCornerAllCorners && (self.lee_borderWidth > 0 || cornerRadius > 0)
        && ![self isKindOfClass:[UIImageView class]]) {
        // 缓存起来，这样性能提升很多
        NSString *lastKey = [self lee_lastBorderImageKey];
        ImageClipedManager *manager = [ImageClipedManager shared];
        NSString *key = [manager lee_hashKeyWithColor:self.backgroundColor
                                               radius:cornerRadius
                                               border:self.lee_borderWidth
                                          borderColor:self.lee_borderColor
                                           targetSize:targetSize];
        
        if (self.shouldRefreshCache || lastKey == nil || ![lastKey isEqualToString:key]) {
            UIColor *bgColor = [self _private_color:backgroundColor];
            UIImage *image = [UIImage lee_imageWithColor:self.backgroundColor
                                                  size:targetSize
                                            cornerRadius:cornerRadius
                                         backgroundColor:bgColor
                                             borderColor:self.lee_borderColor
                                             borderWidth:self.lee_borderWidth];
            self.backgroundColor = [UIColor colorWithPatternImage:image];
            [self setLee_lastBorderImageKey:key];
        }
    } else {
        __block _CornerBorderLayer *borderLayer = nil;
        [self.layer.sublayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[_CornerBorderLayer class]]) {
                borderLayer = (_CornerBorderLayer *)obj;
                *stop = YES;
            }
        }];
        
        // 当Frame发生变化时，也会自动移除
        if ((self.shouldRefreshCache && borderLayer != nil)
            || (borderLayer && !CGSizeEqualToSize(borderLayer.bounds.size, targetSize))
            || (borderLayer && CGColorEqualToColor(borderLayer.strokeColor, self.lee_borderColor.CGColor))
            || (borderLayer && (self.lee_borderWidth - borderLayer.lineWidth) >= 0.000001)) {
            [borderLayer removeFromSuperlayer];
            
            for (NSUInteger i = 0; i < self.subviews.count; ++i) {
                UIView *subView = [self.subviews objectAtIndex:i];
                if ([subView isKindOfClass:[_CornerImageView class]]) {
                    [subView removeFromSuperview];
                }
            }
        } else if (borderLayer && !self.shouldRefreshCache) {
            return;
        }
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                   byRoundingCorners:corner
                                                         cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
        borderLayer = [_CornerBorderLayer layer];
        borderLayer.path = path.CGPath;
        borderLayer.lineWidth = self.lee_borderWidth;
        borderLayer.strokeColor = self.lee_borderColor.CGColor;
        borderLayer.fillColor = [UIColor clearColor].CGColor;
        borderLayer.frame = self.bounds;
        [self.layer addSublayer:borderLayer];
        
        UIColor *bgColor = [self _private_color:backgroundColor];
        [self _lee_addCornerImages:corner
                            radius:cornerRadius
                              size:targetSize
                             color:bgColor];
    }
}

- (UIColor *)_private_color:(UIColor *)backgroundColor {
    UIColor *bgColor = nil;
    if (backgroundColor == nil || CGColorEqualToColor(backgroundColor.CGColor, [UIColor clearColor].CGColor)) {
        UIView *superview = self.superview;
        while (superview.backgroundColor == nil || CGColorEqualToColor(superview.backgroundColor.CGColor, [UIColor clearColor].CGColor)) {
            if (!superview) {
                break;
            }
            
            superview = [superview superview];
        }
        
        bgColor = superview.backgroundColor;
    } else {
        bgColor = backgroundColor;
    }
    
    if (bgColor == nil) {
        bgColor = self.backgroundColor;
    }
    
    if (CGColorEqualToColor(bgColor.CGColor, [UIColor clearColor].CGColor)) {
        bgColor = [UIColor whiteColor];
    }
    
    return bgColor;
}

- (void)lee_addCorner:(UIRectCorner)corner cornerRadius:(CGFloat)cornerRadius backgroundColor:(UIColor *)backgroundColor {
    [self lee_addCorner:UIRectCornerAllCorners cornerRadius:cornerRadius size:self.bounds.size backgroundColor:backgroundColor];
}

- (void)lee_addCorner:(UIRectCorner)corner cornerRadius:(CGFloat)cornerRadius {
    [self lee_addCorner:corner cornerRadius:cornerRadius size:self.bounds.size];
}

- (void)lee_addCornerRadius:(CGFloat)cornerRadius size:(CGSize)targetSize {
    [self lee_addCorner:UIRectCornerAllCorners cornerRadius:cornerRadius size:targetSize];
}

- (void)lee_addCornerRadius:(CGFloat)cornerRadius {
    [self lee_addCorner:UIRectCornerAllCorners cornerRadius:cornerRadius];
}

- (UIImage *)lee_setImage:(id)image size:(CGSize)targetSize isEqualScale:(BOOL)isEqualScale onCliped:(Callback)callback {
    return [self lee_private_setImage:image
                                 size:targetSize
                         cornerRadius:0
                          rectCorener:UIRectCornerAllCorners
                      backgroundColor:nil
                         isEqualScale:isEqualScale
                             isCircle:NO
                             onCliped:callback];
}

- (UIImage *)lee_setImage:(id)image isEqualScale:(BOOL)isEqualScale onCliped:(Callback)callback {
    return [self lee_setImage:image size:self.frame.size isEqualScale:isEqualScale onCliped:callback];
}

- (UIImage *)lee_setCircleImage:(id)image
                           size:(CGSize)targetSize
                   isEqualScale:(BOOL)isEqualScale
                 backgrounColor:(UIColor *)backgroundColor
                       onCliped:(Callback)callback {
    return [self lee_private_setImage:image
                                 size:targetSize
                         cornerRadius:0
                          rectCorener:UIRectCornerAllCorners
                      backgroundColor:backgroundColor
                         isEqualScale:isEqualScale
                             isCircle:YES
                             onCliped:callback];
}

- (UIImage *)lee_setCircleImage:(id)image size:(CGSize)targetSize isEqualScale:(BOOL)isEqualScale onCliped:(Callback)callback {
    return [self lee_private_setImage:image
                                 size:targetSize
                         cornerRadius:0
                          rectCorener:UIRectCornerAllCorners
                      backgroundColor:nil
                         isEqualScale:isEqualScale
                             isCircle:YES
                             onCliped:callback];
}

- (UIImage *)lee_setCircleImage:(id)image isEqualScale:(BOOL)isEqualScale onCliped:(Callback)callback {
    return [self lee_setCircleImage:image size:self.frame.size isEqualScale:isEqualScale onCliped:callback];
}

- (UIImage *)lee_setImage:(id)image
                     size:(CGSize)targetSize
             cornerRadius:(CGFloat)cornerRaidus
          backgroundColor:(UIColor *)backgroundColor
             isEqualScale:(BOOL)isEqualScale
                 onCliped:(Callback)callback {
    return [self lee_setImage:image
                         size:targetSize
                 cornerRadius:cornerRaidus
                   rectCorner:UIRectCornerAllCorners
              backgroundColor:backgroundColor
                 isEqualScale:isEqualScale
                     onCliped:callback];
}

- (UIImage *)lee_setImage:(id)image
                     size:(CGSize)targetSize
             cornerRadius:(CGFloat)cornerRaidus
                 onCliped:(Callback)callback {
    return [self lee_setImage:image
                         size:targetSize
                 cornerRadius:cornerRaidus
              backgroundColor:nil
                 isEqualScale:YES
                     onCliped:callback];
}

- (UIImage *)lee_setImage:(id)image
             cornerRadius:(CGFloat)cornerRaidus onCliped:(Callback)callback {
    return [self lee_setImage:image size:self.frame.size cornerRadius:cornerRaidus onCliped:callback];
}

- (UIImage *)lee_setImage:(id)image
                     size:(CGSize)targetSize
             cornerRadius:(CGFloat)cornerRaidus
               rectCorner:(UIRectCorner)rectCorner
          backgroundColor:(UIColor *)backgroundColor
             isEqualScale:(BOOL)isEqualScale
                 onCliped:(Callback)callback {
    return [self lee_private_setImage:image
                                 size:targetSize
                         cornerRadius:cornerRaidus
                          rectCorener:rectCorner
                      backgroundColor:backgroundColor
                         isEqualScale:isEqualScale
                             isCircle:NO
                             onCliped:callback];
}

- (UIImage *)lee_setImage:(id)image
             cornerRadius:(CGFloat)cornerRaidus
               rectCorner:(UIRectCorner)rectCorner
             isEqualScale:(BOOL)isEqualScale
                 onCliped:(Callback)callback {
    return [self lee_private_setImage:image
                                 size:self.frame.size
                         cornerRadius:cornerRaidus
                          rectCorener:rectCorner
                      backgroundColor:nil
                         isEqualScale:isEqualScale
                             isCircle:NO
                             onCliped:callback];
}

- (UIImage *)lee_setImage:(id)image
                     size:(CGSize)targetSize
             cornerRadius:(CGFloat)cornerRaidus
               rectCorner:(UIRectCorner)rectCorner
                 onCliped:(Callback)callback {
    return [self lee_setImage:image
                         size:targetSize
                 cornerRadius:cornerRaidus
                   rectCorner:rectCorner
              backgroundColor:nil
                 isEqualScale:YES
                     onCliped:callback];
}

- (UIImage *)lee_setImage:(id)image
             cornerRadius:(CGFloat)cornerRaidus
               rectCorner:(UIRectCorner)rectCorner
                 onCliped:(Callback)callback {
    return [self lee_setImage:image
                         size:self.frame.size
                 cornerRadius:cornerRaidus
                   rectCorner:rectCorner
                     onCliped:callback];
}

#pragma makr - Private
- (UIImage *)lee_private_setImage:(id)image
                             size:(CGSize)targetSize
                     cornerRadius:(CGFloat)cornerRadius
                      rectCorener:(UIRectCorner)rectCorner
                  backgroundColor:(UIColor *)bgColor
                     isEqualScale:(BOOL)isEqualScale
                         isCircle:(BOOL)isCircle
                         onCliped:(Callback)callback {
    if (image == nil) {
        return nil;
    }
    
    if (bgColor == nil || CGColorEqualToColor(bgColor.CGColor, [UIColor clearColor].CGColor)) {
        UIView *superview = self.superview;
        while (superview.backgroundColor == nil || CGColorEqualToColor(superview.backgroundColor.CGColor, [UIColor clearColor].CGColor)) {
            if (!superview) {
                break;
            }
            
            superview = [superview superview];
        }
        
        bgColor = superview.backgroundColor;
    }
    
    if (bgColor == nil || CGColorEqualToColor(bgColor.CGColor, [UIColor clearColor].CGColor)) {
        bgColor = [UIColor whiteColor];
    }
    
    UIImage *willBeClipedImage = image;
    if ([image isKindOfClass:[NSString class]]) {
        willBeClipedImage = [UIImage imageNamed:image];
    } else if ([image isKindOfClass:[UIImage class]]) {
        willBeClipedImage = image;
    } else if ([image isKindOfClass:[NSData class]]) {
        willBeClipedImage = [UIImage imageWithData:image];
    }
    
    if (willBeClipedImage == nil) {
        return nil;
    }
    
    NSDictionary *tempDict = @{@"rectCorner" : @(rectCorner),
                               @"willBeClipedImage" : willBeClipedImage,
                               @"cornerRadius" : @(cornerRadius),
                               @"bgColor" : bgColor,
                               @"isEqualScale" : @(isEqualScale),
                               @"isCircle" : @(isCircle)};
    NSMutableDictionary *dict = [tempDict mutableCopy];
    if (callback) {
        [dict setObject:callback forKey:@"callback"];
    }
    
    if (targetSize.width <= 0 || targetSize.height <= 0) {
        [self setNeedsLayout];
        
        [self performSelector:@selector(_private_clipImagWithDict:)
                   withObject:dict
                   afterDelay:0
                      inModes:@[NSRunLoopCommonModes]];
    } else {
        [self _private_clipImagWithDict:dict targetSize:targetSize];
    }
    
    return willBeClipedImage;
}

- (void)_private_clipImagWithDict:(NSDictionary *)dict {
    [self _private_clipImagWithDict:dict targetSize:self.bounds.size];
}

- (void)_private_clipImagWithDict:(NSDictionary *)dict targetSize:(CGSize)targetSize {
    if (targetSize.width <= 0 || targetSize.height <= 0) {
        NSLog(@"未能在自动布局之后取到targetSize，所以无法添加圆角");
        return;
    }
    
    UIRectCorner rectCorner = [dict[@"rectCorner"] integerValue];
    UIImage *willBeClipedImage = dict[@"willBeClipedImage"];
    CGFloat cornerRadius = [dict[@"cornerRadius"] floatValue];
    UIColor *bgColor = dict[@"bgColor"];
    BOOL isEqualScale = [dict[@"isEqualScale"] boolValue];
    BOOL isCircle = [dict[@"isCircle"] boolValue];
    
    Callback callback = nil;
    if (dict[@"callback"] != nil) {
        callback = dict[@"callback"];
    }
    
    __block UIImage *clipedImage = nil;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        willBeClipedImage.lee_pathColor = self.lee_pathColor;
        willBeClipedImage.lee_pathWidth = self.lee_pathWidth;
        willBeClipedImage.lee_borderColor = self.lee_borderColor;
        willBeClipedImage.lee_borderWidth = self.lee_borderWidth;
        
        @autoreleasepool {
            clipedImage = [willBeClipedImage lee_clipToSize:targetSize
                                               cornerRadius:cornerRadius
                                                    cornerType:rectCorner
                                            backgroundColor:bgColor
                                               shouldScale:isEqualScale
                                                   isCircle:isCircle];
            
            [self _private_updateContentInMainThread:clipedImage callback:callback];
        }
    });
}

- (void)_private_updateContentInMainThread:(UIImage *)clipedImage callback:(Callback)callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (clipedImage) {
            if ([self isKindOfClass:[UIImageView class]]) {
                UIImageView *imgView = (UIImageView *)self;
                imgView.image = clipedImage;
            } else if ([self isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)self;
                [button setImage:clipedImage forState:UIControlStateNormal];
            } else {
                self.layer.contents = (__bridge id _Nullable)(clipedImage.CGImage);
            }
            
            if (callback) {
                callback(clipedImage);
            }
        }
    });
}

- (void)_lee_addCornerImages:(UIRectCorner)corners radius:(CGFloat)radius size:(CGSize)targetSize color:(UIColor *)color {
    if ([self lee_hasAddEmpty]) {
        return;
    }
    
    CGFloat value1 = targetSize.width - radius / 2.0;
    CGFloat value2 = radius / 2.0;
    CGFloat value3 = targetSize.height - radius / 2.0;
    
    ImageClipedManager *manager = [ImageClipedManager shared];
    _CornerImage *image = [manager lee_cornerImageWithColor:color
                                                        radius:radius
                                                        border:self.lee_borderWidth
                                                    targetSize:targetSize];
    if (image == nil) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL shouldAdd = NO;
        
        if (corners & UIRectCornerTopLeft && image.leftUpImage) {
            _CornerImageView *leftUpImageView = [[_CornerImageView alloc] initWithFrame:CGRectMake(0, 0, radius, radius)];
            [leftUpImageView setImage:image.leftUpImage];
            leftUpImageView.center = CGPointMake(value2, value2);
            [self addSubview:leftUpImageView];
            shouldAdd = YES;
        }
        
        if (corners & UIRectCornerTopRight && image.rightUpImage) {
            _CornerImageView *rightUpImageView = [[_CornerImageView alloc] initWithFrame:CGRectMake(0, 0, radius, radius)];
            [rightUpImageView setImage:image.rightUpImage];
            rightUpImageView.center = CGPointMake(value1, value2);
            [self addSubview:rightUpImageView];
            shouldAdd = YES;
        }
        
        if (corners & UIRectCornerBottomRight && image.rightDownImage) {
            _CornerImageView *rightDownImageView = [[_CornerImageView alloc] initWithFrame:CGRectMake(0, 0, radius, radius)];
            [rightDownImageView setImage:image.rightDownImage];
            rightDownImageView.center = CGPointMake(value1, value3);
            [self addSubview:rightDownImageView];
            shouldAdd = YES;
        }
        
        if (corners & UIRectCornerBottomLeft && image.leftDownImage) {
            _CornerImageView *leftDownImageView = [[_CornerImageView alloc] initWithFrame:CGRectMake(0, 0, radius, radius)];
            [leftDownImageView setImage:image.leftDownImage];
            leftDownImageView.center = CGPointMake(value2, value3);
            [self addSubview:leftDownImageView];
            shouldAdd = YES;
        }
        
        objc_setAssociatedObject(self, "lee_hasAddEmpty", @(shouldAdd), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
}

- (BOOL)lee_hasAddEmpty {
    NSNumber *hasAdd = objc_getAssociatedObject(self, "lee_hasAddEmpty");
    if (hasAdd && [hasAdd respondsToSelector:@selector(boolValue)]) {
        return [hasAdd boolValue];
    }
    
    return NO;
}

- (NSString *)lee_lastBorderImageKey {
    return objc_getAssociatedObject(self, "lee_lastBorderImageKey");
}

- (void)setLee_lastBorderImageKey:(NSString *)key {
    objc_setAssociatedObject(self,
                             "lee_lastBorderImageKey",
                             key,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

