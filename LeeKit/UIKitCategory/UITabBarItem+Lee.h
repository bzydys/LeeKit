//
//  UITabBarItem+Lee.h
//  LeeKit
//
//  Created by Lee on 2018/3/7.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBarItem (Lee)

/**
 *  双击 tabBarItem 时的回调，默认为 nil。
 *  @arg tabBarItem 被双击的 UITabBarItem
 *  @arg index      被双击的 UITabBarItem 的序号
 */
@property(nonatomic, copy) void (^doubleTapBlock)(UITabBarItem *tabBarItem, NSInteger index);

/**
 * 获取一个UITabBarItem内的按钮，里面包含imageView、label等子View
 */
- (UIControl *)lee_barButton;

/**
 * 获取一个UITabBarItem内显示图标的UIImageView，如果找不到则返回nil
 * @warning 需要对nil的返回值做保护
 */
- (UIImageView *)lee_imageView;

@end
