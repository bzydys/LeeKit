//
//  LeeAlertViewController.m
//  LeeKit
//
//  Created by Lee on 2018/3/16.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "LeeAlertViewController.h"
#import "LeeButton.h"
#import "LeeUITextField.h"
#import "UIView+Lee.h"
#import "UIImage+Lee.h"
#import "UIControl+Lee.h"
#import "CALayer+Lee.h"
#import "LeeModalPresentationViewController.h"
#define IOS_VERSION ([[[UIDevice currentDevice] systemVersion] doubleValue])

static NSUInteger alertControllerCount = 0;

#pragma mark - LeeBUttonWrapView

@interface LeeAlertButtonWrapView : UIView

@property(nonatomic, strong) LeeButton *button;

@end

@implementation LeeAlertButtonWrapView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.button = [[LeeButton alloc] init];
        self.button.adjustsButtonWhenDisabled = NO;
        self.button.adjustsButtonWhenHighlighted = NO;
        [self addSubview:self.button];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.button.frame = self.bounds;
}

@end

#pragma mark - LeeAlertAction

@protocol LeeAlertActionDelegate <NSObject>

- (void)didClickAlertAction:(LeeAlertAction *)alertAction;

@end

@interface LeeAlertAction ()

@property(nonatomic, strong) LeeAlertButtonWrapView *buttonWrapView;
@property(nonatomic, copy, readwrite) NSString *title;
@property(nonatomic, assign, readwrite) LeeAlertActionStyle style;
@property(nonatomic, copy) void (^handler)(LeeAlertAction *action);
@property(nonatomic, weak) id<LeeAlertActionDelegate> delegate;

@end

@implementation LeeAlertAction

+ (instancetype)actionWithTitle:(NSString *)title style:(LeeAlertActionStyle)style handler:(void (^)(LeeAlertAction *action))handler {
    LeeAlertAction *alertAction = [[LeeAlertAction alloc] init];
    alertAction.title = title;
    alertAction.style = style;
    alertAction.handler = handler;
    return alertAction;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.buttonWrapView = [[LeeAlertButtonWrapView alloc] init];
        self.button.lee_automaticallyAdjustTouchHighlightedInScrollView = YES;
        [self.button addTarget:self action:@selector(handleAlertActionEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (LeeButton *)button {
    return self.buttonWrapView.button;
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    self.button.enabled = enabled;
}

- (void)handleAlertActionEvent:(id)sender {
    // 需要先调delegate，里面会先恢复keywindow
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickAlertAction:)]) {
        [self.delegate didClickAlertAction:self];
    }
}

@end

@implementation LeeAlertViewController (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self appearance];
    });
}

static LeeAlertViewController *alertControllerAppearance;
+ (instancetype)appearance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self resetAppearance];
    });
    return alertControllerAppearance;
}

+ (NSMutableParagraphStyle *)lee_paragraphStyleWithLineHeight:(CGFloat)lineHeight lineBreakMode:(NSLineBreakMode)lineBreakMode textAlignment:(NSTextAlignment)textAlignment {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = lineHeight;
    paragraphStyle.maximumLineHeight = lineHeight;
    paragraphStyle.lineBreakMode = lineBreakMode;
    paragraphStyle.alignment = textAlignment;
    return paragraphStyle;
}

+ (void)resetAppearance {
    if (!alertControllerAppearance) {
        
        alertControllerAppearance = [[LeeAlertViewController alloc] init];
        
        alertControllerAppearance.alertContentMargin = UIEdgeInsetsMake(0, 0, 0, 0);
        alertControllerAppearance.alertContentMaximumWidth = 270;
        alertControllerAppearance.alertSeperatorColor = [UIColor colorWithRed:211/255.0 green:211/255.0 blue:219/255.0 alpha:1];
        alertControllerAppearance.alertTitleAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:17],NSParagraphStyleAttributeName:[self lee_paragraphStyleWithLineHeight:0 lineBreakMode:NSLineBreakByTruncatingTail textAlignment:NSTextAlignmentLeft]};
        alertControllerAppearance.alertMessageAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:13],NSParagraphStyleAttributeName:[self lee_paragraphStyleWithLineHeight:0 lineBreakMode:NSLineBreakByTruncatingTail textAlignment:NSTextAlignmentLeft]};
        alertControllerAppearance.alertButtonAttributes = @{NSForegroundColorAttributeName:[UIColor blueColor],NSFontAttributeName:[UIFont systemFontOfSize:17],NSKernAttributeName:@(0)};
        alertControllerAppearance.alertButtonDisabledAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:129/255.0 green:129/255.0 blue:129/255.0 alpha:1],NSFontAttributeName:[UIFont systemFontOfSize:17],NSKernAttributeName:@(0)};
        alertControllerAppearance.alertCancelButtonAttributes = @{NSForegroundColorAttributeName:[UIColor blueColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:17],NSKernAttributeName:@(0)};
        alertControllerAppearance.alertDestructiveButtonAttributes = @{NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName:[UIFont systemFontOfSize:17],NSKernAttributeName:@(0)};
        alertControllerAppearance.alertContentCornerRadius = (IOS_VERSION >= 9.0 ? 13 : 6);
        alertControllerAppearance.alertButtonHeight = 44;
        alertControllerAppearance.alertHeaderBackgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
        alertControllerAppearance.alertButtonBackgroundColor = alertControllerAppearance.alertHeaderBackgroundColor;
        alertControllerAppearance.alertButtonHighlightBackgroundColor = [UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1];
        alertControllerAppearance.alertHeaderInsets = UIEdgeInsetsMake(20, 16, 20, 16);
        alertControllerAppearance.alertTitleMessageSpacing = 3;
        
        alertControllerAppearance.sheetContentMargin = UIEdgeInsetsMake(10, 10, 10, 10);
        alertControllerAppearance.sheetContentMaximumWidth = 414 - alertControllerAppearance.sheetContentMargin.left - alertControllerAppearance.sheetContentMargin.right;
        alertControllerAppearance.sheetSeperatorColor = [UIColor colorWithRed:211/255.0 green:211/255.0 blue:219/255.0 alpha:1];
        alertControllerAppearance.sheetTitleAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:143/255.0 green:143/255.0 blue:143/255.0 alpha:1],NSFontAttributeName:[UIFont boldSystemFontOfSize:13],NSParagraphStyleAttributeName:[self lee_paragraphStyleWithLineHeight:0 lineBreakMode:NSLineBreakByTruncatingTail textAlignment:NSTextAlignmentLeft]};
        alertControllerAppearance.sheetMessageAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:143/255.0 green:143/255.0 blue:143/255.0 alpha:1],NSFontAttributeName:[UIFont systemFontOfSize:13],NSParagraphStyleAttributeName:[self lee_paragraphStyleWithLineHeight:0 lineBreakMode:NSLineBreakByTruncatingTail textAlignment:NSTextAlignmentLeft]};
        alertControllerAppearance.sheetButtonAttributes = @{NSForegroundColorAttributeName:[UIColor blueColor],NSFontAttributeName:[UIFont systemFontOfSize:20],NSKernAttributeName:@(0)};
        alertControllerAppearance.sheetButtonDisabledAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:129/255.0 green:129/255.0 blue:129/255.0 alpha:1],NSFontAttributeName:[UIFont systemFontOfSize:20],NSKernAttributeName:@(0)};
        alertControllerAppearance.sheetCancelButtonAttributes = @{NSForegroundColorAttributeName:[UIColor blueColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:20],NSKernAttributeName:@(0)};
        alertControllerAppearance.sheetDestructiveButtonAttributes = @{NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName:[UIFont systemFontOfSize:20],NSKernAttributeName:@(0)};
        alertControllerAppearance.sheetCancelButtonMarginTop = 8;
        alertControllerAppearance.sheetContentCornerRadius = (IOS_VERSION >= 9.0 ? 13 : 6);
        alertControllerAppearance.sheetButtonHeight = (IOS_VERSION >= 9.0 ? 57 : 44);
        alertControllerAppearance.sheetHeaderBackgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
        alertControllerAppearance.sheetButtonBackgroundColor = alertControllerAppearance.sheetHeaderBackgroundColor;
        alertControllerAppearance.sheetButtonHighlightBackgroundColor = [UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1];
        alertControllerAppearance.sheetHeaderInsets = UIEdgeInsetsMake(16, 16, 16, 16);
        alertControllerAppearance.sheetTitleMessageSpacing = 8;
        alertControllerAppearance.isExtendBottomLayout = NO;
    }
}

