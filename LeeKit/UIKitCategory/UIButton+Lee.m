//
//  UIButton+Lee.m
//  LeeKit
//
//  Created by Lee on 2018/3/6.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "UIButton+Lee.h"

@implementation UIButton (Lee)

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title {
    if (self = [super init]) {
        [self setImage:image forState:UIControlStateNormal];
        [self setTitle:title forState:UIControlStateNormal];
    }
    return self;
}

- (void)lee_calculateHeightAfterSetAppearance {
    [self setTitle:@"测" forState:UIControlStateNormal];
    [self sizeToFit];
    [self setTitle:nil forState:UIControlStateNormal];
}

@end
