//
//  LeeKeyboardManager.m
//  LeeKit
//
//  Created by Lee on 2018/3/13.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "LeeKeyboardManager.h"
#import <objc/runtime.h>
#define IOS_VERSION ([[[UIDevice currentDevice] systemVersion] doubleValue])

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

@interface UIView (keyboardManager)

-(id)lee_findFirstResponder;

@end

@implementation UIView (keyboardManager)

-(id)lee_findFirstResponder{
    if (self.isFirstResponder) {
        return self;
    }
    for (UIView *subView in self.subviews) {
        id responder = [subView lee_findFirstResponder];
        if (responder) {
            return responder;
        }
    }
    return nil;
}

@end

@interface UIResponder (KeyboardManager)

// 系统自己的isFirstResponder有延迟，这里手动记录UIResponder是否isFirstResponder
@property(nonatomic, assign) BOOL keyboardManager_isFirstResponder;

@end

@implementation UIResponder (KeyboardManager)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        ReplaceMethod(class, @selector(becomeFirstResponder), @selector(keyboardManager_becomeFirstResponder));
        ReplaceMethod(class, @selector(resignFirstResponder), @selector(keyboardManager_resignFirstResponder));
    });
}

- (BOOL)keyboardManager_becomeFirstResponder {
    self.keyboardManager_isFirstResponder = YES;
    return [self keyboardManager_becomeFirstResponder];
}

- (BOOL)keyboardManager_resignFirstResponder {
    self.keyboardManager_isFirstResponder = NO;
    return [self keyboardManager_resignFirstResponder];
}

