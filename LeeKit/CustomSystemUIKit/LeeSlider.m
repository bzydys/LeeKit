//
//  LeeSlider.m
//  LeeKit
//
//  Created by Lee on 2018/3/20.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "LeeSlider.h"
#import "UIImage+Lee.h"
#import "UIView+Lee.h"

CGRect CGRectSetHeight(CGRect rect, CGFloat height) {
    rect.size.height = height;
    return rect;
}

CGRect CGRectSetY(CGRect rect, CGFloat y) {
    rect.origin.y = y;
    return rect;
}

@implementation LeeSlider

- (void)setThumbSize:(CGSize)thumbSize {
    _thumbSize = thumbSize;
    [self updateThumbImage];
}

- (void)setThumbColor:(UIColor *)thumbColor {
    _thumbColor = thumbColor;
    [self updateThumbImage];
}

- (void)updateThumbImage {
    if (!(self.thumbSize.width <= 0 || self.thumbSize.height <= 0)) {
        UIColor *thumbColor = self.thumbColor ?: self.tintColor;
        UIImage *thumbImage = [UIImage lee_imageWithShape:LeeImageShapeOval size:_thumbSize tintColor:thumbColor];
        [self setThumbImage:thumbImage forState:UIControlStateNormal];
        [self setThumbImage:thumbImage forState:UIControlStateHighlighted];
    }
}

- (UIView *)thumbViewIfExist {
    // thumbView 并非在一开始就存在，而是在某个时机才生成的，所以可能返回 nil
    UIView *thumbView = [self valueForKey:@"thumbView"];
    return thumbView;
}

- (void)setThumbShadowColor:(UIColor *)thumbShadowColor {
    _thumbShadowColor = thumbShadowColor;
    UIView *thumbView = [self thumbViewIfExist];
    if (thumbView) {
        thumbView.layer.shadowColor = _thumbShadowColor.CGColor;
        thumbView.layer.shadowOpacity = _thumbShadowColor ? 1 : 0;
    }
}

- (void)setThumbShadowOffset:(CGSize)thumbShadowOffset {
    _thumbShadowOffset = thumbShadowOffset;
    UIView *thumbView = [self thumbViewIfExist];
    if (thumbView) {
        thumbView.layer.shadowOffset = _thumbShadowOffset;
    }
}

- (void)setThumbShadowRadius:(CGFloat)thumbShadowRadius {
    _thumbShadowRadius = thumbShadowRadius;
    UIView *thumbView = [self thumbViewIfExist];
    if (thumbView) {
        thumbView.layer.shadowRadius = thumbShadowRadius;
    }
}

- (CGRect)trackRectForBounds:(CGRect)bounds {
    CGRect result = [super trackRectForBounds:bounds];
    if (self.trackHeight == 0) {
        return result;
    }
    
    result = CGRectSetHeight(result, self.trackHeight);
    result = CGRectSetY(result, (CGRectGetHeight(bounds) - CGRectGetHeight(result))/2.0);
    return result;
}

- (void)didAddSubview:(UIView *)subview {
    [super didAddSubview:subview];
    if (subview && subview == [self thumbViewIfExist]) {
        UIView *thumbView = subview;
        thumbView.layer.shadowColor = self.thumbShadowColor.CGColor;
        thumbView.layer.shadowOpacity = self.thumbShadowColor ? 1 : 0;
        thumbView.layer.shadowOffset = self.thumbShadowOffset;
        thumbView.layer.shadowRadius = self.thumbShadowRadius;
    }
}

@end
