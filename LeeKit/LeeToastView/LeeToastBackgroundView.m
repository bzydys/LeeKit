//
//  LeeToastBackgroundView.m
//  LeeKit
//
//  Created by Lee on 2018/3/12.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "LeeToastBackgroundView.h"

@interface LeeToastBackgroundView ()

@property(nonatomic, strong) UIView *effectView;

@end

@implementation LeeToastBackgroundView

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //子layer不会受父layer影响
        self.layer.allowsGroupOpacity = NO;
        self.backgroundColor = self.styleColor;
        self.layer.cornerRadius = self.cornerRadius;
    }
    return self;
}

-(void)setShouldBlurBackgroundView:(BOOL)shouldBlurBackgroundView{
    _shouldBlurBackgroundView = shouldBlurBackgroundView;
    if (shouldBlurBackgroundView) {
        if (NSClassFromString(@"UIBlurEffect")) {
            UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
            effectView.layer.cornerRadius = self.cornerRadius;
            effectView.layer.masksToBounds = YES;
            [self addSubview:effectView];
            self.effectView = effectView;
        }else{
            if (self.effectView) {
                [self.effectView removeFromSuperview];
                self.effectView = nil;
            }
        }
    }
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.effectView) {
        self.effectView.frame = self.bounds;
    }
}

#pragma mark - UIAppearance

- (void)setStyleColor:(UIColor *)styleColor {
    _styleColor = styleColor;
    self.backgroundColor = styleColor;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
    if (self.effectView) {
        self.effectView.layer.cornerRadius = cornerRadius;
    }
}


@end

@interface LeeToastBackgroundView (UIAppearance)

@end

@implementation LeeToastBackgroundView (UIAppearance)

+(void)initialize{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setDefaultAppearance];
    });
}

+ (void)setDefaultAppearance {
    LeeToastBackgroundView *appearance = [LeeToastBackgroundView appearance];
    appearance.styleColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    appearance.cornerRadius = 10.0;
}

@end
