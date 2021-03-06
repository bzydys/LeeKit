
//
//  LeeEmptyView.m
//  LeeKit
//
//  Created by Lee on 2018/3/12.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "LeeEmptyView.h"
#import "UIControl+Lee.h"

static inline UIColor * UIColorMake(NSInteger r,NSInteger g,NSInteger b){
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1];
}

@interface LeeEmptyView()
@property(nonatomic, strong) UIScrollView *scrollView;  // 保证内容超出屏幕时也不至于直接被clip（比如横屏时）
@end

@implementation LeeEmptyView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self didInitialized];
    }
    return self;
}

- (void)didInitialized {
    // 系统默认会在view即将被add到window上时才设置这些值，这个时机有点晚了，因为我们可能在add到window之前就进行sizeThatFits计算或对view进行截图等操作，因此这里提前到init时就去做
    LeeEmptyView *appearance = [LeeEmptyView appearance];
    _imageViewInsets = appearance.imageViewInsets;
    _loadingViewInsets = appearance.loadingViewInsets;
    _textLabelInsets = appearance.textLabelInsets;
    _detailTextLabelInsets = appearance.detailTextLabelInsets;
    _actionButtonInsets = appearance.actionButtonInsets;
    _verticalOffset = appearance.verticalOffset;
    _textLabelFont = appearance.textLabelFont;
    _detailTextLabelFont = appearance.detailTextLabelFont;
    _actionButtonFont = appearance.actionButtonFont;
    _textLabelTextColor = appearance.textLabelTextColor;
    _detailTextLabelTextColor = appearance.detailTextLabelTextColor;
    _actionButtonTitleColor = appearance.actionButtonTitleColor;
    
    self.scrollView = [[UIScrollView alloc] init];
    if (@available(iOS 11, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 10, 0, 10); // 避免 label 直接撑满到屏幕两边，不好看
    [self addSubview:self.scrollView];
    
    _contentView = [[UIView alloc] init];
    [self.scrollView addSubview:self.contentView];
    
    _loadingView = (UIView<LeeEmptyViewProtocol> *)[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    ((UIActivityIndicatorView *)self.loadingView).hidesWhenStopped = NO;    // 此控件是通过loadingView.hidden属性来控制显隐的，如果UIActivityIndicatorView的hidesWhenStopped属性设置为YES的话，则手动设置它的hidden属性就会失效，因此这里要置为NO
    [self.contentView addSubview:self.loadingView];
    
    _imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:self.imageView];
    
    _textLabel = [[UILabel alloc] init];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.numberOfLines = 0;
    [self.contentView addSubview:self.textLabel];
    
    _detailTextLabel = [[UILabel alloc] init];
    self.detailTextLabel.textAlignment = NSTextAlignmentCenter;
    self.detailTextLabel.numberOfLines = 0;
    [self.contentView addSubview:self.detailTextLabel];
    
    _actionButton = [[UIButton alloc] init];
    self.actionButton.lee_outsideEdge = UIEdgeInsetsMake(-20, -20, -20, -20);
    [self.contentView addSubview:self.actionButton];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.scrollView.frame = self.bounds;
    
    CGSize contentViewSize = [self sizeThatContentViewFits];
    self.contentView.frame = CGRectMake(0, CGRectGetMidY(self.scrollView.bounds) - contentViewSize.height / 2 + self.verticalOffset, contentViewSize.width, contentViewSize.height);
    
    self.scrollView.contentSize = CGSizeMake(fmax(CGRectGetWidth(self.scrollView.bounds) - self.scrollView.contentInset.left - self.scrollView.contentInset.right, contentViewSize.width), fmax(CGRectGetHeight(self.scrollView.bounds) - self.scrollView.contentInset.bottom - self.scrollView.contentInset.top, CGRectGetMaxY(self.contentView.frame)));
    
    CGFloat originY = 0;
    if (!self.imageView.hidden) {
        [self.imageView sizeToFit];
        self.imageView.frame = CGRectMake((CGRectGetWidth(self.scrollView.bounds) - CGRectGetWidth(self.imageView.frame))/2.0 + self.imageViewInsets.left - self.imageViewInsets.right, originY + self.imageViewInsets.top, CGRectGetWidth(self.imageView.bounds), CGRectGetHeight(self.imageView.bounds));
        originY = CGRectGetMaxY(self.imageView.frame) + self.imageViewInsets.bottom;
    }
    
    if (!self.loadingView.hidden) {
        self.loadingView.frame = CGRectMake((CGRectGetWidth(self.contentView.bounds) - CGRectGetWidth(self.loadingView.bounds))/2.0 + self.loadingViewInsets.left - self.loadingViewInsets.right, originY + self.loadingViewInsets.top, CGRectGetWidth(self.loadingView.bounds), CGRectGetHeight(self.loadingView.bounds));
        originY = CGRectGetMaxY(self.loadingView.frame) + self.loadingViewInsets.bottom;
    }
    
    if (!self.textLabel.hidden) {
        CGFloat labelWidth = CGRectGetWidth(self.contentView.bounds) - self.textLabelInsets.left - self.textLabelInsets.right;
        CGSize labelSize = [self.textLabel sizeThatFits:CGSizeMake(labelWidth, CGFLOAT_MAX)];
        self.textLabel.frame = CGRectMake(self.textLabelInsets.left, originY + self.textLabelInsets.top, labelWidth, labelSize.height);
        originY = CGRectGetMaxY(self.textLabel.frame) + self.textLabelInsets.bottom;
    }
    
    if (!self.detailTextLabel.hidden) {
        CGFloat labelWidth = CGRectGetWidth(self.contentView.bounds) - self.detailTextLabelInsets.left - self.detailTextLabelInsets.right;
        CGSize labelSize = [self.detailTextLabel sizeThatFits:CGSizeMake(labelWidth, CGFLOAT_MAX)];
        self.detailTextLabel.frame = CGRectMake(self.detailTextLabelInsets.left, originY + self.detailTextLabelInsets.top, labelWidth, labelSize.height);
        originY = CGRectGetMaxY(self.detailTextLabel.frame) + self.detailTextLabelInsets.bottom;
    }
    
    if (!self.actionButton.hidden) {
        [self.actionButton sizeToFit];
        self.actionButton.frame = CGRectMake((CGRectGetWidth(self.contentView.bounds) - CGRectGetWidth(self.actionButton.bounds))/2.0 + self.actionButtonInsets.left - self.actionButtonInsets.right, originY + self.actionButtonInsets.top, CGRectGetWidth(self.actionButton.bounds), CGRectGetHeight(self.actionButton.bounds));
        originY = CGRectGetMaxY(self.actionButton.frame) + self.actionButtonInsets.bottom;
    }
    
    
}

- (CGSize)sizeThatContentViewFits {
    CGFloat resultWidth = CGRectGetWidth(self.scrollView.bounds) - self.scrollView.contentInset.left - self.scrollView.contentInset.right;
    
    CGFloat imageViewHeight = [self.imageView sizeThatFits:CGSizeMake(resultWidth, CGFLOAT_MAX)].height + self.imageViewInsets.top + self.imageViewInsets.bottom;
    CGFloat loadingViewHeight = CGRectGetHeight(self.loadingView.bounds)+ self.loadingViewInsets.top + self.loadingViewInsets.bottom;
    CGFloat textLabelHeight = [self.textLabel sizeThatFits:CGSizeMake(resultWidth, CGFLOAT_MAX)].height + self.textLabelInsets.top + self.textLabelInsets.bottom;
    CGFloat detailTextLabelHeight = [self.detailTextLabel sizeThatFits:CGSizeMake(resultWidth, CGFLOAT_MAX)].height + self.detailTextLabelInsets.top + self.detailTextLabelInsets.bottom;
    CGFloat actionButtonHeight = [self.actionButton sizeThatFits:CGSizeMake(resultWidth, CGFLOAT_MAX)].height + self.actionButtonInsets.top + self.actionButtonInsets.bottom;
    CGFloat resultHeight = 0;
    if (!self.imageView.hidden) {
        resultHeight += imageViewHeight;
    }
    if (!self.loadingView.hidden) {
        resultHeight += loadingViewHeight;
    }
    if (!self.textLabel.hidden) {
        resultHeight += textLabelHeight;
    }
    if (!self.detailTextLabel.hidden) {
        resultHeight += detailTextLabelHeight;
    }
    if (!self.actionButton.hidden) {
        resultHeight += actionButtonHeight;
    }
    return CGSizeMake(resultWidth, resultHeight);
}

- (void)updateDetailTextLabelWithText:(NSString *)text {
    if (self.detailTextLabelFont && self.detailTextLabelTextColor && text) {
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.minimumLineHeight = self.detailTextLabelFont.pointSize + 10;
        paragraphStyle.maximumLineHeight = self.detailTextLabelFont.pointSize + 10;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:text attributes:@{
                                                                                                  NSFontAttributeName: self.detailTextLabelFont,
                                                                                                  NSForegroundColorAttributeName: self.detailTextLabelTextColor,
                                                                                                  NSParagraphStyleAttributeName: paragraphStyle
                                                                                                  }];
        self.detailTextLabel.attributedText = string;
    }
    self.detailTextLabel.hidden = !text;
    //下次runloop刷新
    [self setNeedsLayout];
}

