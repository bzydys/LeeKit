//
//  TagConfig.h
//  LeeKit
//
//  Created by Lee on 2018/2/20.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TagConfig : NSObject

/**
 控件的最大高度，超过之后
 */
@property(nonatomic, assign) CGFloat maxHeight;

/**
 单个item最大高度
 */
@property(nonatomic, assign) CGFloat maxItemHeight;

/**
 是否可变宽度
 */
@property(nonatomic, assign) BOOL flexable;

/**
 如果为不可变宽度，指定有多少列
 */
@property(nonatomic, assign) NSInteger colCount;

/**
 普通状态的字体颜色
 */
@property(nonatomic, strong) UIColor *normalTitleColor;

/**
 选中的字体颜色
 */
@property(nonatomic, strong) UIColor *selectedTitleColor;

/**
 字体
 */
@property(nonatomic, strong) UIFont *titleFont;

/**
 圆角大小
 */
@property(nonatomic, assign) CGFloat cornerRadius;

/**
 选中背景色
 */
@property(nonatomic, strong) UIColor *selectedBackgroundColor;

/**
 普通状态下item的背景色
 */
@property(nonatomic, strong) UIColor *normalBackgroundColor;

/**
 可变宽度下间距大小
 */
@property(nonatomic, assign) CGFloat itemSpace;

/**
 可变宽度下item的内边距
 */
@property(nonatomic, assign) UIEdgeInsets inset;


@end
