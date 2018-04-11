//
//  LeeFloatLayout.h
//  LeeKit
//
//  Created by Lee on 2018/3/18.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
/// 用于属性 maximumItemSize，是它的默认值。表示 item 的最大宽高会自动根据当前 floatLayoutView 的内容大小来调整，从而避免 item 内容过多时可能溢出 floatLayoutView。
UIKIT_EXTERN const CGSize LeeFloatLayoutAutomaticalMaximumItemSize;

/**
 *  做类似 CSS 里的 float:left 的布局，自行使用 addSubview: 将子 View 添加进来即可。
 *
 *  支持通过 `contentMode` 属性修改子 View 的对齐方式，目前仅支持 `UIViewContentModeLeft` 和 `UIViewContentModeRight`，默认为 `UIViewContentModeLeft`。
 */
@interface LeeFloatLayout : UIView
///布局容器内边距
@property(nonatomic, assign) UIEdgeInsets padding;
///item最小尺寸，默认为CGSizeZero
@property(nonatomic, assign) CGSize minimumItemSize;

///item最大尺寸
@property(nonatomic, assign) CGSize maximunItemSize;
/**
 *  item 之间的间距，默认为 UIEdgeInsetsZero。
 *
 *  @warning 上、下、左、右四个边缘的 item 布局时不会考虑 itemMargins.left/bottom/left/right。
 */
@property(nonatomic, assign) UIEdgeInsets itemMargin;

@end