-(void)setLoadingView:(UIView<LeeEmptyViewProtocol> *)loadingView{
    if (self.loadingView != loadingView) {
        [self.loadingView removeFromSuperview];
        _loadingView = loadingView;
        [self.contentView addSubview:_loadingView];
    }
    [self setNeedsLayout];
}

- (void)setLoadingViewHidden:(BOOL)hidden {
    self.loadingView.hidden = hidden;
    if (!hidden && [self.loadingView respondsToSelector:@selector(startAnimating)]) {
        [self.loadingView startAnimating];
    }
    [self setNeedsLayout];
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
    self.imageView.hidden = !image;
    [self setNeedsLayout];
}

- (void)setTextLabelText:(NSString *)text {
    self.textLabel.text = text;
    self.textLabel.hidden = !text;
    [self setNeedsLayout];
}

- (void)setDetailTextLabelText:(NSString *)text {
    [self updateDetailTextLabelWithText:text];
}

- (void)setActionButtonTitle:(NSString *)title {
    [self.actionButton setTitle:title forState:UIControlStateNormal];
    self.actionButton.hidden = !title;
    [self setNeedsLayout];
}

- (void)setImageViewInsets:(UIEdgeInsets)imageViewInsets {
    _imageViewInsets = imageViewInsets;
    [self setNeedsLayout];
}

