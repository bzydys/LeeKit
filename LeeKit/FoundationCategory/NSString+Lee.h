//
//  NSString+Lee.h
//  LeeKit
//
//  Created by Lee on 2018/3/6.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Lee)

/// 判断是否包含某个子字符串
- (BOOL)lee_includesString:(NSString *)string;

/// 去掉头尾的空白字符
- (NSString *)lee_trim;

/// 去掉整段文字内的所有空白字符（包括换行符）
- (NSString *)lee_trimAllWhiteSpace;

/// 把该字符串转换为对应的 md5
- (NSString *)lee_md5;

+ (instancetype)lee_stringWithCGFloat:(CGFloat)floatValue decimal:(NSUInteger)decimal;

@end