@end




@interface LeeAlertViewController ()<LeeAlertActionDelegate, LeeModalPresentationContentViewControllerProtocol, LeeModalPresentationViewControllerDelegate>

@property(nonatomic, assign, readwrite) LeeAlertControllerStyle preferredStyle;
@property(nonatomic, strong, readwrite) LeeModalPresentationViewController *modalPresentationViewController;

@property(nonatomic, strong) UIView *containerView;

@property(nonatomic, strong) UIControl *maskView;

@property(nonatomic, strong) UIView *scrollWrapView;
@property(nonatomic, strong) UIScrollView *headerScrollView;
@property(nonatomic, strong) UIScrollView *buttonScrollView;

@property(nonatomic, strong) UIView *headerEffectView;
@property(nonatomic, strong) UIView *cancelButtoneEffectView;

@property(nonatomic, strong) CALayer *extendLayer;

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *messageLabel;
@property(nonatomic, strong) LeeAlertAction *cancelAction;

@property(nonatomic, strong) NSMutableArray<LeeAlertAction *> *alertActions;
@property(nonatomic, strong) NSMutableArray<LeeAlertAction *> *destructiveActions;
@property(nonatomic, strong) NSMutableArray<UITextField *> *alertTextFields;

@property(nonatomic, assign) CGFloat keyboardHeight;
@property(nonatomic, assign) BOOL isShowing;

// 保护 showing 的过程中调用 hide 无效
@property(nonatomic, assign) BOOL isNeedsHideAfterAlertShowed;
@property(nonatomic, assign) BOOL isAnimatedForHideAfterAlertShowed;

@end

@implementation LeeAlertViewController {
    NSString  *_title;
    BOOL _needsUpdateAction;
    BOOL _needsUpdateTitle;
    BOOL _needsUpdateMessage;
}

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
    if (alertControllerAppearance) {
        self.alertContentMargin = [LeeAlertViewController appearance].alertContentMargin;
        self.alertContentMaximumWidth = [LeeAlertViewController appearance].alertContentMaximumWidth;
        self.alertSeperatorColor = [LeeAlertViewController appearance].alertSeperatorColor;
        self.alertContentCornerRadius = [LeeAlertViewController appearance].alertContentCornerRadius;
        self.alertTitleAttributes = [LeeAlertViewController appearance].alertTitleAttributes;
        self.alertMessageAttributes = [LeeAlertViewController appearance].alertMessageAttributes;
        self.alertButtonAttributes = [LeeAlertViewController appearance].alertButtonAttributes;
        self.alertButtonDisabledAttributes = [LeeAlertViewController appearance].alertButtonDisabledAttributes;
        self.alertCancelButtonAttributes = [LeeAlertViewController appearance].alertCancelButtonAttributes;
        self.alertDestructiveButtonAttributes = [LeeAlertViewController appearance].alertDestructiveButtonAttributes;
        self.alertButtonHeight = [LeeAlertViewController appearance].alertButtonHeight;
        self.alertHeaderBackgroundColor = [LeeAlertViewController appearance].alertHeaderBackgroundColor;
        self.alertButtonBackgroundColor = [LeeAlertViewController appearance].alertButtonBackgroundColor;
        self.alertButtonHighlightBackgroundColor = [LeeAlertViewController appearance].alertButtonHighlightBackgroundColor;
        self.alertHeaderInsets = [LeeAlertViewController appearance].alertHeaderInsets;
        self.alertTitleMessageSpacing = [LeeAlertViewController appearance].alertTitleMessageSpacing;
        
        self.sheetContentMargin = [LeeAlertViewController appearance].sheetContentMargin;
        self.sheetContentMaximumWidth = [LeeAlertViewController appearance].sheetContentMaximumWidth;
        self.sheetSeperatorColor = [LeeAlertViewController appearance].sheetSeperatorColor;
        self.sheetTitleAttributes = [LeeAlertViewController appearance].sheetTitleAttributes;
        self.sheetMessageAttributes = [LeeAlertViewController appearance].sheetMessageAttributes;
        self.sheetButtonAttributes = [LeeAlertViewController appearance].sheetButtonAttributes;
        self.sheetButtonDisabledAttributes = [LeeAlertViewController appearance].sheetButtonDisabledAttributes;
        self.sheetCancelButtonAttributes = [LeeAlertViewController appearance].sheetCancelButtonAttributes;
        self.sheetDestructiveButtonAttributes = [LeeAlertViewController appearance].sheetDestructiveButtonAttributes;
        self.sheetCancelButtonMarginTop = [LeeAlertViewController appearance].sheetCancelButtonMarginTop;
        self.sheetContentCornerRadius = [LeeAlertViewController appearance].sheetContentCornerRadius;
        self.sheetButtonHeight = [LeeAlertViewController appearance].sheetButtonHeight;
        self.sheetHeaderBackgroundColor = [LeeAlertViewController appearance].sheetHeaderBackgroundColor;
        self.sheetButtonBackgroundColor = [LeeAlertViewController appearance].sheetButtonBackgroundColor;
        self.sheetButtonHighlightBackgroundColor = [LeeAlertViewController appearance].sheetButtonHighlightBackgroundColor;
        self.sheetHeaderInsets = [LeeAlertViewController appearance].sheetHeaderInsets;
        self.sheetTitleMessageSpacing = [LeeAlertViewController appearance].sheetTitleMessageSpacing;
        self.isExtendBottomLayout = [LeeAlertViewController appearance].isExtendBottomLayout;
    }
}

- (void)setAlertButtonAttributes:(NSDictionary<NSString *,id> *)alertButtonAttributes {
    _alertButtonAttributes = alertButtonAttributes;
    _needsUpdateAction = YES;
}

- (void)setSheetButtonAttributes:(NSDictionary<NSString *,id> *)sheetButtonAttributes {
    _sheetButtonAttributes = sheetButtonAttributes;
    _needsUpdateAction = YES;
}

- (void)setAlertButtonDisabledAttributes:(NSDictionary<NSString *,id> *)alertButtonDisabledAttributes {
    _alertButtonDisabledAttributes = alertButtonDisabledAttributes;
    _needsUpdateAction = YES;
}

