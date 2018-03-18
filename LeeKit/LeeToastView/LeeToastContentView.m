//
//  LeeToastContentView.m
//  LeeKit
//
//  Created by Lee on 2018/3/12.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "LeeToastContentView.h"

#define DefaultTextLabelFont [UIFont boldSystemFontOfSize:16]
#define DefaultDetailTextLabelFont [UIFont boldSystemFontOfSize:12]
#define DefaultLabelColor [UIColor whiteColor]

@implementation LeeToastContentView

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.allowsGroupOpacity = NO;
        
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    
    _textLabel = [[UILabel alloc] init];
    self.textLabel.numberOfLines = 0;
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.textColor = DefaultLabelColor;
    self.textLabel.font = DefaultTextLabelFont;
    self.textLabel.opaque = NO;
    [self addSubview:self.textLabel];
    
    _detailTextLabel = [[UILabel alloc] init];
    self.detailTextLabel.numberOfLines = 0;
    self.detailTextLabel.textAlignment = NSTextAlignmentCenter;
    self.detailTextLabel.textColor = DefaultLabelColor;
    self.detailTextLabel.font = DefaultDetailTextLabelFont;
    self.detailTextLabel.opaque = NO;
    [self addSubview:self.detailTextLabel];
}

-(void)setCustomView:(__kindof UIView *)customView{
    if (self.customView == customView) {
        return;
    }else{
        if (self.customView) {
            [self.customView removeFromSuperview];
            _customView = nil;
        }
    }
    
    _customView = customView;
    [self addSubview:self.customView];
    [self updateCustomViewTintColor];
    [self setNeedsLayout];

}

