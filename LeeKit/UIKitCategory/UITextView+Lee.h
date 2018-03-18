//
//  UITextView+Lee.h
//  LeeKit
//
//  Created by Lee on 2018/3/7.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (Lee)

- (NSRange)lee_convertNSRangeFromUITextRange:(UITextRange *)textRange;

/**
 *  设置 text 会让 selectedTextRange 跳到最后一个字符，导致在中间修改文字后光标会跳到末尾，所以设置前要保存一下，设置后恢复过来
 */
- (void)lee_setTextKeepingSelectedRange:(NSString *)text;

/**
 *  设置 attributedText 会让 selectedTextRange 跳到最后一个字符，导致在中间修改文字后光标会跳到末尾，所以设置前要保存一下，设置后恢复过来
 */
- (void)lee_setAttributedTextKeepingSelectedRange:(NSAttributedString *)attributedText;

/**
 *  [UITextView scrollRangeToVisible:] 并不会考虑 textContainerInset.bottom，所以使用这个方法来代替
 */
- (void)lee_scrollCaretVisibleAnimated:(BOOL)animated;

@end
