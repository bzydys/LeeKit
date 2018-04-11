//
//  LeeSegmentView.h
//  LeeKit
//
//  Created by Lee on 2018/3/30.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LeeSegmentView;

@protocol LeeSegmentViewDelegate
///高度与父控件保持一致，这里仅约束宽度
-(CGFloat)segmentView:(LeeSegmentView *)segmentView widthForRowAtIndex:(NSUInteger)index;
///每个item的点击回调
-(void)segmentView:(LeeSegmentView *)segmentView didSelectItemAtIndex:(NSUInteger)index;
///每个item选中的样式
-(void)segmentView:(LeeSegmentView *)segmentView styleForSelectAtIndex:(NSInteger)index;

///每个item未选中的样式
-(void)segmentView:(LeeSegmentView *)segmentView styleFordeSelectAtIndex:(NSInteger)index;

@end

@protocol LeeSegmentViewDataSource
///总共返回多少个Item
-(NSUInteger)numberofItemsInLeeSegmentView:(LeeSegmentView *)segmentView;
///指定位置的自定义Item
-(UIControl *)segmentView:(LeeSegmentView *)segmentView viewAtIndex:(NSUInteger)index;

@end

@interface LeeSegmentView : UIView
///代理
@property(nonatomic, weak) id<LeeSegmentViewDelegate> delegate;
///数据源
@property(nonatomic, weak) id<LeeSegmentViewDataSource> dataSource;
///每个item之间的间距大小，默认为0
@property(nonatomic, assign) CGFloat itemSpace;

///item底部的分割线
@property(nonatomic, strong, readonly) CALayer *lineLayer;
///当控件是滑块遮盖的样式，这个就是覆盖物
@property(nonatomic, strong, readonly) CALayer *coverLayer;

///防止item的宽度过小,影响视觉效果,默认为0，不做限制
@property(nonatomic, assign) CGFloat itemMinimumWidth;
///所有item的容器
@property(nonatomic, strong, readonly) UIScrollView *contentScrollView;
///padding仅支持水平方向
@property(nonatomic, assign) UIEdgeInsets padding;

///返回对应的item
-(UIControl *)viewForItemAtIndex:(NSUInteger)index;


/**
 滚动到对应的item

 @param index 目的index
 @param animated 是否动画
 */
-(void)scrollToIndex:(NSUInteger)index withAnimated:(BOOL)animated;

/**
 滚动到下个Item的进度，适用于scrollView的联动

 @param progress 最大为1 偏移量/宽度
 */
-(void)scrollWithProgress:(CGFloat)progress;

@end
