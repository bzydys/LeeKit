//
//  LeeCustomNavigationBar.h
//  LeeKit
//
//  Created by Lee on 2017/12/15.
//  Copyright © 2017年 Lee. All rights reserved.
//

typedef void(^leftItemClickCallBack)(void);
typedef void(^rightItemClickCallBack)(void);

#import <UIKit/UIKit.h>

@interface LeeCustomNavigationBar : UIView

#pragma mark - 属性
@property(nonatomic, copy) leftItemClickCallBack leftCb;
@property(nonatomic, copy) rightItemClickCallBack rightCb;

/**
 导航标题
 */
@property(nonatomic, copy) NSString *title;

/**
 导航标题颜色
 */
@property(nonatomic, strong) UIColor *titleColor;

/**
 导航字体
 */
@property(nonatomic, strong) UIFont *titleFont;

/**
 导航背景色
 */
@property(nonatomic, strong) UIColor *barBackgroundColor;

/**
 导航的背景图
 */
@property(nonatomic, strong) UIImage *barBackgroundImage;


#pragma mark - 方法

/**
 类方法返回实例对象

 @return 导航栏对象
 */
+(instancetype)customNavigationBar;

/**
 设置导航栏底部线是否隐藏

 @param hidden 是否隐藏
 */
-(void)lee_setBottomLineHidden:(BOOL)hidden;


/**
 设置导航栏透明度

 @param alpha 透明度（0-1）
 */
-(void)lee_setBackgroundAlpha:(CGFloat)alpha;


/**
  设置item的颜色

 @param color 颜色
 */
-(void)lee_setTintColor:(UIColor *)color;


#pragma mark - 左侧
/**
 设置左侧item的背景图
 
 @param image 普通状态的背景图
 @param highlightedImage 高亮状态的背景图
 @param titleColor 按钮标题颜色
 @param title 按钮标题
 */
-(void)lee_setLeftButtonWithImage:(UIImage *)image highlighted:(UIImage *)highlightedImage titleColor:(UIColor *)titleColor title:(NSString *)title;


/**
 不带标题的左侧按钮
 
 @param image 普通状态的背景图
 @param highlightedImage 高亮状态的背景图
 */
-(void)lee_setLeftButtonWithImage:(UIImage *)image highlighted:(UIImage *)highlightedImage;


/**
 设置左侧item的背景图

 @param image 普通状态的背景图
 */
-(void)lee_setLeftButtonWithImage:(UIImage *)image;


/**
 设置左侧item的标题

 @param title 标题
 @param titleColor 标题颜色
 */
-(void)lee_setLeftButtonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor;


#pragma mark - 右侧
/**
 设置右侧item的背景图

 @param image 普通状态的背景图
 @param highlightedImage 高亮状态的背景图
 @param titleColor 按钮标题颜色
 @param title 按钮标题
 */
-(void)lee_setRightButtonWithImage:(UIImage *)image highlighted:(UIImage *)highlightedImage titleColor:(UIColor *)titleColor title:(NSString *)title;

/**
 不带标题的右侧按钮

 @param image 普通状态的背景图
 @param highlightedImage 高亮状态的背景图
 */
-(void)lee_setRightButtonWithImage:(UIImage *)image highlighted:(UIImage *)highlightedImage;


/**
 设置右侧item的背景图
 
 @param image 普通状态的背景图
 */
-(void)lee_setRightButtonWithImage:(UIImage *)image;


/**
 设置右侧item的标题
 
 @param title 标题
 @param titleColor 标题颜色
 */
-(void)lee_setRightButtonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor;

@end
