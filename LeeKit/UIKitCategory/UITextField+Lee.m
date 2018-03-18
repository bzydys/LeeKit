//
//  UITextField+Lee.m
//  LeeKit
//
//  Created by Lee on 2018/3/7.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "UITextField+Lee.h"

@implementation UITextField (Lee)

- (NSRange)lee_selectedRange {
    NSInteger location = [self offsetFromPosition:self.beginningOfDocument toPosition:self.selectedTextRange.start];
    NSInteger length = [self offsetFromPosition:self.selectedTextRange.start toPosition:self.selectedTextRange.end];
    return NSMakeRange(location, length);
}

@end
