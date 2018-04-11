//
//  BaseViewController.m
//  LeeKit
//
//  Created by Lee on 2018/3/21.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "BaseViewController.h"
#import "LeeEmptyView.h"
#import <objc/runtime.h>

@interface BaseViewControllerHideKeyboardDelegateObject: NSObject<UIGestureRecognizerDelegate, LeeKeyboardManagerDelegate>

@property(nonatomic, weak) BaseViewController *viewController;
- (instancetype)initWithViewController:(BaseViewController *)viewController;
@end

@interface BaseViewController (){
    UITapGestureRecognizer *_hideKeyboardTapGestureRecognizer;
    LeeKeyboardManager *_hideKeyboardManager;
    BaseViewControllerHideKeyboardDelegateObject *_hideKeyboadDelegateObject;
}

@end

@implementation BaseViewController

#pragma mark - 生命周期

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self didInitialized];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialized];
    }
    return self;
}

- (void)didInitialized {
    
    self.hidesBottomBarWhenPushed = YES;
    
    // 不管navigationBar的backgroundImage如何设置，都让布局撑到屏幕顶部，方便布局的统一
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    self.supportedOrientationMask = UIInterfaceOrientationPortrait;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _hideKeyboadDelegateObject = [[BaseViewControllerHideKeyboardDelegateObject alloc] initWithViewController:self];
    _hideKeyboardTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:nil action:NULL];
    self.hideKeyboardTapGestureRecognizer.delegate = _hideKeyboadDelegateObject;
    self.hideKeyboardTapGestureRecognizer.enabled = NO;
    [self.view addGestureRecognizer:self.hideKeyboardTapGestureRecognizer];
    // Do any additional setup after loading the view.
    //子类重写，ui初始化，不在此布局
    [self initSubviews];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutEmptyView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNavigationItemsIsInEditMode:NO animated:NO];
}

#pragma mark - 空列表视图
- (void)showEmptyView {
    if (!self.emptyView) {
        self.emptyView = [[LeeEmptyView alloc] initWithFrame:self.view.bounds];
    }
    [self.view addSubview:self.emptyView];
}

- (void)hideEmptyView {
    [self.emptyView removeFromSuperview];
}

- (BOOL)isEmptyViewShowing {
    return self.emptyView && self.emptyView.superview;
}

- (void)showEmptyViewWithLoading {
    [self showEmptyView];
    [self.emptyView setImage:nil];
    [self.emptyView setLoadingViewHidden:NO];
    [self.emptyView setTextLabelText:nil];
    [self.emptyView setDetailTextLabelText:nil];
    [self.emptyView setActionButtonTitle:nil];
}

- (void)showEmptyViewWithText:(NSString *)text
                   detailText:(NSString *)detailText
                  buttonTitle:(NSString *)buttonTitle
                 buttonAction:(SEL)action {
    [self showEmptyViewWithLoading:NO image:nil text:text detailText:detailText buttonTitle:buttonTitle buttonAction:action];
}

- (void)showEmptyViewWithImage:(UIImage *)image
                          text:(NSString *)text
                    detailText:(NSString *)detailText
                   buttonTitle:(NSString *)buttonTitle
                  buttonAction:(SEL)action {
    [self showEmptyViewWithLoading:NO image:image text:text detailText:detailText buttonTitle:buttonTitle buttonAction:action];
}

- (void)showEmptyViewWithLoading:(BOOL)showLoading
                           image:(UIImage *)image
                            text:(NSString *)text
                      detailText:(NSString *)detailText
                     buttonTitle:(NSString *)buttonTitle
                    buttonAction:(SEL)action {
    [self showEmptyView];
    [self.emptyView setLoadingViewHidden:!showLoading];
    [self.emptyView setImage:image];
    [self.emptyView setTextLabelText:text];
    [self.emptyView setDetailTextLabelText:detailText];
    [self.emptyView setActionButtonTitle:buttonTitle];
    [self.emptyView.actionButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.emptyView.actionButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
}

- (BOOL)layoutEmptyView {
    if (self.emptyView) {
        // 由于为self.emptyView设置frame时会调用到self.view，为了避免导致viewDidLoad提前触发，这里需要判断一下self.view是否已经被初始化
        BOOL viewDidLoad = self.emptyView.superview && [self isViewLoaded];
        if (viewDidLoad) {
            CGSize newEmptyViewSize = self.emptyView.superview.bounds.size;
            CGSize oldEmptyViewSize = self.emptyView.frame.size;
            if (!CGSizeEqualToSize(newEmptyViewSize, oldEmptyViewSize)) {
                self.emptyView.frame = CGRectMake(CGRectGetMinX(self.emptyView.frame), CGRectGetMinY(self.emptyView.frame), newEmptyViewSize.width, newEmptyViewSize.height);
            }
            return YES;
        }
    }
    
    return NO;
}


- (BOOL)hasOverrideMethod:(SEL)selector ofSuperclass:(Class)superclass {
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


@implementation BaseViewController (UISubclassingHooks)

- (void)initSubviews {
    // 子类重写
}

- (void)setNavigationItemsIsInEditMode:(BOOL)isInEditMode animated:(BOOL)animated {
    // 子类重写
    
}

- (void)contentSizeCategoryDidChanged:(NSNotification *)notification {
    // 子类重写
}

@end

@implementation BaseViewController (Keyboard)

- (UITapGestureRecognizer *)hideKeyboardTapGestureRecognizer {
    return _hideKeyboardTapGestureRecognizer;
}

- (LeeKeyboardManager *)hideKeyboardManager {
    return _hideKeyboardManager;
}

- (BOOL)shouldHideKeyboardWhenTouchInView:(UIView *)view {
    // 子类重写，默认返回 NO，也即不主动干预键盘的状态
    return NO;
}

@end


@implementation BaseViewControllerHideKeyboardDelegateObject

- (instancetype)initWithViewController:(BaseViewController *)viewController {
    if (self = [super init]) {
        self.viewController = viewController;
    }
    return self;
}

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer != self.viewController.hideKeyboardTapGestureRecognizer) {
        return YES;
    }
    
    if (![LeeKeyboardManager isKeyboardVisible]) {
        return NO;
    }
    
    UIView *targetView = [self targetView:gestureRecognizer];
    
    // 点击了本身就是输入框的 view，就不要降下键盘了
    if ([targetView isKindOfClass:[UITextField class]] || [targetView isKindOfClass:[UITextView class]]) {
        return NO;
    }
    
    if ([self.viewController shouldHideKeyboardWhenTouchInView:targetView]) {
        [self.viewController.view endEditing:YES];
    }
    return NO;
}

- (nullable UIView *)targetView:(UIGestureRecognizer *)ges {
    CGPoint location = [ges locationInView:ges.view];
    UIView *targetView = [ges.view hitTest:location withEvent:nil];
    return targetView;
}

#pragma mark - <LeeKeyboardManagerDelegate>

- (void)keyboardWillShowWithUserInfo:(LeeKeyboardUserInfo *)keyboardUserInfo {
    if (!(self.viewController.isViewLoaded && self.viewController.view.window)) return;
    BOOL hasOverrideMethod = [self.viewController hasOverrideMethod:@selector(shouldHideKeyboardWhenTouchInView:) ofSuperclass:[BaseViewController class]];
    self.viewController.hideKeyboardTapGestureRecognizer.enabled = hasOverrideMethod;
}



- (void)keyboardWillHideWithUserInfo:(LeeKeyboardUserInfo *)keyboardUserInfo {
    self.viewController.hideKeyboardTapGestureRecognizer.enabled = NO;
}

@end