- (void)setSheetButtonDisabledAttributes:(NSDictionary<NSString *,id> *)sheetButtonDisabledAttributes {
    _sheetButtonDisabledAttributes = sheetButtonDisabledAttributes;
    _needsUpdateAction = YES;
}

- (void)setAlertCancelButtonAttributes:(NSDictionary<NSString *,id> *)alertCancelButtonAttributes {
    _alertCancelButtonAttributes = alertCancelButtonAttributes;
    _needsUpdateAction = YES;
}

- (void)setSheetCancelButtonAttributes:(NSDictionary<NSString *,id> *)sheetCancelButtonAttributes {
    _sheetCancelButtonAttributes = sheetCancelButtonAttributes;
    _needsUpdateAction = YES;
}

- (void)setAlertDestructiveButtonAttributes:(NSDictionary<NSString *,id> *)alertDestructiveButtonAttributes {
    _alertDestructiveButtonAttributes = alertDestructiveButtonAttributes;
    _needsUpdateAction = YES;
}

- (void)setSheetDestructiveButtonAttributes:(NSDictionary<NSString *,id> *)sheetDestructiveButtonAttributes {
    _sheetDestructiveButtonAttributes = sheetDestructiveButtonAttributes;
    _needsUpdateAction = YES;
}

- (void)setAlertButtonBackgroundColor:(UIColor *)alertButtonBackgroundColor {
    _alertButtonBackgroundColor = alertButtonBackgroundColor;
    _needsUpdateAction = YES;
}

- (void)setSheetButtonBackgroundColor:(UIColor *)sheetButtonBackgroundColor {
    _sheetButtonBackgroundColor = sheetButtonBackgroundColor;
    [self updateExtendLayerAppearance];
    _needsUpdateAction = YES;
}

- (void)setAlertButtonHighlightBackgroundColor:(UIColor *)alertButtonHighlightBackgroundColor {
    _alertButtonHighlightBackgroundColor = alertButtonHighlightBackgroundColor;
    _needsUpdateAction = YES;
}

- (void)setSheetButtonHighlightBackgroundColor:(UIColor *)sheetButtonHighlightBackgroundColor {
    _sheetButtonHighlightBackgroundColor = sheetButtonHighlightBackgroundColor;
    _needsUpdateAction = YES;
}

- (void)setAlertTitleAttributes:(NSDictionary<NSString *,id> *)alertTitleAttributes {
    _alertTitleAttributes = alertTitleAttributes;
    _needsUpdateTitle = YES;
}

- (void)setAlertMessageAttributes:(NSDictionary<NSString *,id> *)alertMessageAttributes {
    _alertMessageAttributes = alertMessageAttributes;
    _needsUpdateMessage = YES;
}

- (void)setSheetTitleAttributes:(NSDictionary<NSString *,id> *)sheetTitleAttributes {
    _sheetTitleAttributes = sheetTitleAttributes;
    _needsUpdateTitle = YES;
}

- (void)setSheetMessageAttributes:(NSDictionary<NSString *,id> *)sheetMessageAttributes {
    _sheetMessageAttributes = sheetMessageAttributes;
    _needsUpdateMessage = YES;
}

- (void)setAlertHeaderBackgroundColor:(UIColor *)alertHeaderBackgroundColor {
    _alertHeaderBackgroundColor = alertHeaderBackgroundColor;
    [self updateHeaderBackgrondColor];
}

- (void)setSheetHeaderBackgroundColor:(UIColor *)sheetHeaderBackgroundColor {
    _sheetHeaderBackgroundColor = sheetHeaderBackgroundColor;
    [self updateHeaderBackgrondColor];
}

- (void)updateHeaderBackgrondColor {
    if (self.preferredStyle == LeeAlertControllerStyleActionSheet) {
        if (self.headerScrollView) { self.headerScrollView.backgroundColor = self.sheetHeaderBackgroundColor; }
    } else if (self.preferredStyle == LeeAlertControllerStyleAlert) {
        if (self.headerScrollView) { self.headerScrollView.backgroundColor = self.alertHeaderBackgroundColor; }
    }
}

- (void)setAlertSeperatorColor:(UIColor *)alertSeperatorColor {
    _alertSeperatorColor = alertSeperatorColor;
    [self updateEffectBackgroundColor];
}

- (void)setSheetSeperatorColor:(UIColor *)sheetSeperatorColor {
    _sheetSeperatorColor = sheetSeperatorColor;
    [self updateEffectBackgroundColor];
}

- (void)updateEffectBackgroundColor {
    if (self.preferredStyle == LeeAlertControllerStyleAlert && self.alertSeperatorColor) {
        if (self.headerEffectView) { self.headerEffectView.backgroundColor = self.alertSeperatorColor; }
        if (self.cancelButtoneEffectView) { self.cancelButtoneEffectView.backgroundColor = self.alertSeperatorColor; }
    } else if (self.preferredStyle == LeeAlertControllerStyleActionSheet && self.sheetSeperatorColor) {
        if (self.headerEffectView) { self.headerEffectView.backgroundColor = self.sheetSeperatorColor; }
        if (self.cancelButtoneEffectView) { self.cancelButtoneEffectView.backgroundColor = self.sheetSeperatorColor; }
    }
}

- (void)setAlertContentCornerRadius:(CGFloat)alertContentCornerRadius {
    _alertContentCornerRadius = alertContentCornerRadius;
    [self updateCornerRadius];
}

- (void)setSheetContentCornerRadius:(CGFloat)sheetContentCornerRadius {
    _sheetContentCornerRadius = sheetContentCornerRadius;
    [self updateCornerRadius];
}

- (void)setIsExtendBottomLayout:(BOOL)isExtendBottomLayout {
    _isExtendBottomLayout = isExtendBottomLayout;
    if (isExtendBottomLayout) {
        self.extendLayer.hidden = NO;
        [self updateExtendLayerAppearance];
    } else {
        self.extendLayer.hidden = YES;
    }
}

- (void)updateExtendLayerAppearance {
    if (self.extendLayer) {
        self.extendLayer.backgroundColor = self.sheetButtonBackgroundColor.CGColor;
    }
}