- (void)updateCustomViewTintColor {
    self.customView.tintColor = self.tintColor;
    if ([self.customView isKindOfClass:[UIImageView class]]) {
        UIImageView *customView = (UIImageView *)self.customView;
        customView.image = [customView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    if ([self.customView isKindOfClass:[UIActivityIndicatorView class]]) {
        UIActivityIndicatorView *customView = (UIActivityIndicatorView *)self.customView;
        customView.color = self.tintColor;
    }
}

- (void)setTextLabelText:(NSString *)textLabelText {
    _textLabelText = textLabelText;
    
    if (textLabelText) {
        self.textLabel.attributedText = [[NSAttributedString alloc] initWithString:textLabelText attributes:self.textLabelAttributes];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        [self setNeedsLayout];
    }
}

- (void)setDetailTextLabelText:(NSString *)detailTextLabelText {
    _detailTextLabelText = detailTextLabelText;
    if (detailTextLabelText) {
        self.detailTextLabel.attributedText = [[NSAttributedString alloc] initWithString:detailTextLabelText attributes:self.detailTextLabelAttributes];
        self.detailTextLabel.textAlignment = NSTextAlignmentCenter;
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    BOOL hasCustomView = self.customView != nil;
    BOOL hasTextLabel = self.textLabel.text.length > 0;
    BOOL hasDetailTextLabel = self.detailTextLabel.text.length > 0;
    
    CGFloat width = 0;
    CGFloat height = 0;
    
    CGFloat maxContentWidth = size.width - self.insets.left - self.insets.right;
    CGFloat maxContentHeight = size.height - self.insets.top - self.insets.bottom;
    
    if (hasCustomView) {
        width = fmax(width, CGRectGetWidth(self.customView.bounds));
        height += (CGRectGetHeight(self.customView.bounds) + ((hasTextLabel || hasDetailTextLabel) ? self.customViewMarginBottom : 0));
    }
    
    if (hasTextLabel) {
        CGSize textLabelSize = [self.textLabel sizeThatFits:CGSizeMake(maxContentWidth, maxContentHeight)];
        width = fmax(width, textLabelSize.width);
        height += (textLabelSize.height + (hasDetailTextLabel ? self.textLabelMarginBottom : 0));
    }
    
    if (hasDetailTextLabel) {
        CGSize detailTextLabelSize = [self.detailTextLabel sizeThatFits:CGSizeMake(maxContentWidth, maxContentHeight)];
        width = fmax(width, detailTextLabelSize.width);
        height += (detailTextLabelSize.height + self.detailTextLabelMarginBottom);
    }
    
    width += (self.insets.left + self.insets.right);
    height += (self.insets.top + self.insets.bottom);
    if (!CGSizeEqualToSize(self.minimumSize, CGSizeZero)) {
        width = fmax(width, self.minimumSize.width);
        height = fmax(height, self.minimumSize.height);
    }
    
    return CGSizeMake(fmin(size.width, width), fmin(size.height, height));
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    BOOL hasCustomView = !!self.customView;
    BOOL hasTextLabel = self.textLabel.text.length > 0;
    BOOL hasDetailTextLabel = self.detailTextLabel.text.length > 0;
    
    CGFloat contentWidth = CGRectGetWidth(self.bounds);
    CGFloat maxContentWidth = contentWidth - self.insets.left - self.insets.right;
    
    CGFloat minY = self.insets.top;
    
    if (hasCustomView) {
        if (!hasTextLabel && !hasDetailTextLabel) {
            // 处理有minimumSize的情况
            minY = (CGRectGetHeight(self.bounds)- CGRectGetHeight(self.customView.bounds))/2.0;
        }
        self.customView.frame = CGRectMake((contentWidth- CGRectGetWidth(self.customView.bounds))/2.0, minY, CGRectGetWidth(self.customView.bounds), CGRectGetHeight(self.customView.bounds));
        minY = CGRectGetMaxY(self.customView.frame) + self.customViewMarginBottom;
    }
    
    if (hasTextLabel) {
        CGSize textLabelSize = [self.textLabel sizeThatFits:CGSizeMake(maxContentWidth, CGFLOAT_MAX)];
        if (!hasCustomView && !hasDetailTextLabel) {
            // 处理有minimumSize的情况
            minY = (CGRectGetHeight(self.bounds) - textLabelSize.height)/2.0;
        }
        self.textLabel.frame = CGRectMake((contentWidth - maxContentWidth)/2.0, minY, maxContentWidth, textLabelSize.height);
        minY = CGRectGetMaxY(self.textLabel.frame) + self.textLabelMarginBottom;
    }
    
    if (hasDetailTextLabel) {
        // 暂时没考虑剩余高度不够用的情况
        CGSize detailTextLabelSize = [self.detailTextLabel sizeThatFits:CGSizeMake(maxContentWidth, CGFLOAT_MAX)];
        if (!hasCustomView && !hasTextLabel) {
            // 处理有minimumSize的情况
            minY = (CGRectGetHeight(self.bounds) - detailTextLabelSize.height)/2.0;
        }
        self.detailTextLabel.frame = CGRectMake((contentWidth - maxContentWidth)/2.0, minY, maxContentWidth, detailTextLabelSize.height);
    }
    
}

- (void)tintColorDidChange {
    
    if (self.customView) {
        [self updateCustomViewTintColor];
    }
    
    NSMutableDictionary *textLabelAttributes = [[NSMutableDictionary alloc] initWithDictionary:self.textLabelAttributes];
    textLabelAttributes[NSForegroundColorAttributeName] = self.tintColor;
    self.textLabelAttributes = textLabelAttributes;
    self.textLabelText = self.textLabelText;
    
    NSMutableDictionary *detailTextLabelAttributes = [[NSMutableDictionary alloc] initWithDictionary:self.detailTextLabelAttributes];
    detailTextLabelAttributes[NSForegroundColorAttributeName] = self.tintColor;
    self.detailTextLabelAttributes = detailTextLabelAttributes;
    self.detailTextLabelText = self.detailTextLabelText;
}

#pragma mark - UIAppearance

- (void)setInsets:(UIEdgeInsets)insets {
    _insets = insets;
    [self setNeedsLayout];
}

- (void)setMinimumSize:(CGSize)minimumSize {
    _minimumSize = minimumSize;
    [self setNeedsLayout];
}

- (void)setCustomViewMarginBottom:(CGFloat)customViewMarginBottom {
    _customViewMarginBottom = customViewMarginBottom;
    [self setNeedsLayout];
}

- (void)setTextLabelMarginBottom:(CGFloat)textLabelMarginBottom {
    _textLabelMarginBottom = textLabelMarginBottom;
    [self setNeedsLayout];
}

- (void)setDetailTextLabelMarginBottom:(CGFloat)detailTextLabelMarginBottom {
    _detailTextLabelMarginBottom = detailTextLabelMarginBottom;
    [self setNeedsLayout];
}

- (void)setTextLabelAttributes:(NSDictionary *)textLabelAttributes {
    _textLabelAttributes = textLabelAttributes;
    if (self.textLabelText && self.textLabelText.length > 0) {
        // 刷新label的attributes
        self.textLabelText = self.textLabelText;
    }
}

- (void)setDetailTextLabelAttributes:(NSDictionary *)detailTextLabelAttributes {
    _detailTextLabelAttributes = detailTextLabelAttributes;
    if (self.detailTextLabelText && self.detailTextLabelText.length > 0) {
        // 刷新label的attributes
        self.detailTextLabelText = self.detailTextLabelText;
    }
}
@end

@interface LeeToastContentView (UIAppearance)

@end

@implementation LeeToastContentView (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setDefaultAppearance];
    });
}

+ (void)setDefaultAppearance {
    LeeToastContentView *appearance = [LeeToastContentView appearance];
    appearance.insets = UIEdgeInsetsMake(16, 16, 16, 16);
    appearance.minimumSize = CGSizeZero;
    appearance.customViewMarginBottom = 8;
    appearance.textLabelMarginBottom = 4;
    appearance.detailTextLabelMarginBottom = 0;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = 22;
    paragraphStyle.maximumLineHeight = 22;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSMutableParagraphStyle *paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle1.minimumLineHeight = 18;
    paragraphStyle1.maximumLineHeight = 18;
    paragraphStyle1.alignment = NSTextAlignmentCenter;
    appearance.textLabelAttributes = @{NSFontAttributeName: DefaultTextLabelFont, NSForegroundColorAttributeName: DefaultLabelColor, NSParagraphStyleAttributeName: paragraphStyle};
    appearance.detailTextLabelAttributes = @{NSFontAttributeName: DefaultDetailTextLabelFont, NSForegroundColorAttributeName: DefaultLabelColor, NSParagraphStyleAttributeName: paragraphStyle1};
}

@end
