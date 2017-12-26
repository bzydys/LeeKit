//
//  LeeCustomNavigationBar.m
//  LeeKit
//
//  Created by Lee on 2017/12/15.
//  Copyright © 2017年 Lee. All rights reserved.
//

#import "LeeCustomNavigationBar.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kNavHeight 44
#define kStatusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height


/**
 默认跳转方式
 */
@implementation UIViewController(route)

-(void)lee_toLastViewController{
    //如果是push方式
    if (self.navigationController) {
        if (self.navigationController.viewControllers.count == 1) {
            if (self.presentingViewController) {
                
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else if(self.presentingViewController){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

+ (UIViewController*)lee_currentViewController{
    
    UIViewController* rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    return [self lee_currentViewControllerFrom:rootViewController];
}

+ (UIViewController*)lee_currentViewControllerFrom:(UIViewController*)viewController{
    
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController *)viewController;
        return [self lee_currentViewControllerFrom:navigationController.viewControllers.lastObject];
    }
    else if([viewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController *)viewController;
        return [self lee_currentViewControllerFrom:tabBarController.selectedViewController];
    }
    else if (viewController.presentedViewController != nil) {
        return [self lee_currentViewControllerFrom:viewController.presentedViewController];
    }
    else {
        return viewController;
    }
}

@end



@interface LeeCustomNavigationBar()

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIButton *leftButton;
@property(nonatomic, strong) UIButton *rightButton;
@property(nonatomic, strong) UIView *bottomLine;
@property(nonatomic, strong) UIView *backgroundView;
@property(nonatomic, strong) UIImageView *backgroundImageView;

@end

@implementation LeeCustomNavigationBar

+(instancetype)customNavigationBar{
    LeeCustomNavigationBar *navigationBar = [[self alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kStatusBarHeight + kNavHeight)];
    return navigationBar;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setupView];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

#pragma mark - 私有方法
-(void)setupView{
    
    //初始化默认值
    _titleColor = [UIColor blackColor];
    _titleFont = [UIFont systemFontOfSize:18];
    
    
    _backgroundView = [[UIView alloc] init];
    [self addSubview:self.backgroundView];
    
    _backgroundImageView = [[UIImageView alloc] init];
    _backgroundImageView.hidden = YES;
    [self addSubview:self.backgroundImageView];
    
    _leftButton = [[UIButton alloc] init];
    [_leftButton addTarget:self action:@selector(clickBack) forControlEvents:UIControlEventTouchUpInside];
    _leftButton.imageView.contentMode = UIViewContentModeCenter;
    _leftButton.hidden = YES;
    [self addSubview:self.leftButton];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = _titleColor;
    _titleLabel.font = _titleFont;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.hidden = YES;
    [self addSubview:self.titleLabel];
    
    _rightButton = [[UIButton alloc] init];
    [_rightButton addTarget:self action:@selector(clickRight) forControlEvents:UIControlEventTouchUpInside];
    _rightButton.imageView.contentMode = UIViewContentModeCenter;
    _rightButton.hidden = YES;
    [self addSubview:self.rightButton];
    
    _bottomLine = [[UIView alloc] init];
    _bottomLine.backgroundColor = [UIColor colorWithRed:(CGFloat)(218.0/255.0) green:(CGFloat)(218.0/255.0) blue:(CGFloat)(218.0/255.0) alpha:1.0];
    [self addSubview:self.bottomLine];
    
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat top = kStatusBarHeight;
    CGFloat margin = 0;
    CGFloat buttonHeight = 44;
    CGFloat buttonWidth = 44;
    CGFloat titleLabelHeight = 44;
    CGFloat titleLabelWidth = kScreenWidth - buttonWidth * 2;
    
    self.backgroundView.frame = self.bounds;
    self.backgroundImageView.frame = self.bounds;
    self.leftButton.frame = CGRectMake(margin, top, buttonWidth, buttonHeight);
    self.rightButton.frame = CGRectMake(kScreenWidth - buttonWidth - margin, top, buttonWidth, buttonHeight);
    self.titleLabel.frame = CGRectMake(CGRectGetMidX(self.leftButton.frame), top, titleLabelWidth, titleLabelHeight);
    self.bottomLine.frame = CGRectMake(0, self.bounds.size.height-0.5, kScreenWidth, 0.5);
    
}


#pragma mark - 公共方法的实现
-(void)lee_setBottomLineHidden:(BOOL)hidden{
    if (self.bottomLine.isHidden == hidden) {
        return;
    }
    self.bottomLine.hidden = hidden;
}

-(void)lee_setBackgroundAlpha:(CGFloat)alpha{
    self.backgroundImageView.alpha = alpha;
    self.backgroundView.alpha = alpha;
    self.bottomLine.alpha = alpha;
}

-(void)lee_setTintColor:(UIColor *)color{
    [self.leftButton setTitleColor:color forState:UIControlStateNormal];
    [self.rightButton setTitleColor:color forState:UIControlStateNormal];
}

-(void)lee_setLeftButtonWithImage:(UIImage *)image highlighted:(UIImage *)highlightedImage titleColor:(UIColor *)titleColor title:(NSString *)title{
    self.leftButton.hidden = NO;
    [self.leftButton setImage:image forState:UIControlStateNormal];
    [self.leftButton setImage:highlightedImage forState:UIControlStateHighlighted];
    [self.leftButton setTitle:title forState:UIControlStateNormal];
    [self.leftButton setTitleColor:titleColor forState:UIControlStateNormal];
}

-(void)lee_setLeftButtonWithImage:(UIImage *)image highlighted:(UIImage *)highlightedImage{
    [self lee_setLeftButtonWithImage:image highlighted:highlightedImage titleColor:nil title:nil];
}

-(void)lee_setLeftButtonWithImage:(UIImage *)image{
    [self lee_setLeftButtonWithImage:image highlighted:nil titleColor:nil title:nil];
}

-(void)lee_setLeftButtonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor{
    [self lee_setLeftButtonWithImage:nil highlighted:nil titleColor:titleColor title:title];
}


-(void)lee_setRightButtonWithImage:(UIImage *)image highlighted:(UIImage *)highlightedImage titleColor:(UIColor *)titleColor title:(NSString *)title{
    self.rightButton.hidden = NO;
    [self.rightButton setImage:image forState:UIControlStateNormal];
    [self.rightButton setImage:highlightedImage forState:UIControlStateHighlighted];
    [self.rightButton setTitle:title forState:UIControlStateNormal];
    [self.rightButton setTitleColor:titleColor forState:UIControlStateNormal];
}

-(void)lee_setRightButtonWithImage:(UIImage *)image highlighted:(UIImage *)highlightedImage{
    [self lee_setRightButtonWithImage:image highlighted:highlightedImage titleColor:nil title:nil];
}

-(void)lee_setRightButtonWithImage:(UIImage *)image{
    [self lee_setRightButtonWithImage:image highlighted:nil titleColor:nil title:nil];
}

-(void)lee_setRightButtonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor{
    [self lee_setRightButtonWithImage:nil highlighted:nil titleColor:titleColor title:title];
}




#pragma mark - Action & Event

-(void)clickBack{
    if (self.leftCb) {
        self.leftCb();
    }else{
        //默认执行返回
        UIViewController *currentVC = [UIViewController lee_currentViewController];
        [currentVC lee_toLastViewController];
    }
}

-(void)clickRight{
    if (self.rightCb) {
        self.rightCb();
    }
}

#pragma mark - setter
-(void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.hidden = NO;
    self.titleLabel.text = _title;
}
- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    self.titleLabel.textColor = titleColor;
}
- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    self.titleLabel.font = titleFont;
}
-(void)setBarBackgroundColor:(UIColor *)barBackgroundColor {
    self.backgroundImageView.hidden = YES;
    _barBackgroundColor = barBackgroundColor;
    self.backgroundView.hidden = NO;
    self.backgroundView.backgroundColor = _barBackgroundColor;
}
- (void)setBarBackgroundImage:(UIImage *)barBackgroundImage {
    self.backgroundView.hidden = YES;
    _barBackgroundImage = barBackgroundImage;
    self.backgroundImageView.hidden = NO;
    self.backgroundImageView.image = _barBackgroundImage;
}



@end