- (void)updateCornerRadius {
    if (self.preferredStyle == LeeAlertControllerStyleAlert) {
        if (self.containerView) { self.containerView.layer.cornerRadius = self.alertContentCornerRadius; self.containerView.clipsToBounds = YES; }
        if (self.cancelButtoneEffectView) { self.cancelButtoneEffectView.layer.cornerRadius = 0; self.cancelButtoneEffectView.clipsToBounds = NO;}
        if (self.scrollWrapView) { self.scrollWrapView.layer.cornerRadius = 0; self.scrollWrapView.clipsToBounds = NO; }
    } else {
        if (self.containerView) { self.containerView.layer.cornerRadius = 0; self.containerView.clipsToBounds = NO; }
        if (self.cancelButtoneEffectView) { self.cancelButtoneEffectView.layer.cornerRadius = self.sheetContentCornerRadius; self.cancelButtoneEffectView.clipsToBounds = YES; }
        if (self.scrollWrapView) { self.scrollWrapView.layer.cornerRadius = self.sheetContentCornerRadius; self.scrollWrapView.clipsToBounds = YES; }
    }
}

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(LeeAlertControllerStyle)preferredStyle {
    LeeAlertViewController *alertController = [[self alloc] initWithTitle:title message:message preferredStyle:preferredStyle];
    if (alertController) {
        return alertController;
    }
    return nil;
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(LeeAlertControllerStyle)preferredStyle {
    self = [self init];
    if (self) {
        
        self.isShowing = NO;
        self.shouldRespondMaskViewTouch = preferredStyle == LeeAlertControllerStyleActionSheet;
        
        self.alertActions = [[NSMutableArray alloc] init];
        self.alertTextFields = [[NSMutableArray alloc] init];
        self.destructiveActions = [[NSMutableArray alloc] init];
        
        self.containerView = [[UIView alloc] init];
        
        self.maskView = [[UIControl alloc] init];
        self.maskView.alpha = 0;
        self.maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.35f];
        [self.maskView addTarget:self action:@selector(handleMaskViewEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        self.scrollWrapView = [[UIView alloc] init];
        self.headerEffectView = [[UIView alloc] init];
        self.cancelButtoneEffectView = [[UIView alloc] init];
        self.headerScrollView = [[UIScrollView alloc] init];
        self.buttonScrollView = [[UIScrollView alloc] init];
        
        self.extendLayer = [CALayer layer];
        self.extendLayer.hidden = !self.isExtendBottomLayout;
        [self.extendLayer lee_removeDefaultAnimations];
        
        self.title = title;
        self.message = message;
        self.preferredStyle = preferredStyle;
        
        [self updateHeaderBackgrondColor];
        [self updateEffectBackgroundColor];
        [self updateCornerRadius];
        [self updateExtendLayerAppearance];
        
    }
    return self;
}

- (void)setPreferredStyle:(LeeAlertControllerStyle)preferredStyle {
    _preferredStyle = [self isIPad] ? LeeAlertControllerStyleAlert : preferredStyle;
}

- (BOOL)isIPad {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.maskView];
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.scrollWrapView];
    [self.scrollWrapView addSubview:self.headerEffectView];
    [self.scrollWrapView addSubview:self.headerScrollView];
    [self.scrollWrapView addSubview:self.buttonScrollView];
    [self.containerView.layer addSublayer:self.extendLayer];
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    BOOL hasTitle = (self.titleLabel.text.length > 0 && !self.titleLabel.hidden);
    BOOL hasMessage = (self.messageLabel.text.length > 0 && !self.messageLabel.hidden);
    BOOL hasTextField = self.alertTextFields.count > 0;
    BOOL hasCustomView = !!_customView;
    CGFloat contentOriginY = 0;
    
    self.maskView.frame = self.view.bounds;
    
    if (self.preferredStyle == LeeAlertControllerStyleAlert) {
        
        CGFloat contentPaddingLeft = self.alertHeaderInsets.left;
        CGFloat contentPaddingRight = self.alertHeaderInsets.right;
        
        CGFloat contentPaddingTop = (hasTitle || hasMessage || hasTextField || hasCustomView) ? self.alertHeaderInsets.top : 0;
        CGFloat contentPaddingBottom = (hasTitle || hasMessage || hasTextField || hasCustomView) ? self.alertHeaderInsets.bottom : 0;
        self.containerView.lee_width = fmin(self.alertContentMaximumWidth, CGRectGetWidth(self.view.bounds) - self.alertContentMargin.left - self.alertContentMargin.right);
        self.scrollWrapView.lee_width = CGRectGetWidth(self.containerView.bounds);
        self.headerScrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.scrollWrapView.bounds), 0);
        contentOriginY = contentPaddingTop;
        // 标题和副标题布局
        if (hasTitle) {
            CGFloat titleLabelLimitWidth = CGRectGetWidth(self.headerScrollView.bounds) - contentPaddingLeft - contentPaddingRight;
            CGSize titleLabelSize = [self.titleLabel sizeThatFits:CGSizeMake(titleLabelLimitWidth, CGFLOAT_MAX)];
            self.titleLabel.frame = CGRectMake(contentPaddingLeft, contentOriginY, titleLabelLimitWidth, titleLabelSize.height);
            contentOriginY = CGRectGetMaxY(self.titleLabel.frame) + (hasMessage ? self.alertTitleMessageSpacing : contentPaddingBottom);
        }
        if (hasMessage) {
            CGFloat messageLabelLimitWidth = CGRectGetWidth(self.headerScrollView.bounds) - contentPaddingLeft - contentPaddingRight;
            CGSize messageLabelSize = [self.messageLabel sizeThatFits:CGSizeMake(messageLabelLimitWidth, CGFLOAT_MAX)];
            self.messageLabel.frame = CGRectMake(contentPaddingLeft, contentOriginY, messageLabelLimitWidth, messageLabelSize.height);
            contentOriginY = CGRectGetMaxY(self.messageLabel.frame) + contentPaddingBottom;
        }
        // 输入框布局
        if (hasTextField) {
            for (int i = 0; i < self.alertTextFields.count; i++) {
                UITextField *textField = self.alertTextFields[i];
                textField.frame = CGRectMake(contentPaddingLeft, contentOriginY, CGRectGetWidth(self.headerScrollView.bounds) - contentPaddingLeft - contentPaddingRight, 25);
                contentOriginY = CGRectGetMaxY(textField.frame) - 1;
            }
            contentOriginY += 16;
        }
        // 自定义view的布局 - 自动居中
        if (hasCustomView) {
            CGSize customViewSize = [_customView sizeThatFits:CGSizeMake(CGRectGetWidth(self.headerScrollView.bounds), CGFLOAT_MAX)];
            _customView.frame = CGRectMake((CGRectGetWidth(self.headerScrollView.bounds) - customViewSize.width) / 2, contentOriginY, customViewSize.width, customViewSize.height);
            contentOriginY = CGRectGetMaxY(_customView.frame) + contentPaddingBottom;
        }
        // 内容scrollView的布局
        self.headerScrollView.frame = CGRectMake(self.headerScrollView.frame.origin.x, self.headerScrollView.frame.origin.y, self.headerScrollView.frame.size.width, contentOriginY);
        self.headerScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.headerScrollView.bounds), contentOriginY);
        contentOriginY = CGRectGetMaxY(self.headerScrollView.frame);
        // 按钮布局
        self.buttonScrollView.frame = CGRectMake(0, contentOriginY, CGRectGetWidth(self.containerView.bounds), 0);
        contentOriginY = 0;
        NSArray *newOrderActions = [self orderedAlertActions:self.alertActions];
        if (self.alertActions.count > 0) {
            BOOL verticalLayout = YES;
            if (self.alertActions.count == 2) {
                CGFloat halfWidth = CGRectGetWidth(self.buttonScrollView.bounds) / 2;
                LeeAlertAction *action1 = newOrderActions[0];
                LeeAlertAction *action2 = newOrderActions[1];
                CGSize actionSize1 = [action1.button sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
                CGSize actionSize2 = [action2.button sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
                if (actionSize1.width < halfWidth && actionSize2.width < halfWidth) {
                    verticalLayout = NO;
                }
            }
            if (!verticalLayout) {
                LeeAlertAction *action1 = newOrderActions[1];
                action1.buttonWrapView.frame = CGRectMake(0, contentOriginY + 1, CGRectGetWidth(self.buttonScrollView.bounds) / 2, self.alertButtonHeight);
                LeeAlertAction *action2 = newOrderActions[0];
                action2.buttonWrapView.frame = CGRectMake(CGRectGetMaxX(action1.buttonWrapView.frame) + 1, contentOriginY + 1, CGRectGetWidth(self.buttonScrollView.bounds) / 2 - 1, self.alertButtonHeight);
                contentOriginY = CGRectGetMaxY(action1.buttonWrapView.frame);
            }
            else {
                for (int i = 0; i < newOrderActions.count; i++) {
                    LeeAlertAction *action = newOrderActions[i];
                    action.buttonWrapView.frame = CGRectMake(0, contentOriginY + 1, CGRectGetWidth(self.containerView.bounds), self.alertButtonHeight - 1);
                    contentOriginY = CGRectGetMaxY(action.buttonWrapView.frame);
                }
            }
        }
        // 按钮scrollView的布局
        self.buttonScrollView.frame = CGRectMake(self.buttonScrollView.frame.origin.x, self.buttonScrollView.frame.origin.y, self.buttonScrollView.frame.size.width, contentOriginY);
        self.buttonScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.buttonScrollView.bounds), contentOriginY);
        // 容器最后布局
        CGFloat contentHeight = CGRectGetHeight(self.headerScrollView.bounds) + CGRectGetHeight(self.buttonScrollView.bounds);
        CGFloat screenSpaceHeight = CGRectGetHeight(self.view.bounds);
        if (contentHeight > screenSpaceHeight - 20) {
            screenSpaceHeight -= 20;
            CGFloat contentH = fmin(CGRectGetHeight(self.headerScrollView.bounds), screenSpaceHeight / 2);
            CGFloat buttonH = fmin(CGRectGetHeight(self.buttonScrollView.bounds), screenSpaceHeight / 2);
            if (contentH >= screenSpaceHeight / 2 && buttonH >= screenSpaceHeight / 2) {
                self.headerScrollView.frame = CGRectMake(self.headerScrollView.frame.origin.x, self.headerScrollView.frame.origin.y, self.headerScrollView.frame.size.width, screenSpaceHeight / 2);
                self.buttonScrollView.frame = CGRectMake(self.headerScrollView.frame.origin.x, CGRectGetMaxY(self.headerScrollView.frame), self.buttonScrollView.frame.size.width, self.buttonScrollView.frame.size.height);
                self.buttonScrollView.frame = CGRectMake(self.buttonScrollView.frame.origin.x, self.buttonScrollView.frame.origin.y, self.buttonScrollView.frame.size.width, screenSpaceHeight / 2);
            } else if (contentH < screenSpaceHeight / 2) {
                self.headerScrollView.frame = CGRectMake(self.headerScrollView.frame.origin.x, self.headerScrollView.frame.origin.y, self.headerScrollView.frame.size.width, contentH);
                self.buttonScrollView.frame = CGRectMake(self.buttonScrollView.frame.origin.x, CGRectGetMaxY(self.headerScrollView.frame), self.buttonScrollView.frame.size.width, self.buttonScrollView.frame.size.height);
                self.buttonScrollView.frame = CGRectMake(self.buttonScrollView.frame.origin.x, self.buttonScrollView.frame.origin.y, self.buttonScrollView.frame.size.width, screenSpaceHeight - contentH);
            } else if (buttonH < screenSpaceHeight / 2) {
                self.headerScrollView.frame = CGRectMake(self.headerScrollView.frame.origin.x, self.headerScrollView.frame.origin.y, self.headerScrollView.frame.size.width, screenSpaceHeight - buttonH);
                self.buttonScrollView.frame = CGRectMake(self.buttonScrollView.frame.origin.x, CGRectGetMaxY(self.headerScrollView.frame), self.buttonScrollView.frame.size.width, self.buttonScrollView.frame.size.height);
                self.buttonScrollView.frame = CGRectMake(self.buttonScrollView.frame.origin.x, self.buttonScrollView.frame.origin.y, self.buttonScrollView.frame.size.width, buttonH);
            }
            contentHeight = CGRectGetHeight(self.headerScrollView.bounds) + CGRectGetHeight(self.buttonScrollView.bounds);
            screenSpaceHeight += 20;
        }
        self.scrollWrapView.frame =  CGRectMake(0, 0, CGRectGetWidth(self.scrollWrapView.bounds), contentHeight);
        self.headerEffectView.frame = self.scrollWrapView.bounds;
        
        CGRect containerRect = CGRectMake((CGRectGetWidth(self.view.bounds) - CGRectGetWidth(self.containerView.bounds)) / 2, (screenSpaceHeight - contentHeight - self.keyboardHeight) / 2, CGRectGetWidth(self.containerView.bounds), CGRectGetHeight(self.scrollWrapView.bounds));
        self.containerView.frame = CGRectApplyAffineTransform(containerRect, self.containerView.transform);
    }
    
    else if (self.preferredStyle == LeeAlertControllerStyleActionSheet) {
        
        CGFloat contentPaddingLeft = self.alertHeaderInsets.left;
        CGFloat contentPaddingRight = self.alertHeaderInsets.right;
        
        CGFloat contentPaddingTop = (hasTitle || hasMessage || hasTextField) ? self.sheetHeaderInsets.top : 0;
        CGFloat contentPaddingBottom = (hasTitle || hasMessage || hasTextField) ? self.sheetHeaderInsets.bottom : 0;
        self.containerView.lee_width = fmin(self.sheetContentMaximumWidth, CGRectGetWidth(self.view.bounds) - self.sheetContentMargin.left - self.sheetContentMargin.right);
        self.scrollWrapView.lee_width = CGRectGetWidth(self.containerView.bounds);
        self.headerScrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.containerView.bounds), 0);
        contentOriginY = contentPaddingTop;
        // 标题和副标题布局
        if (hasTitle) {
            CGFloat titleLabelLimitWidth = CGRectGetWidth(self.headerScrollView.bounds) - contentPaddingLeft - contentPaddingRight;
            CGSize titleLabelSize = [self.titleLabel sizeThatFits:CGSizeMake(titleLabelLimitWidth, CGFLOAT_MAX)];
            self.titleLabel.frame = CGRectMake(contentPaddingLeft, contentOriginY, titleLabelLimitWidth, titleLabelSize.height);
            contentOriginY = CGRectGetMaxY(self.titleLabel.frame) + (hasMessage ? self.sheetTitleMessageSpacing : contentPaddingBottom);
        }
        if (hasMessage) {
            CGFloat messageLabelLimitWidth = CGRectGetWidth(self.headerScrollView.bounds) - contentPaddingLeft - contentPaddingRight;
            CGSize messageLabelSize = [self.messageLabel sizeThatFits:CGSizeMake(messageLabelLimitWidth, CGFLOAT_MAX)];
            self.messageLabel.frame = CGRectMake(contentPaddingLeft, contentOriginY, messageLabelLimitWidth, messageLabelSize.height);
            contentOriginY = CGRectGetMaxY(self.messageLabel.frame) + contentPaddingBottom;
        }
        // 自定义view的布局 - 自动居中
        if (hasCustomView) {
            CGSize customViewSize = [_customView sizeThatFits:CGSizeMake(CGRectGetWidth(self.headerScrollView.bounds), CGFLOAT_MAX)];
            _customView.frame = CGRectMake((CGRectGetWidth(self.headerScrollView.bounds) - customViewSize.width) / 2, contentOriginY, customViewSize.width, customViewSize.height);
            contentOriginY = CGRectGetMaxY(_customView.frame) + contentPaddingBottom;
        }
        // 内容scrollView布局
        self.headerScrollView.frame = CGRectMake(self.headerScrollView.frame.origin.x, self.headerScrollView.frame.origin.y, self.headerScrollView.frame.size.width, contentOriginY);
        self.headerScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.headerScrollView.bounds), contentOriginY);
        contentOriginY = CGRectGetMaxY(self.headerScrollView.frame);
        // 按钮的布局
        self.buttonScrollView.frame = CGRectMake(0, contentOriginY, CGRectGetWidth(self.containerView.bounds), 0);
        contentOriginY = 0;
        NSArray *newOrderActions = [self orderedAlertActions:self.alertActions];
        if (self.alertActions.count > 0) {
            contentOriginY = (hasTitle || hasMessage || hasCustomView) ? contentOriginY + 1 : contentOriginY;
            for (int i = 0; i < newOrderActions.count; i++) {
                LeeAlertAction *action = newOrderActions[i];
                if (action.style == LeeAlertActionStyleCancel && i == newOrderActions.count - 1) {
                    continue;
                } else {
                    action.buttonWrapView.frame = CGRectMake(0, contentOriginY, CGRectGetWidth(self.buttonScrollView.bounds), self.sheetButtonHeight - 1);
                    contentOriginY = CGRectGetMaxY(action.buttonWrapView.frame) + 1;
                }
            }
            contentOriginY -= 1;
        }
        // 按钮scrollView布局
        self.buttonScrollView.frame = CGRectMake(self.buttonScrollView.frame.origin.x, self.buttonScrollView.frame.origin.y, self.buttonScrollView.frame.size.width, contentOriginY);
        self.buttonScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.buttonScrollView.bounds), contentOriginY);
        // 容器最终布局
        self.scrollWrapView.frame =  CGRectMake(0, 0, CGRectGetWidth(self.scrollWrapView.bounds), CGRectGetMaxY(self.buttonScrollView.frame));
        self.headerEffectView.frame = self.scrollWrapView.bounds;
        contentOriginY = CGRectGetMaxY(self.scrollWrapView.frame) + self.sheetCancelButtonMarginTop;
        if (self.cancelAction) {
            self.cancelButtoneEffectView.frame = CGRectMake(0, contentOriginY, CGRectGetWidth(self.containerView.bounds), self.sheetButtonHeight);
            self.cancelAction.buttonWrapView.frame = self.cancelButtoneEffectView.bounds;
            contentOriginY = CGRectGetMaxY(self.cancelButtoneEffectView.frame);
        }
        // 把上下的margin都加上用于跟整个屏幕的高度做比较
        CGFloat contentHeight = contentOriginY + self.sheetContentMargin.top + self.sheetContentMargin.bottom;
        CGFloat screenSpaceHeight = CGRectGetHeight(self.view.bounds);
        if (contentHeight > screenSpaceHeight) {
            CGFloat cancelButtonAreaHeight = (self.cancelAction ? (CGRectGetHeight(self.cancelAction.buttonWrapView.bounds) + self.sheetCancelButtonMarginTop) : 0);
            screenSpaceHeight = screenSpaceHeight - cancelButtonAreaHeight - self.sheetContentMargin.top - self.sheetContentMargin.bottom;
            CGFloat contentH = MIN(CGRectGetHeight(self.headerScrollView.bounds), screenSpaceHeight / 2);
            CGFloat buttonH = MIN(CGRectGetHeight(self.buttonScrollView.bounds), screenSpaceHeight / 2);
            if (contentH >= screenSpaceHeight / 2 && buttonH >= screenSpaceHeight / 2) {
                self.headerScrollView.lee_height = screenSpaceHeight / 2;
                self.buttonScrollView.lee_top = CGRectGetMaxY(self.headerScrollView.frame);
                self.buttonScrollView.lee_height =  screenSpaceHeight / 2;
            } else if (contentH < screenSpaceHeight / 2) {
                self.headerScrollView.lee_height = contentH;
                self.buttonScrollView.lee_top =  CGRectGetMaxY(self.headerScrollView.frame);
                self.buttonScrollView.lee_height =  screenSpaceHeight - contentH;
            } else if (buttonH < screenSpaceHeight / 2) {
                self.headerScrollView.lee_height =  screenSpaceHeight - buttonH;
                self.buttonScrollView.lee_top =  CGRectGetMaxY(self.headerScrollView.frame);
                self.buttonScrollView.lee_height = buttonH;
            }
            self.scrollWrapView.lee_height =   CGRectGetHeight(self.headerScrollView.bounds) + CGRectGetHeight(self.buttonScrollView.bounds);
            if (self.cancelAction) {
                self.cancelButtoneEffectView.lee_top =  CGRectGetMaxY(self.scrollWrapView.frame) + self.sheetCancelButtonMarginTop;
            }
            contentHeight = CGRectGetHeight(self.headerScrollView.bounds) + CGRectGetHeight(self.buttonScrollView.bounds) + cancelButtonAreaHeight + self.sheetContentMargin.bottom;
            screenSpaceHeight += (cancelButtonAreaHeight + self.sheetContentMargin.top + self.sheetContentMargin.bottom);
        } else {
            // 如果小于屏幕高度，则把顶部的top减掉
            contentHeight -= self.sheetContentMargin.top;
        }
        
        CGRect containerRect = CGRectMake((CGRectGetWidth(self.view.bounds) - CGRectGetWidth(self.containerView.bounds)) / 2, screenSpaceHeight - contentHeight - [self safeAreaInsetsForIPhoneX].bottom, CGRectGetWidth(self.containerView.bounds), contentHeight + (self.isExtendBottomLayout ? [self safeAreaInsetsForIPhoneX].bottom : 0));
        self.containerView.frame = CGRectApplyAffineTransform(containerRect, self.containerView.transform);
        
        self.extendLayer.frame = CGRectMake(0, CGRectGetHeight(self.containerView.bounds) - [self safeAreaInsetsForIPhoneX].bottom - 1, CGRectGetWidth(self.containerView.bounds), [self safeAreaInsetsForIPhoneX].bottom + 1);
    }
}

