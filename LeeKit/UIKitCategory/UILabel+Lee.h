//
//  UILabel+Lee.h
//  LeeKit
//
//  Created by Lee on 2018/3/7.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Lee)

- (instancetype)initWithFont:(UIFont *)font textColor:(UIColor *)textColor;

/**
 * @brief 在需要特殊样式时，可通过此属性直接给整个 label 添加 NSAttributeName 系列样式，然后 setText 即可，无需使用繁琐的 attributedText
 *
 * @note 即使先调用 setText/attributedText ，然后再设置此属性，此属性仍然会生效
 * @note 如果此属性包含了 NSKernAttributeName ，则最后一个字的 kern 效果会自动被移除，否则容易导致文字在视觉上不居中
 *
 * @note 当你设置了此属性后，每次你调用 setText: 时，其实都会被自动转而调用 setAttributedText:
 *
 * 现在你有三种方法控制 label 的样式：
 * 1. 本身的样式属性（如 textColor, font 等）
 * 2. lee_textAttributes
 * 3. 构造 NSAttributedString
 * 这三种方式可以同时使用，如果样式发生冲突（比如先通过方法1将文字设成红色，又通过方法2将文字设成蓝色），则绝大部分情况下代码执行顺序靠后的会最终生效
 * 唯一例外的极端情况是：先用方法2将文字设成红色，再用方法1将文字设成蓝色，最后再 setText，这时虽然代码执行顺序靠后的是方法1，但最终生效的会是方法2，为了避免这种极端情况的困扰，建议不要同时使用方法1和方法2去设置同一种样式。
 *
 */
@property(nonatomic, copy) NSDictionary<NSString *, id> *lee_textAttributes;

/**
 *  设置当前整段文字的行高
 *  @note 如果同时通过 lee_textAttributes 或 attributedText 给整段文字设置了行高，则此方法将不再生效。换句话说，此方法设置的行高将永远不会覆盖 lee_textAttributes 或 attributedText 设置的行高。
 *  @note 比如对于字符串"abc"，你通过 attributedText 设置 {0, 1} 这个 range 范围内的行高为 10，又通过 setLee_lineHeight: 设置了整体行高为 20，则最终 {0, 1} 内的行高将为 10，而 {1, 2} 内的行高将为全局行高 20
 *  @note 比如对于字符串"abc"，你先通过 setLee_lineHeight: 设置整体行高为 10，又通过 attributedText/lee_textAttributes 设置整体行高为 20，无论这两个设置的代码的先后顺序如何，最终行高都将为 20
 *
 *  @note 当你设置了此属性后，每次你调用 setText: 时，其实都会被自动转而调用 setAttributedText:
 *
 */

- (void)setLee_lineHeight:(CGFloat)lee_lineHeight;


@end