- (void)setKeyboardManager_isFirstResponder:(BOOL)keyboardManager_isFirstResponder {
    objc_setAssociatedObject(self, @selector(keyboardManager_isFirstResponder), @(keyboardManager_isFirstResponder), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)keyboardManager_isFirstResponder {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end

@interface LeeKeyboardUserInfo ()

@property(nonatomic, weak, readwrite) LeeKeyboardManager *keyboardManager;
@property(nonatomic, strong, readwrite) NSNotification *notification;
@property(nonatomic, weak, readwrite) UIResponder *targetResponder;
@property(nonatomic, assign) BOOL isTargetResponderFocused;

@property(nonatomic, assign, readwrite) CGFloat width;
@property(nonatomic, assign, readwrite) CGFloat height;

@property(nonatomic, assign, readwrite) CGRect beginFrame;
@property(nonatomic, assign, readwrite) CGRect endFrame;

@property(nonatomic, assign, readwrite) NSTimeInterval animationDuration;
@property(nonatomic, assign, readwrite) UIViewAnimationCurve animationCurve;
@property(nonatomic, assign, readwrite) UIViewAnimationOptions animationOptions;

@end

@implementation LeeKeyboardUserInfo

-(void)setNotification:(NSNotification *)notification {
    _notification = notification;
    if (self.originUserInfo) {
        _animationDuration = [[self.originUserInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        _animationCurve = (UIViewAnimationCurve)[[self.originUserInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
        _animationOptions = self.animationCurve<<16;
        _beginFrame = [[self.originUserInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        _endFrame = [[self.originUserInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    }
}

- (void)setTargetResponder:(UIResponder *)targetResponder {
    _targetResponder = targetResponder;
    self.isTargetResponderFocused = targetResponder && targetResponder.keyboardManager_isFirstResponder;
}

- (NSDictionary *)originUserInfo {
    return self.notification ? self.notification.userInfo : nil;
}

- (CGFloat)width {
    CGRect keyboardRect = [LeeKeyboardManager convertKeyboardRect:_endFrame toView:nil];
    return keyboardRect.size.width;
}

- (CGFloat)height {
    CGRect keyboardRect = [LeeKeyboardManager convertKeyboardRect:_endFrame toView:nil];
    return keyboardRect.size.height;
}

- (CGFloat)heightInView:(UIView *)view {
    if (!view) {
        return [self height];
    }
    CGRect keyboardRect = [LeeKeyboardManager convertKeyboardRect:_endFrame toView:view];
    CGRect visiableRect = CGRectIntersection(view.bounds, keyboardRect);
    if (CGRectIsNull(visiableRect)) {
        return 0;
    }
    return visiableRect.size.height;
}

- (CGRect)beginFrame {
    return _beginFrame;
}

- (CGRect)endFrame {
    return _endFrame;
}

- (NSTimeInterval)animationDuration {
    return _animationDuration;
}

- (UIViewAnimationCurve)animationCurve {
    return _animationCurve;
}

- (UIViewAnimationOptions)animationOptions {
    return _animationOptions;
}

@end

@interface LeeKeyboardManager ()

@property(nonatomic, strong) NSMutableArray <NSValue *> *targetResponderValues;

@property(nonatomic, strong) LeeKeyboardUserInfo *keyboardMoveUserInfo;
@property(nonatomic, assign) CGRect keyboardMoveBeginRect;

@end

static UIResponder *kCurrentResponder = nil;

@implementation LeeKeyboardManager

// 1、系统键盘app启动第一次使用键盘的时候，会调用两轮键盘通知事件，之后就只会调用一次。而搜狗等第三方输入法的键盘，目前发现每次都会调用三次键盘通知事件。总之，键盘的通知事件是不确定的。

// 2、搜狗键盘可以修改键盘的高度，在修改键盘高度之后，会调用键盘的keyboardWillChangeFrameNotification和keyboardWillShowNotification通知。

// 3、如果从一个聚焦的输入框直接聚焦到另一个输入框，会调用前一个输入框的keyboardWillChangeFrameNotification，在调用后一个输入框的keyboardWillChangeFrameNotification，最后调用后一个输入框的keyboardWillShowNotification（如果此时是浮动键盘，那么后一个输入框的keyboardWillShowNotification不会被调用；）。

// 4、iPad可以变成浮动键盘，固定->浮动：会调用keyboardWillChangeFrameNotification和keyboardWillHideNotification；浮动->固定：会调用keyboardWillChangeFrameNotification和keyboardWillShowNotification；浮动键盘在移动的时候只会调用keyboardWillChangeFrameNotification通知，并且endFrame为zero，fromFrame不为zero，而是移动前键盘的frame。浮动键盘在聚焦和失焦的时候只会调用keyboardWillChangeFrameNotification，不会调用show和hide的notification。

// 5、iPad可以拆分为左右的小键盘，小键盘的通知具体基本跟浮动键盘一样。

// 6、iPad可以外接键盘，外接键盘之后屏幕上就没有虚拟键盘了，但是当我们输入文字的时候，发现底部还是有一条灰色的候选词，条东西也是键盘，它也会触发跟虚拟键盘一样的通知事件。如果点击这条候选词右边的向下箭头，则可以完全隐藏虚拟键盘，这个时候如果失焦再聚焦发现还是没有这条候选词，也就是键盘完全不出来了，如果输入文字，候选词才会重新出来。总结来说就是这条候选词是可以关闭的，关闭之后只有当下次输入才会重新出现。（聚焦和失焦都只调用keyboardWillChangeFrameNotification和keyboardWillHideNotification通知，而且frame始终不变，都是在屏幕下面）

// 7、iOS8 hide 之后高度变成0了，keyboardWillHideNotification还是正常的，所以建议不要使用键盘高度来做动画，而是用键盘的y值；在show和hide的时候endFrame会出现一些奇怪的中间值，最终值是对的；两个输入框切换聚焦，iOS8不会触发任何键盘通知；iOS8的浮动切换正常；

// 8、iOS8在 固定->浮动 的过程中，后面的keyboardWillChangeFrameNotification和keyboardWillHideNotification里面的endFrame是正确的，而iOS10和iOS9是错的，iOS9的y值是键盘的MaxY，而iOS10的y值是隐藏状态下的y，也就是屏幕高度。所以iOS9和iOS10需要在keyboardDidChangeFrameNotification里面重新刷新一下。

- (instancetype)init {
    NSAssert(NO, @"请使用initWithDelegate:初始化");
    return [self initWithDelegate:nil];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    NSAssert(NO, @"请使用initWithDelegate:初始化");
    return [self initWithDelegate:nil];
}

- (instancetype)initWithDelegate:(id <LeeKeyboardManagerDelegate>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
        _delegateEnabled = YES;
        _targetResponderValues = [[NSMutableArray alloc] init];
        [self addKeyboardNotification];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)addTargetResponder:(UIResponder *)targetResponder {
    if (!targetResponder || ![targetResponder isKindOfClass:[UIResponder class]]) {
        return NO;
    }
    [self.targetResponderValues addObject:[self packageTargetResponder:targetResponder]];
    return YES;
}

- (NSArray<UIResponder *> *)allTargetResponders {
    NSMutableArray *targetResponders = nil;
    for (int i = 0; i < self.targetResponderValues.count; i++) {
        if (!targetResponders) {
            targetResponders = [[NSMutableArray alloc] init];
        }
        id unPackageValue = [self unPackageTargetResponder:self.targetResponderValues[i]];
        if (unPackageValue && [unPackageValue isKindOfClass:[UIResponder class]]) {
            [targetResponders addObject:(UIResponder *)unPackageValue];
        }
    }
    return [targetResponders copy];
}

- (UIResponder *)unPackageTargetResponder:(NSValue *)value {
    if (!value) {
        return nil;
    }
    id unPackageValue = [value nonretainedObjectValue];
    if (![unPackageValue isKindOfClass:[UIResponder class]]) {
        return nil;
    }
    return (UIResponder *)unPackageValue;
}

- (void)addKeyboardNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShowNotification:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHideNotification:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrameNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrameNotification:) name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (void)keyboardWillShowNotification: (NSNotification *)notification {
#ifdef DEBUG
    NSLog(@"keyboardWillShowNotification - %@", self);
    NSLog(@"\n");
#endif
    if (![self shouldReceiveShowNotification]) {
        return;
    }
    
    LeeKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
    userInfo.targetResponder = kCurrentResponder ?: nil;
    if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardWillShowWithUserInfo:)]) {
        [self.delegate keyboardWillShowWithUserInfo:userInfo];
    }
}

- (void)keyboardDidShowNotification:(NSNotification *)notification {
#ifdef DEBUG
    NSLog(@"keyboardDidShowNotification - %@", self);
    NSLog(@"\n");
#endif
    LeeKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
    userInfo.targetResponder = kCurrentResponder ?: nil;
    
    id firstResponder = [[UIApplication sharedApplication].keyWindow lee_findFirstResponder];
    BOOL shouldReceiveDidShowNotification = self.targetResponderValues.count <= 0 || (firstResponder && firstResponder == kCurrentResponder);
    
    if (shouldReceiveDidShowNotification) {
        
        if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardDidShowWithUserInfo:)]) {
            [self.delegate keyboardDidShowWithUserInfo:userInfo];
        }
    }
}

- (void)keyboardWillHideNotification:(NSNotification *)notification {
#ifdef DEBUG
    NSLog(@"keyboardWillHideNotification - %@", self);
    NSLog(@"\n");
#endif
    if (![self shouldReceiveHideNotification]) {
        return;
    }
    
    LeeKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
    userInfo.targetResponder = kCurrentResponder ?: nil;
    
    if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardWillHideWithUserInfo:)]) {
        [self.delegate keyboardWillHideWithUserInfo:userInfo];
    }
}