- (UIEdgeInsets)safeAreaInsetsForIPhoneX {
    if (!CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(375, 812))) {
        return UIEdgeInsetsZero;
    }
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return UIEdgeInsetsMake(44, 0, 34, 0);
            
        case UIInterfaceOrientationPortraitUpsideDown:
            return UIEdgeInsetsMake(34, 0, 44, 0);
            
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            return UIEdgeInsetsMake(0, 44, 21, 44);
            
        case UIInterfaceOrientationUnknown:
        default:
            return UIEdgeInsetsMake(44, 0, 34, 0);
    }
}

- (NSArray *)orderedAlertActions:(NSArray *)actions {
    NSMutableArray<LeeAlertAction *> *newActions = [[NSMutableArray alloc] init];
    // 按照用户addAction的先后顺序来排序
    if (self.orderActionsByAddedOrdered) {
        [newActions addObjectsFromArray:self.alertActions];
        // 取消按钮不参与排序，所以先移除，在最后再重新添加
        if (self.cancelAction) {
            [newActions removeObject:self.cancelAction];
        }
    } else {
        for (LeeAlertAction *action in self.alertActions) {
            if (action.style != LeeAlertActionStyleCancel && action.style != LeeAlertActionStyleDestructive) {
                [newActions addObject:action];
            }
        }
        for (LeeAlertAction *action in self.destructiveActions) {
            [newActions addObject:action];
        }
    }
    if (self.cancelAction) {
        [newActions addObject:self.cancelAction];
    }
    return newActions;
}

