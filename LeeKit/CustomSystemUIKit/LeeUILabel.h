//
//  LeeUILabel.h
//  LeeKit
//
//  Created by Lee on 2018/3/9.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * `LeeUILabel`支持通过`contentEdgeInsets`属性来实现类似padding的效果。
 *
 */

@interface LeeUILabel : UILabel

/// 控制label内容的padding，默认为UIEdgeInsetsZero
@property(nonatomic,assign) UIEdgeInsets contentEdgeInsets;
///是否为镂空字体
@property(nonatomic, assign) BOOL shouldStroke;


@end
