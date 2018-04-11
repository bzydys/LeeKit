//
//  LeePieProgressView.m
//  LeeKit
//
//  Created by Lee on 2018/3/20.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "LeePieProgressView.h"

@interface LeePieProgressLayer : CALayer

@property(nonatomic, strong) UIColor *fillColor;
@property(nonatomic, assign) float progress;
@property(nonatomic, assign) CFTimeInterval progressAnimationDuration;
@property(nonatomic, assign) BOOL shouldChangeProgressWithAnimation; // default is YES
@end

@implementation LeePieProgressLayer
// 加dynamic才能让自定义的属性支持动画
@dynamic fillColor;
@dynamic progress;

- (instancetype)init {
    if (self = [super init]) {
        self.shouldChangeProgressWithAnimation = YES;
    }
    return self;
}

+ (BOOL)needsDisplayForKey:(NSString *)key {
    return [key isEqualToString:@"progress"] || [super needsDisplayForKey:key];
}

- (id<CAAction>)actionForKey:(NSString *)event{
    if ([event isEqualToString:@"progress"] && self.shouldChangeProgressWithAnimation) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:event];
        animation.fromValue = [self.presentationLayer valueForKey:event];
        animation.duration = self.progressAnimationDuration;
        return animation;
    }
    return [super actionForKey:event];
}

- (void)drawInContext:(CGContextRef)context {
    if (CGRectIsEmpty(self.bounds)) {
        return;
    }
    
    // 绘制扇形进度区域
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = MIN(center.x, center.y);
    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = M_PI * 2 * self.progress + startAngle;
    CGContextSetFillColorWithColor(context, self.fillColor.CGColor);
    CGContextMoveToPoint(context, center.x, center.y);
    CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    [super drawInContext:context];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.cornerRadius = CGRectGetHeight(frame) / 2;
}


@end

@implementation LeePieProgressView

+ (Class)layerClass {
    return [LeePieProgressLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.tintColor = [UIColor blueColor];
        
        [self didInitialized];
    }
    return self;
}

- (void)didInitialized {
    self.progress = 0.0;
    self.progressAnimationDuration = 0.5;
    
    self.layer.contentsScale = [UIScreen mainScreen].scale;// 要显示指定一个倍数
    self.layer.borderWidth = 1.0;
    [self.layer setNeedsDisplay];
}

- (void)setProgress:(float)progress {
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(float)progress animated:(BOOL)animated {
    _progress = fmax(0.0, fmin(1.0, progress));
    LeePieProgressLayer *layer = (LeePieProgressLayer *)self.layer;
    layer.shouldChangeProgressWithAnimation = animated;
    layer.progress = _progress;
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)setProgressAnimationDuration:(CFTimeInterval)progressAnimationDuration {
    _progressAnimationDuration = progressAnimationDuration;
    self.progressLayer.progressAnimationDuration = progressAnimationDuration;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    self.progressLayer.fillColor = self.tintColor;
    self.progressLayer.borderColor = self.tintColor.CGColor;
}

- (LeePieProgressLayer *)progressLayer {
    return (LeePieProgressLayer *)self.layer;
}




@end
