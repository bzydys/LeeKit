//
//  InfiniteConfiguration.h
//  LeeKit
//
//  Created by Lee on 2018/1/22.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PageControllDirection) {
    PageControllDirectionCenter=0,//默认在中间
    PageControllDirectionLeft,
    PageControllDirectionRight
    
};

@interface InfiniteConfiguration : NSObject


/**
 是否为无限滚动，default为YES
 */
@property(nonatomic, assign, getter=isInfinite) BOOL infinite;


/**
 是否显示正在加载的view
 */
@property(nonatomic, assign) BOOL showLoadingView;

/**
 页面切换的时长
 */
@property(nonatomic, assign) NSTimeInterval duration;

/**
 小圆点所在的位置
 */
@property(nonatomic, assign) PageControllDirection direction;

/**
 非当前页小圆点的颜色
 */
@property(nonatomic, strong) UIColor *pageUnselectColor;

/**
 当前页小圆点的颜色
 */
@property(nonatomic, strong) UIColor *pageSelectColor;

@end