- (void)initModalPresentationController {
    _modalPresentationViewController = [[LeeModalPresentationViewController alloc] init];
    self.modalPresentationViewController.delegate = self;
    self.modalPresentationViewController.maximumContentViewWidth = CGFLOAT_MAX;
    self.modalPresentationViewController.contentViewMargins = UIEdgeInsetsZero;
    self.modalPresentationViewController.dimmingView = nil;
    self.modalPresentationViewController.contentViewController = self;
    [self customModalPresentationControllerAnimation];
}

- (void)customModalPresentationControllerAnimation {
    
    __weak __typeof(self)weakSelf = self;
    
    self.modalPresentationViewController.layoutBlock = ^(CGRect containerBounds, CGFloat keyboardHeight, CGRect contentViewDefaultFrame) {
        weakSelf.view.frame = CGRectMake(0, 0, CGRectGetWidth(containerBounds), CGRectGetHeight(containerBounds));
        weakSelf.keyboardHeight = keyboardHeight;
        [weakSelf.view setNeedsLayout];
    };
    
    self.modalPresentationViewController.showingAnimation = ^(UIView *dimmingView, CGRect containerBounds, CGFloat keyboardHeight, CGRect contentViewFrame, void(^completion)(BOOL finished)) {
        if (self.preferredStyle == LeeAlertControllerStyleAlert) {
            weakSelf.containerView.alpha = 0;
            weakSelf.containerView.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1.0);
            [UIView animateWithDuration:0.25f delay:0 options:7 << 16 animations:^{
                weakSelf.maskView.alpha = 1;
                weakSelf.containerView.alpha = 1;
                weakSelf.containerView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0);
            } completion:^(BOOL finished) {
                if (completion) {
                    completion(finished);
                }
            }];
        } else if (self.preferredStyle == LeeAlertControllerStyleActionSheet) {
            weakSelf.containerView.layer.transform = CATransform3DMakeTranslation(0, CGRectGetHeight(weakSelf.containerView.bounds), 0);
            [UIView animateWithDuration:0.25f delay:0 options:7 << 16 animations:^{
                weakSelf.maskView.alpha = 1;
                weakSelf.containerView.layer.transform = CATransform3DIdentity;
            } completion:^(BOOL finished) {
                if (completion) {
                    completion(finished);
                }
            }];
        }
    };
    
    self.modalPresentationViewController.hidingAnimation = ^(UIView *dimmingView, CGRect containerBounds, CGFloat keyboardHeight, void(^completion)(BOOL finished)) {
        if (self.preferredStyle == LeeAlertControllerStyleAlert) {
            [UIView animateWithDuration:0.25f delay:0 options:7 << 16 animations:^{
                weakSelf.maskView.alpha = 0;
                weakSelf.containerView.alpha = 0;
            } completion:^(BOOL finished) {
                weakSelf.containerView.alpha = 1;
                if (completion) {
                    completion(finished);
                }
            }];
        } else if (self.preferredStyle == LeeAlertControllerStyleActionSheet) {
            [UIView animateWithDuration:0.25f delay:0 options:7 << 16 animations:^{
                weakSelf.maskView.alpha = 0;
                weakSelf.containerView.layer.transform = CATransform3DMakeTranslation(0, CGRectGetHeight(weakSelf.containerView.bounds), 0);
            } completion:^(BOOL finished) {
                if (completion) {
                    completion(finished);
                }
            }];
        }
    };
}