-(void)setTextLabelInsets:(UIEdgeInsets)textLabelInsets {
    _textLabelInsets = textLabelInsets;
    [self setNeedsLayout];
}

- (void)setDetailTextLabelInsets:(UIEdgeInsets)detailTextLabelInsets {
    _detailTextLabelInsets = detailTextLabelInsets;
    [self setNeedsLayout];
}

- (void)setActionButtonInsets:(UIEdgeInsets)actionButtonInsets {
    _actionButtonInsets = actionButtonInsets;
    [self setNeedsLayout];
}

- (void)setVerticalOffset:(CGFloat)verticalOffset {
    _verticalOffset = verticalOffset;
    [self setNeedsLayout];
}

- (void)setTextLabelFont:(UIFont *)textLabelFont {
    _textLabelFont = textLabelFont;
    self.textLabel.font = textLabelFont;
    [self setNeedsLayout];
}

- (void)setDetailTextLabelFont:(UIFont *)detailTextLabelFont {
    _detailTextLabelFont = detailTextLabelFont;
    [self updateDetailTextLabelWithText:self.detailTextLabel.text];
}

- (void)setActionButtonFont:(UIFont *)actionButtonFont {
    _actionButtonFont = actionButtonFont;
    self.actionButton.titleLabel.font = actionButtonFont;
    [self setNeedsLayout];
}
- (void)setTextLabelTextColor:(UIColor *)textLabelTextColor {
    _textLabelTextColor = textLabelTextColor;
    self.textLabel.textColor = textLabelTextColor;
}

- (void)setDetailTextLabelTextColor:(UIColor *)detailTextLabelTextColor {
    _detailTextLabelTextColor = detailTextLabelTextColor;
    [self updateDetailTextLabelWithText:self.detailTextLabel.text];
}

- (void)setActionButtonTitleColor:(UIColor *)actionButtonTitleColor {
    _actionButtonTitleColor = actionButtonTitleColor;
    [self.actionButton setTitleColor:actionButtonTitleColor forState:UIControlStateNormal];
}

@end

@interface LeeEmptyView (UIAppearance)

@end

@implementation LeeEmptyView (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setDefaultAppearance];
    });
}

+ (void)setDefaultAppearance {
    LeeEmptyView *appearance = [LeeEmptyView appearance];
    appearance.imageViewInsets = UIEdgeInsetsMake(0, 0, 36, 0);
    appearance.loadingViewInsets = UIEdgeInsetsMake(0, 0, 36, 0);
    appearance.textLabelInsets = UIEdgeInsetsMake(0, 0, 10, 0);
    appearance.detailTextLabelInsets = UIEdgeInsetsMake(0, 0, 10, 0);
    appearance.actionButtonInsets = UIEdgeInsetsZero;
    appearance.verticalOffset = -30;
    
    appearance.textLabelFont = [UIFont systemFontOfSize:15];
    appearance.detailTextLabelFont = [UIFont systemFontOfSize:14];
    appearance.actionButtonFont = [UIFont systemFontOfSize:15];
    
    appearance.textLabelTextColor = UIColorMake(93, 100, 110);
    appearance.detailTextLabelTextColor = UIColorMake(133, 140, 150);
    appearance.actionButtonTitleColor = UIColorMake(49, 189, 243);
}


@end