- (void)keyboardDidHideNotification:(NSNotification *)notification {
    
    #ifdef DEBUG
        NSLog(@"keyboardDidHideNotification - %@", self);
        NSLog(@"\n");
    #endif
    
    LeeKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
    userInfo.targetResponder = kCurrentResponder ?: nil;
    
    if ([self shouldReceiveHideNotification]) {
        if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardDidHideWithUserInfo:)]) {
            [self.delegate keyboardDidHideWithUserInfo:userInfo];
        }
    }
    
    if (kCurrentResponder && !kCurrentResponder.keyboardManager_isFirstResponder) {
        kCurrentResponder = nil;
    }
}

- (void)keyboardWillChangeFrameNotification:(NSNotification *)notification {
    
#ifdef DEBUG
    NSLog(@"keyboardWillChangeFrameNotification - %@", self);
    NSLog(@"\n");
#endif
    
    LeeKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
    
    if ([self shouldReceiveShowNotification]) {
        userInfo.targetResponder = kCurrentResponder ?: nil;
    } else if ([self shouldReceiveHideNotification]) {
        userInfo.targetResponder = kCurrentResponder ?: nil;
    } else {
        return;
    }
    
    if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardWillChangeFrameWithUserInfo:)]) {
        [self.delegate keyboardWillChangeFrameWithUserInfo:userInfo];
    }
}