- (void)showWithAnimated:(BOOL)animated {
    if (self.isShowing) {
        return;
    }
    if (self.alertTextFields.count > 0) {
        [self.alertTextFields.firstObject becomeFirstResponder];
    }
    if (_needsUpdateAction) {
        [self updateAction];
    }
    if (_needsUpdateTitle) {
        [self updateTitleLabel];
    }
    if (_needsUpdateMessage) {
        [self updateMessageLabel];
    }
    
    [self initModalPresentationController];
    
    if ([self.delegate respondsToSelector:@selector(willShowAlertController:)]) {
        [self.delegate willShowAlertController:self];
    }
    
    __weak __typeof(self)weakSelf = self;
    
    [self.modalPresentationViewController showWithAnimated:animated completion:^(BOOL finished) {
        weakSelf.maskView.alpha = 1;
        weakSelf.isShowing = YES;
        if (self.isNeedsHideAfterAlertShowed) {
            [self hideWithAnimated:self.isAnimatedForHideAfterAlertShowed];
            self.isNeedsHideAfterAlertShowed = NO;
            self.isAnimatedForHideAfterAlertShowed = NO;
        }
        if ([weakSelf.delegate respondsToSelector:@selector(didShowAlertController:)]) {
            [weakSelf.delegate didShowAlertController:weakSelf];
        }
    }];
    
    // 增加alertController计数
    alertControllerCount++;
}

- (void)hideWithAnimated:(BOOL)animated {
    [self hideWithAnimated:animated completion:NULL];
}

- (void)hideWithAnimated:(BOOL)animated completion:(void (^)(void))completion {
    if (!self.isShowing) {
        self.isNeedsHideAfterAlertShowed = YES;
        self.isAnimatedForHideAfterAlertShowed = animated;
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(willHideAlertController:)]) {
        [self.delegate willHideAlertController:self];
    }
    
    __weak __typeof(self)weakSelf = self;
    
    [self.modalPresentationViewController hideWithAnimated:animated completion:^(BOOL finished) {
        weakSelf.modalPresentationViewController = nil;
        weakSelf.isShowing = NO;
        weakSelf.maskView.alpha = 0;
        if (self.preferredStyle == LeeAlertControllerStyleAlert) {
            weakSelf.containerView.alpha = 0;
        } else {
            weakSelf.containerView.layer.transform = CATransform3DMakeTranslation(0, CGRectGetHeight(weakSelf.containerView.bounds), 0);
        }
        if ([weakSelf.delegate respondsToSelector:@selector(didHideAlertController:)]) {
            [weakSelf.delegate didHideAlertController:weakSelf];
        }
        if (completion) {
            completion();
        }
    }];
    
    // 减少alertController计数
    alertControllerCount--;
}

- (void)addAction:(LeeAlertAction *)action {
    if (action.style == LeeAlertActionStyleCancel && self.cancelAction) {
        [NSException raise:@"QMUIAlertController使用错误" format:@"同一个alertController不可以同时添加两个cancel按钮"];
    }
    if (action.style == LeeAlertActionStyleCancel) {
        self.cancelAction = action;
    }
    if (action.style == LeeAlertActionStyleDestructive) {
        [self.destructiveActions addObject:action];
    }
    // 只有ActionSheet的取消按钮不参与滚动
    if (self.preferredStyle == LeeAlertControllerStyleActionSheet && action.style == LeeAlertActionStyleCancel && ![self isIPad]) {
        if (!self.cancelButtoneEffectView.superview) {
            [self.containerView addSubview:self.cancelButtoneEffectView];
        }
        [self.cancelButtoneEffectView addSubview:action.buttonWrapView];
    } else {
        [self.buttonScrollView addSubview:action.buttonWrapView];
    }
    action.delegate = self;
    [self.alertActions addObject:action];
}

