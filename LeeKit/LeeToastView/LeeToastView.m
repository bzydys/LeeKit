//
//  LeeToastView.m
//  LeeKit
//
//  Created by Lee on 2018/3/12.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "LeeToastView.h"
#import "LeeToastBackgroundView.h"
#import "LeeToastContentView.h"
#import "LeeToastAnimator.h"
#import "LeeKeyboardManager.h"

@interface LeeToastView ()

@property(nonatomic, weak) NSTimer *hideDelayTimer;

@end

@implementation LeeToastView

-(instancetype)initWithFrame:(CGRect)frame {
    NSAssert(NO, @"请使用initWithView:初始化");
    return [self initWithView:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSAssert(NO, @"请使用initWithView:初始化");
    return [self initWithView:nil];
}

- (instancetype)initWithView:(UIView *)view {
    NSParameterAssert(view != nil);
    if (self = [super initWithFrame:view.bounds]) {
        _parentView = view;
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    
    self.toastPosition = LeeToastViewPositionCenter;
    
    // 顺序不能乱，先添加backgroundView再添加contentView
    self.backgroundView = [self defaultBackgroundView];
    self.contentView = [self defaultContentView];
    
    self.opaque = NO;
    self.alpha = 0.0;
    self.backgroundColor = [UIColor clearColor];
    self.layer.allowsGroupOpacity = NO;
    
    self.tintColor = [UIColor whiteColor];
    
    _maskView = [[UIView alloc] init];
    self.maskView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.maskView];
    
}

- (LeeToastAnimator *)defaultAnimator {
    LeeToastAnimator *toastAnimator = [[LeeToastAnimator alloc] initWithToastView:self];
    return toastAnimator;
}

- (UIView *)defaultBackgroundView {
    LeeToastBackgroundView *backgroundView = [[LeeToastBackgroundView alloc] init];
    return backgroundView;
}

- (UIView *)defaultContentView {
    LeeToastContentView *contentView = [[LeeToastContentView alloc] init];
    return contentView;
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    _parentView = nil;
}

- (void)setBackgroundView:(UIView *)backgroundView {
    if (self.backgroundView) {
        [self.backgroundView removeFromSuperview];
        _backgroundView = nil;
    }
    _backgroundView = backgroundView;
    self.backgroundView.alpha = 0.0;
    [self addSubview:self.backgroundView];
    [self setNeedsLayout];
}

- (void)setContentView:(UIView *)contentView {
    if (self.contentView) {
        [self.contentView removeFromSuperview];
        _contentView = nil;
    }
    _contentView = contentView;
    self.contentView.alpha = 0.0;
    [self addSubview:self.contentView];
    [self setNeedsLayout];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.frame = self.parentView.bounds;
    self.maskView.frame = self.bounds;
    
    CGFloat contentWidth = CGRectGetWidth(self.parentView.bounds);
    CGFloat contentHeight = CGRectGetHeight(self.parentView.bounds);
    
    CGFloat limitWidth = contentWidth - self.marginInsets.left - self.marginInsets.right;
    CGFloat limitHeight = contentHeight - self.marginInsets.top - self.marginInsets.bottom;
    
    if ([LeeKeyboardManager isKeyboardVisible]) {
        // 处理键盘相关逻辑，当键盘在显示的时候，内容高度会减去键盘的高度以使 Toast 居中
        CGRect keyboardFrame = [LeeKeyboardManager currentKeyboardFrame];
        CGRect parentViewRect = [[LeeKeyboardManager keyboardWindow] convertRect:self.parentView.frame fromView:self.parentView.superview];
        CGRect overlapRect = CGRectIntersection(keyboardFrame, parentViewRect);
        contentHeight -= CGRectGetHeight(overlapRect);
    }
    
    if (self.contentView) {
        
        CGSize contentViewSize = [self.contentView sizeThatFits:CGSizeMake(limitWidth, limitHeight)];
        CGFloat contentViewX = fmax(self.marginInsets.left, (contentWidth - contentViewSize.width) / 2) + self.offset.x;
        CGFloat contentViewY = fmax(self.marginInsets.top, (contentHeight - contentViewSize.height) / 2) + self.offset.y;
        
        if (self.toastPosition == LeeToastViewPositionTop) {
            contentViewY = self.marginInsets.top + self.offset.y;
        } else if (self.toastPosition == LeeToastViewPositionBottom) {
            contentViewY = contentHeight - contentViewSize.height - self.marginInsets.bottom + self.offset.y;
        }
        
        CGRect contentRect = CGRectMake(contentViewX, contentViewY, contentViewSize.width, contentViewSize.height);
        self.contentView.frame = CGRectApplyAffineTransform(contentRect, self.contentView.transform);
    }
    if (self.backgroundView) {
        // backgroundView的frame跟contentView一样，contentView里面的subviews如果需要在视觉上跟backgroundView有个padding，那么就自己在自定义的contentView里面做。
        self.backgroundView.frame = self.contentView.frame;
    }
}

#pragma mark - Show and Hide

- (void)showAnimated:(BOOL)animated {
    
    // show之前需要layout以下，防止同一个tip切换不同的状态导致layout没更新
    [self setNeedsLayout];
    
    [self.hideDelayTimer invalidate];
    self.alpha = 1.0;
    
    if (self.willShowBlock) {
        self.willShowBlock(self.parentView, animated);
    }
    
    if (animated) {
        if (!self.toastAnimator) {
            self.toastAnimator = [self defaultAnimator];
        }
        if (self.toastAnimator) {
            __weak __typeof(self)weakSelf = self;
            [self.toastAnimator showWithCompletion:^(BOOL finished) {
                if (weakSelf.didShowBlock) {
                    weakSelf.didShowBlock(weakSelf.parentView, animated);
                }
            }];
        }
    } else {
        self.backgroundView.alpha = 1.0;
        self.contentView.alpha = 1.0;
        if (self.didShowBlock) {
            self.didShowBlock(self.parentView, animated);
        }
    }
}

- (void)hideAnimated:(BOOL)animated {
    
    if (self.willHideBlock) {
        self.willHideBlock(self.parentView, animated);
    }
    
    if (animated) {
        if (!self.toastAnimator) {
            self.toastAnimator = [self defaultAnimator];
        }
        if (self.toastAnimator) {
            __weak __typeof(self)weakSelf = self;
            [self.toastAnimator hideWithCompletion:^(BOOL finished) {
                [weakSelf didHideWithAnimated:animated];
            }];
        }
    } else {
        self.backgroundView.alpha = 0.0;
        self.contentView.alpha = 0.0;
        [self didHideWithAnimated:animated];
    }
}

- (void)didHideWithAnimated:(BOOL)animated {
    
    if (self.didHideBlock) {
        self.didHideBlock(self.parentView, animated);
    }
    
    [self.hideDelayTimer invalidate];
    self.alpha = 0.0;
    if (self.removeFromSuperViewWhenHide) {
        [self removeFromSuperview];
    }
}

- (void)hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay {
    NSTimer *timer = [NSTimer timerWithTimeInterval:delay target:self selector:@selector(handleHideTimer:) userInfo:@(animated) repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.hideDelayTimer = timer;
}

- (void)handleHideTimer:(NSTimer *)timer {
    [self hideAnimated:[timer.userInfo boolValue]];
}

#pragma mark - UIAppearance

- (void)setOffset:(CGPoint)offset {
    _offset = offset;
    [self setNeedsLayout];
}

- (void)setMarginInsets:(UIEdgeInsets)marginInsets {
    _marginInsets = marginInsets;
    [self setNeedsLayout];
}

@end

@interface LeeToastView (UIAppearance)

@end

@implementation LeeToastView (UIAppearance)

+(void)initialize{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setDefaultAppearance];
    });
}

+ (void)setDefaultAppearance {
    LeeToastView *appearance = [LeeToastView appearance];
    appearance.offset = CGPointZero;
    appearance.marginInsets = UIEdgeInsetsMake(20, 20, 20, 20);
}

@end

@implementation LeeToastView (ToastTool)

+ (BOOL)hideAllToastInView:(UIView *)view animated:(BOOL)animated {
    NSArray *toastViews = [self allToastInView:view];
    BOOL returnFlag = NO;
    for (LeeToastView *toastView in toastViews) {
        if (toastView) {
            toastView.removeFromSuperViewWhenHide = YES;
            [toastView hideAnimated:animated];
            returnFlag = YES;
        }
    }
    return returnFlag;
}

+ (instancetype)toastInView:(UIView *)view {
    //迭代器
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:self]) {
            return (LeeToastView *)subview;
        }
    }
    return nil;
}

+ (NSArray <LeeToastView *> *)allToastInView:(UIView *)view {
    NSMutableArray *toastViews = [[NSMutableArray alloc] init];
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:self]) {
            [toastViews addObject:subview];
        }
    }
    return toastViews;
}

@end