- (void)keyboardDidChangeFrameNotification:(NSNotification *)notification {
    
#ifdef DEBUG
    NSLog(@"keyboardDidChangeFrameNotification - %@", self);
    NSLog(@"\n");
#endif
    
    LeeKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
    
    if ([self shouldReceiveShowNotification]) {
        userInfo.targetResponder = kCurrentResponder ?: nil;
    } else if ([self shouldReceiveHideNotification]) {
        userInfo.targetResponder = kCurrentResponder ?: nil;
    } else {
        return;
    }
    
    if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardDidChangeFrameWithUserInfo:)]) {
        [self.delegate keyboardDidChangeFrameWithUserInfo:userInfo];
    }
}

- (BOOL)shouldReceiveShowNotification {
    
    kCurrentResponder = [[UIApplication sharedApplication].keyWindow lee_findFirstResponder];
    
    if (self.targetResponderValues.count <= 0) {
        return YES;
    } else {
        return kCurrentResponder && [self.targetResponderValues containsObject:[self packageTargetResponder:kCurrentResponder]];
    }
}

- (BOOL)shouldReceiveHideNotification {
    if (self.targetResponderValues.count <= 0) {
        return YES;
    } else {
        if (kCurrentResponder) {
            return [self.targetResponderValues containsObject:[self packageTargetResponder:kCurrentResponder]];
        } else {
            return NO;
        }
    }
}

- (NSValue *)packageTargetResponder:(UIResponder *)targetResponder {
    if (![targetResponder isKindOfClass:[UIResponder class]]) {
        return nil;
    }
    return [NSValue valueWithNonretainedObject:targetResponder];
}

- (LeeKeyboardUserInfo *)newUserInfoWithNotification:(NSNotification *)notification {
    LeeKeyboardUserInfo *userInfo = [[LeeKeyboardUserInfo alloc] init];
    userInfo.keyboardManager = self;
    userInfo.notification = notification;
    return userInfo;
}

#pragma mark - 工具方法
+ (void)animateWithAnimated:(BOOL)animated keyboardUserInfo:(LeeKeyboardUserInfo *)keyboardUserInfo animations:(void (^)(void))animations completion:(void (^)(BOOL))completion{
    if (animated) {
        [UIView animateWithDuration:keyboardUserInfo.animationDuration delay:0 options:keyboardUserInfo.animationOptions|UIViewAnimationOptionBeginFromCurrentState animations:^{
            if (animations) {
                animations();
            }
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
    }else{
        if (animations) {
            animations();
        }
        if (completion) {
            completion(YES);
        }
    }
}

+ (UIWindow *)keyboardWindow{
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        if ([self getKeyboardViewFromWindow:window]) {
            return window;
        }
    }
    
    NSMutableArray *kbWindows = nil;
    
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        NSString *windowName = NSStringFromClass(window.class);
        if (IOS_VERSION < 9) {
            // UITextEffectsWindow
            if (windowName.length == 19 &&
                [windowName hasPrefix:@"UI"] &&
                [windowName hasSuffix:[NSString stringWithFormat:@"%@%@", @"TextEffects", @"Window"]]) {
                if (!kbWindows) kbWindows = [NSMutableArray new];
                [kbWindows addObject:window];
            }
        } else {
            // UIRemoteKeyboardWindow
            if (windowName.length == 22 &&
                [windowName hasPrefix:@"UI"] &&
                [windowName hasSuffix:[NSString stringWithFormat:@"%@%@", @"Remote", @"KeyboardWindow"]]) {
                if (!kbWindows) kbWindows = [NSMutableArray new];
                [kbWindows addObject:window];
            }
        }
    }
    
    if (kbWindows.count == 1) {
        return kbWindows.firstObject;
    }
    
    return nil;
}

