//
//  LeeUITextField.m
//  LeeKit
//
//  Created by Lee on 2018/3/9.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "LeeUITextField.h"

@interface LeeUITextField()<UITextFieldDelegate>

@end

@implementation LeeUITextField

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.placeHolderColor = [UIColor colorWithRed:196/255.0 green:200/255.0 blue:208/255.0 alpha:1];
        self.placeHolderFont = self.font;
        self.textInsets = UIEdgeInsetsMake(0, 7, 0, 7);
        self.maximumTextLength = NSUIntegerMax;
    }
    return self;
}

#pragma mark - placeHolder

-(void)setPlaceHolderColor:(UIColor *)placeHolderColor{
    _placeHolderColor = placeHolderColor;
    if (self.placeholder) {
        [self updateAttributedPlaceholderIfNeeded];
    }
}

-(void)setPlaceHolderFont:(UIFont *)placeHolderFont{
    _placeHolderFont = placeHolderFont;
    if (self.placeholder) {
        [self updateAttributedPlaceholderIfNeeded];
    }
}

- (void)updateAttributedPlaceholderIfNeeded {
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName: self.placeHolderColor, NSFontAttributeName: self.placeHolderFont}];
}

#pragma mark - TextInsets

- (CGRect)textRectForBounds:(CGRect)bounds {
    bounds = UIEdgeInsetsInsetRect(bounds, self.textInsets);
    CGRect resultRect = [super textRectForBounds:bounds];
    return resultRect;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    bounds = UIEdgeInsetsInsetRect(bounds, self.textInsets);
    return [super editingRectForBounds:bounds];
}

#pragma mark - <UITextFieldDelegate>


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (self.maximumTextLength < NSUIntegerMax) {
        
        BOOL isDeleting = range.length > 0 && string.length <= 0;
        if (isDeleting || textField.markedTextRange) {
            
            return YES;
        }
        
        NSUInteger rangeLength = range.length;
        if (textField.text.length - rangeLength + string.length > self.maximumTextLength) {
            return NO;
        }
    }
    return YES;
}

@end
