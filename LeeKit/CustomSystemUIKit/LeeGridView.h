//
//  LeeGridView.h
//  LeeKit
//
//  Created by Lee on 2018/3/10.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  用于做九宫格布局，会将内部所有的 subview 根据指定的列数和行高，把每个 item（也即 subview） 拉伸到相同的大小。
 *
 *  支持在 item 和 item 之间显示分隔线，分隔线支持虚线。
 *
 *  @warning 注意分隔线是占位的，把 item 隔开，而不是盖在某个 item 上。
 */

@interface LeeGridView : UIView
///指定显示的列数，默认为0
@property(nonatomic, assign) NSUInteger columnCount;
///指定每一行的高度，默认为0
@property(nonatomic, assign) CGFloat rowHeight;
/// 指定 item 之间的分隔线宽度，默认为 0
@property(nonatomic, assign) CGFloat separatorWidth;
///指定 item 之间的分隔线颜色，默认为 UIColorSeparator
@property(nonatomic, strong) UIColor *separatorColor;
///分割线是否用虚线显示，默认为NO
@property(nonatomic, assign) BOOL shouldSeparatorDashed;
/// 候选的初始化方法，亦可通过 initWithFrame:、init 来初始化。
- (instancetype)initWithColumn:(NSUInteger)column rowHeight:(CGFloat)rowHeight;


@end
