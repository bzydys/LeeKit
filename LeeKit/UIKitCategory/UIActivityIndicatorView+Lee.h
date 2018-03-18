//
//  UIActivityIndicatorView+Lee.h
//  LeeKit
//
//  Created by Lee on 2018/3/6.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIActivityIndicatorView (Lee)

/**
 * 创建一个指定大小的UIActivityIndicatorView
 *
 * 系统的UIActivityIndicatorView尺寸是由UIActivityIndicatorViewStyle决定的，固定不变。因此创建后通过CGAffineTransformMakeScale将其缩放到指定大小。self.frame获取的值也是缩放后的值，不影响布局。
 *
 * @param style UIActivityIndicatorViewStyle
 * @param size  UIActivityIndicatorView的大小
 *
 * @return UIActivityIndicatorView对象
 */
- (instancetype)initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style size:(CGSize)size;

@end
