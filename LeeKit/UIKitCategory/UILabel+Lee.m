//
//  UILabel+Lee.m
//  LeeKit
//
//  Created by Lee on 2018/3/7.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "UILabel+Lee.h"
#import <objc/runtime.h>

@implementation UILabel (Lee)

static inline void ReplaceMethod(Class _class, SEL _originSelector, SEL _newSelector) {
    Method oriMethod = class_getInstanceMethod(_class, _originSelector);
    Method newMethod = class_getInstanceMethod(_class, _newSelector);
    BOOL isAddedMethod = class_addMethod(_class, _originSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (isAddedMethod) {
        class_replaceMethod(_class, _newSelector, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    } else {
        method_exchangeImplementations(oriMethod, newMethod);
    }
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ReplaceMethod([self class], @selector(setText:), @selector(lee_setText:));
        ReplaceMethod([self class], @selector(setAttributedText:), @selector(lee_setAttributedText:));
    });
}

- (void)lee_setText:(NSString *)text {
    if (!text) {
        [self lee_setText:text];
        return;
    }
    if (!self.lee_textAttributes.count && self.lee_lineHeight <= 0) {
        [self lee_setText:text];
        return;
    }
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text attributes:self.lee_textAttributes];
    [self lee_setAttributedText:attributedString];
}

// 在 lee_textAttributes 样式基础上添加用户传入的 attributedString 中包含的新样式。换句话说，如果这个方法里有样式冲突，则以 attributedText 为准
- (void)lee_setAttributedText:(NSAttributedString *)text {
    if (!text) {
        [self lee_setAttributedText:text];
        return;
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text.string attributes:self.lee_textAttributes];
    [text enumerateAttributesInRange:NSMakeRange(0, text.length) options:0 usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        [attributedString addAttributes:attrs range:range];
    }];
    [self lee_setAttributedText:attributedString];
}

static char kAssociatedObjectKey_textAttributes;
// 在现有样式基础上增加 lee_textAttributes 样式。换句话说，如果这个方法里有样式冲突，则以 lee_textAttributes 为准
- (void)setLee_textAttributes:(NSDictionary<NSString *, id> *)lee_textAttributes {
    NSDictionary *prevTextAttributes = self.lee_textAttributes;
    if ([prevTextAttributes isEqualToDictionary:lee_textAttributes]) {
        return;
    }
    
    objc_setAssociatedObject(self, &kAssociatedObjectKey_textAttributes, lee_textAttributes, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    if (!self.text.length) {
        return;
    }
    NSMutableAttributedString *string = [self.attributedText mutableCopy];
    NSRange fullRange = NSMakeRange(0, string.length);
    
    // 1）当前 attributedText 包含的样式可能来源于两方面：通过 lee_textAttributes 设置的、通过直接传入 attributedString 设置的，这里要过滤删除掉前者的样式效果，保留后者的样式效果
    if (prevTextAttributes) {
        // 找出现在 attributedText 中哪些 attrs 是通过上次的 lee_textAttributes 设置的
        NSMutableArray *willRemovedAttributes = [NSMutableArray array];
        [string enumerateAttributesInRange:NSMakeRange(0, string.length) options:0 usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
            // 如果存在 kern 属性，则只有 range 是第一个字至倒数第二个字，才有可能是通过 lee_textAttribtus 设置的
            if (NSEqualRanges(range, NSMakeRange(0, string.length - 1)) && [attrs[NSKernAttributeName] isEqualToNumber:prevTextAttributes[NSKernAttributeName]]) {
                [string removeAttribute:NSKernAttributeName range:NSMakeRange(0, string.length - 1)];
            }
            // 上面排除掉 kern 属性后，如果 range 不是整个字符串，那肯定不是通过 lee_textAttributes 设置的
            if (!NSEqualRanges(range, fullRange)) {
                return;
            }
            [attrs enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull attr, id  _Nonnull value, BOOL * _Nonnull stop) {
                if (prevTextAttributes[attr] == value) {
                    [willRemovedAttributes addObject:attr];
                }
            }];
        }];
        [willRemovedAttributes enumerateObjectsUsingBlock:^(id  _Nonnull attr, NSUInteger idx, BOOL * _Nonnull stop) {
            [string removeAttribute:attr range:fullRange];
        }];
    }
    
    // 2）添加新样式
    if (lee_textAttributes) {
        [string addAttributes:lee_textAttributes range:fullRange];
    }
    // 不能调用 setAttributedText: ，否则若遇到样式冲突，那个方法会让用户传进来的 NSAttributedString 样式覆盖 lee_textAttributes 的样式
    [self lee_setAttributedText:string];
}

- (NSDictionary *)lee_textAttributes {
    return (NSDictionary *)objc_getAssociatedObject(self, &kAssociatedObjectKey_textAttributes);
}

static char kAssociatedObjectKey_lineHeight;
- (void)setLee_lineHeight:(CGFloat)lee_lineHeight {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_lineHeight, @(lee_lineHeight), OBJC_ASSOCIATION_COPY_NONATOMIC);
    // 注意：对于 UILabel，只要你设置过 text，则 attributedText 就是有值的，因此这里无需区分 setText 还是 setAttributedText
    [self setAttributedText:self.attributedText];
}

- (CGFloat)lee_lineHeight {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_lineHeight) floatValue];
}

- (instancetype)initWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    if (self = [super init]) {
        self.font = font;
        self.textColor = textColor;
    }
    return self;
}

- (void)lee_setTheSameAppearanceAsLabel:(UILabel *)label {
    self.font = label.font;
    self.textColor = label.textColor;
    self.backgroundColor = label.backgroundColor;
    self.lineBreakMode = label.lineBreakMode;
    self.textAlignment = label.textAlignment;
    if ([self respondsToSelector:@selector(setContentEdgeInsets:)] && [label respondsToSelector:@selector(contentEdgeInsets)]) {
        UIEdgeInsets contentEdgeInsets;
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[label methodSignatureForSelector:@selector(contentEdgeInsets)]];
        invocation.target = label;
        invocation.selector = @selector(contentEdgeInsets);
//        [invocation setArgument:&contentEdgeInsets atIndex:2];
        [invocation invoke];
        [invocation getReturnValue:&contentEdgeInsets];
        
        NSInvocation *invocation1 = [NSInvocation invocationWithMethodSignature:[label methodSignatureForSelector:@selector(setContentEdgeInsets:)]];
        invocation1.target = label;
        invocation1.selector = @selector(setContentEdgeInsets:);
        [invocation1 setArgument:&contentEdgeInsets atIndex:2];
        [invocation1 invoke];
    }
}

- (void)lee_calculateHeightAfterSetAppearance {
    self.text = @"测";
    [self sizeToFit];
    self.text = nil;
}

@end
