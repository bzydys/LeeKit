//
//  LeeVisualEffectView.m
//  LeeKit
//
//  Created by Lee on 2018/3/18.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "LeeVisualEffectView.h"

//由于系统版本不同，效果实现不同
@implementation LeeVisualEffectView
{
    UIVisualEffectView *_effectView_8;  // iOS8 及以上
    UIToolbar *_effectView_7;           // iOS7
    UIView *_effectView_6;              // iOS6 及以下,暂时没实现，可通过GPUImage
}

- (instancetype)init {
    self = [self initWithStyle:LeeUIVisualEffectViewStyleLight];
    if (self) {
    }
    return self;
}

- (instancetype)initWithStyle:(LeeUIVisualEffectViewStyle)style {
    self = [super init];
    if (self) {
        _style = style;
        [self initEffectViewUI];
    }
    return self;
}

- (void)initEffectViewUI {
    if ([UIVisualEffectView class]) {
        UIBlurEffectStyle effStyle;
        switch (_style) {
            case LeeUIVisualEffectViewStyleExtraLight:
                effStyle = UIBlurEffectStyleExtraLight;
                break;
            case LeeUIVisualEffectViewStyleLight:
                effStyle = UIBlurEffectStyleLight;
                break;
            case LeeUIVisualEffectViewStyleDark:
                effStyle = UIBlurEffectStyleDark;
            default:
                break;
        }
        _effectView_8 = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:effStyle]];
        _effectView_8.clipsToBounds = YES;
        [self addSubview:_effectView_8];
    } else {
        _effectView_7 = [[UIToolbar alloc] init];
        _effectView_7.clipsToBounds = YES;
        [self addSubview:_effectView_7];
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _effectView_6.backgroundColor = backgroundColor;
    _effectView_7.backgroundColor = backgroundColor;
    _effectView_8.backgroundColor = backgroundColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if ([UIVisualEffectView class]) {
        _effectView_8.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    } else {
        _effectView_7.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    }
}



@end
