//
//  UIButton+Lee.h
//  LeeKit
//
//  Created by Lee on 2018/3/6.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Lee)

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title;

/**
 * 在UIButton的样式（如字体）设置完后，将button的text设置为一个测试字符，再调用sizeToFit，从而令button的高度适应字体
 * @warning 会调用<i>setText:forState:</i>，因此请确保在设置完按钮的样式之后、设置text之前调用
 */
- (void)lee_calculateHeightAfterSetAppearance;


@end
