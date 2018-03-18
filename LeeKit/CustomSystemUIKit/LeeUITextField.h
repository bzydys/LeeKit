//
//  LeeUITextField.h
//  LeeKit
//
//  Created by Lee on 2018/3/9.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeeUITextField : UITextField

///placeHolder的颜色
@property(nonatomic, strong) UIColor *placeHolderColor;
///placeHolder字体
@property(nonatomic, strong) UIFont *placeHolderFont;
///允许输入的最大字符长度
@property(nonatomic, assign) NSUInteger maximumTextLength;

/**
 *  文字在输入框内的 padding。如果出现 clearButton，则 textInsets.right 会控制 clearButton 的右边距
 *
 */
@property(nonatomic, assign) UIEdgeInsets textInsets;

@end
