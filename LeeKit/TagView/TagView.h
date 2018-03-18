//
//  TagView.h
//  LeeKit
//
//  Created by Lee on 2018/2/27.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagConfig.h"

@interface TagView : UIView

/**
 创建Tag对象，使用默认配置

 @param titles 所有需要展示的title
 @return 生成对象
 */
-(instancetype)initWithTitles:(NSArray<NSString *> *)titles;

/**
 * 创建Tag对象

 * @param titles 所有需要展示的title
 * @param config 配置
 * @return 生成对象
 */
-(instancetype)initWithTitles:(NSArray<NSString *> *)titles config:(TagConfig *)config;

//-(instancetype)initWithCustomerCell:(Class)cellClass config:(TagConfig *)config;
@end