- (void)addCancelAction {
    LeeAlertAction *action = [LeeAlertAction actionWithTitle:@"取消" style:LeeAlertActionStyleCancel handler:nil];
    [self addAction:action];
}

- (void)addTextFieldWithConfigurationHandler:(void (^)(LeeUITextField *textField))configurationHandler {
    if (_customView) {
        [NSException raise:@"LeeAlertController使用错误" format:@"UITextField和CustomView不能共存"];
    }
    if (self.preferredStyle == LeeAlertControllerStyleActionSheet) {
        [NSException raise:@"LeeAlertController使用错误" format:@"Sheet类型不运行添加UITextField"];
    }
    LeeUITextField *textField = [[LeeUITextField alloc] init];
    textField.borderStyle = UITextBorderStyleNone;
    textField.backgroundColor = [UIColor whiteColor];
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.font = [UIFont systemFontOfSize:14];
    textField.textColor = [UIColor blackColor];
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.layer.borderColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1].CGColor;
    textField.layer.borderWidth = 1;
    [self.headerScrollView addSubview:textField];
    [self.alertTextFields addObject:textField];
    if (configurationHandler) {
        configurationHandler(textField);
    }
}

- (void)addCustomView:(UIView *)view {
    if (self.alertTextFields.count > 0) {
        [NSException raise:@"LeeAlertController使用错误" format:@"UITextField和CustomView不能共存"];
    }
    _customView = view;
    [self.headerScrollView addSubview:_customView];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    if (!self.titleLabel) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.numberOfLines = 0;
        [self.headerScrollView addSubview:self.titleLabel];
    }
    if (!_title || [_title isEqualToString:@""]) {
        self.titleLabel.hidden = YES;
    } else {
        self.titleLabel.hidden = NO;
        [self updateTitleLabel];
    }
}

- (NSString *)title {
    return _title;
}

- (void)updateTitleLabel {
    if (self.titleLabel && !self.titleLabel.hidden) {
        NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:self.title attributes:self.preferredStyle == LeeAlertControllerStyleAlert ? self.alertTitleAttributes : self.sheetTitleAttributes];
        self.titleLabel.attributedText = attributeString;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
}

- (void)setMessage:(NSString *)message {
    _message = message;
    if (!self.messageLabel) {
        self.messageLabel = [[UILabel alloc] init];
        self.messageLabel.numberOfLines = 0;
        [self.headerScrollView addSubview:self.messageLabel];
    }
    if (!_message || [_message isEqualToString:@""]) {
        self.messageLabel.hidden = YES;
    } else {
        self.messageLabel.hidden = NO;
        [self updateMessageLabel];
    }
}

- (void)updateMessageLabel {
    if (self.messageLabel && !self.messageLabel.hidden) {
        NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:self.message attributes:self.preferredStyle == LeeAlertControllerStyleAlert ? self.alertMessageAttributes : self.sheetMessageAttributes];
        self.messageLabel.attributedText = attributeString;
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
    }
}

- (NSArray *)actions {
    return self.alertActions;
}

- (void)updateAction {
    
    for (LeeAlertAction *alertAction in self.alertActions) {
        
        UIColor *backgroundColor = self.preferredStyle == LeeAlertControllerStyleAlert ? self.alertButtonBackgroundColor : self.sheetButtonBackgroundColor;
        UIColor *highlightBackgroundColor = self.preferredStyle == LeeAlertControllerStyleAlert ? self.alertButtonHighlightBackgroundColor : self.sheetButtonHighlightBackgroundColor;
        
        alertAction.buttonWrapView.clipsToBounds = alertAction.style == LeeAlertActionStyleCancel;
        alertAction.button.backgroundColor = backgroundColor;
        alertAction.button.highlightedBackgroundColor = highlightBackgroundColor;
        
        NSAttributedString *attributeString = nil;
        if (alertAction.style == LeeAlertActionStyleCancel) {
            
            NSDictionary *attributes = (self.preferredStyle == LeeAlertControllerStyleAlert) ? self.alertCancelButtonAttributes : self.sheetCancelButtonAttributes;
            if (alertAction.buttonAttributes) {
                attributes = alertAction.buttonAttributes;
            }
            
            attributeString = [[NSAttributedString alloc] initWithString:alertAction.title attributes:attributes];
            
        } else if (alertAction.style == LeeAlertActionStyleDestructive) {
            
            NSDictionary *attributes = (self.preferredStyle == LeeAlertControllerStyleAlert) ? self.alertDestructiveButtonAttributes : self.sheetDestructiveButtonAttributes;
            if (alertAction.buttonAttributes) {
                attributes = alertAction.buttonAttributes;
            }
            
            attributeString = [[NSAttributedString alloc] initWithString:alertAction.title attributes:attributes];
            
        } else {
            
            NSDictionary *attributes = (self.preferredStyle == LeeAlertControllerStyleAlert) ? self.alertButtonAttributes : self.sheetButtonAttributes;
            if (alertAction.buttonAttributes) {
                attributes = alertAction.buttonAttributes;
            }
            
            attributeString = [[NSAttributedString alloc] initWithString:alertAction.title attributes:attributes];
        }
        
        [alertAction.button setAttributedTitle:attributeString forState:UIControlStateNormal];
        
        NSDictionary *attributes = (self.preferredStyle == LeeAlertControllerStyleAlert) ? self.alertButtonDisabledAttributes : self.sheetButtonDisabledAttributes;
        if (alertAction.buttonDisabledAttributes) {
            attributes = alertAction.buttonDisabledAttributes;
        }
        
        attributeString = [[NSAttributedString alloc] initWithString:alertAction.title attributes:attributes];
        [alertAction.button setAttributedTitle:attributeString forState:UIControlStateDisabled];
        
        if ([alertAction.button imageForState:UIControlStateNormal]) {
            NSRange range = NSMakeRange(0, attributeString.length);
            UIColor *disabledColor = [attributeString attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:&range];
            [alertAction.button setImage:[[alertAction.button imageForState:UIControlStateNormal] lee_imageWithTintColor:disabledColor] forState:UIControlStateDisabled];
        }
    }
}

- (NSArray *)textFields {
    return self.alertTextFields;
}

- (void)handleMaskViewEvent:(id)sender {
    if (_shouldRespondMaskViewTouch) {
        [self hideWithAnimated:YES completion:NULL];
    }
}

#pragma mark - <LeeAlertActionDelegate>

- (void)didClickAlertAction:(LeeAlertAction *)alertAction {
    [self hideWithAnimated:YES completion:^{
        if (alertAction.handler) {
            alertAction.handler(alertAction);
            alertAction.handler = nil;
        }
    }];
}

#pragma mark - <LeeModalPresentationViewControllerDelegate>

- (void)requestHideAllModalPresentationViewController {
    [self hideWithAnimated:NO completion:NULL];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

@implementation LeeAlertViewController (Manager)

+ (BOOL)isAnyAlertControllerVisible {
    return alertControllerCount > 0;
}

@end