+ (UIView *)getKeyboardViewFromWindow:(UIWindow *)window {
    
    if (!window) return nil;
    
    NSString *windowName = NSStringFromClass(window.class);
    if (IOS_VERSION < 9) {
        if (![windowName isEqualToString:@"UITextEffectsWindow"]) {
            return nil;
        }
    } else {
        if (![windowName isEqualToString:@"UIRemoteKeyboardWindow"]) {
            return nil;
        }
    }
    
    for (UIView *view in window.subviews) {
        NSString *viewName = NSStringFromClass(view.class);
        if (![viewName isEqualToString:@"UIInputSetContainerView"]) {
            continue;
        }
        
        for (UIView *subView in view.subviews) {
            NSString *subViewName = NSStringFromClass(subView.class);
            if (![subViewName isEqualToString:@"UIInputSetHostView"]) {
                continue;
            }
            return subView;
        }
    }
    
    return nil;
}

+ (CGRect)convertKeyboardRect:(CGRect)rect toView:(UIView *)view {
    
    if (CGRectIsNull(rect) || CGRectIsInfinite(rect)) {
        return rect;
    }
    
    UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow ?: [UIApplication sharedApplication].windows.firstObject;
    if (!mainWindow) {
        if (view) {
            [view convertRect:rect fromView:nil];
        } else {
            return rect;
        }
    }
    
    rect = [mainWindow convertRect:rect fromWindow:nil];
    if (!view) {
        return [mainWindow convertRect:rect toWindow:nil];
    }
    if (view == mainWindow) {
        return rect;
    }
    
    UIWindow *toWindow = [view isKindOfClass:[UIWindow class]] ? (id)view : view.window;
    if (!mainWindow || !toWindow) {
        return [mainWindow convertRect:rect toView:view];
    }
    if (mainWindow == toWindow) {
        return [mainWindow convertRect:rect toView:view];
    }
    
    rect = [mainWindow convertRect:rect toView:mainWindow];
    rect = [toWindow convertRect:rect fromWindow:mainWindow];
    rect = [view convertRect:rect fromView:toWindow];
    
    return rect;
}

+ (CGFloat)distanceFromMinYToBottomInView:(UIView *)view keyboardRect:(CGRect)rect {
    rect = [self convertKeyboardRect:rect toView:view];
    CGFloat distance = CGRectGetHeight(view.bounds) - CGRectGetMinY(rect);
    return distance;
}

+ (UIView *)keyboardView {
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        UIView *view = [self getKeyboardViewFromWindow:window];
        if (view) {
            return view;
        }
    }
    return nil;
}

+ (BOOL)isKeyboardVisible {
    UIView *keyboardView = self.keyboardView;
    UIWindow *keyboardWindow = keyboardView.window;
    if (!keyboardView || !keyboardWindow) {
        return NO;
    }
    CGRect rect = CGRectIntersection(keyboardWindow.bounds, keyboardView.frame);
    if (CGRectIsNull(rect) || CGRectIsInfinite(rect)) {
        return NO;
    }
    return rect.size.width > 0 && rect.size.height > 0;
}

+ (CGRect)currentKeyboardFrame {
    UIView *keyboardView = [self keyboardView];
    if (!keyboardView) {
        return CGRectNull;
    }
    UIWindow *keyboardWindow = keyboardView.window;
    if (keyboardWindow) {
        return [keyboardWindow convertRect:keyboardView.frame toWindow:nil];
    } else {
        return keyboardView.frame;
    }
}

+ (CGFloat)visiableKeyboardHeight {
    UIView *keyboardView = [self keyboardView];
    UIWindow *keyboardWindow = keyboardView.window;
    if (!keyboardView || !keyboardWindow) {
        return 0;
    } else {
        CGRect visiableRect = CGRectIntersection(keyboardWindow.bounds, keyboardView.frame);
        if (CGRectIsNull(visiableRect)) {
            return 0;
        }
        return visiableRect.size.height;
    }
}

@end
