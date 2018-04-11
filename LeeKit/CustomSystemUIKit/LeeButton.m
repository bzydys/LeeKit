//
//  LeeButton.m
//  LeeKit
//
//  Created by Lee on 2018/3/14.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "LeeButton.h"
#import "CALayer+Lee.h"
#define CG_INLINE static inline

CG_INLINE CGRect
CGRectSetX(CGRect rect, CGFloat x) {
    rect.origin.x = x;
    return rect;
}

CG_INLINE CGRect
CGRectSetY(CGRect rect, CGFloat y) {
    rect.origin.y = y;
    return rect;
}

//CG_INLINE CGRect
//CGRectSetXY(CGRect rect, CGFloat x, CGFloat y) {
//    rect.origin.x = x;
//    rect.origin.y = y;
//    return rect;
//}

CG_INLINE CGRect
CGRectSetWidth(CGRect rect, CGFloat width) {
    rect.size.width = width;
    return rect;
}

CG_INLINE CGRect
CGRectSetHeight(CGRect rect, CGFloat height) {
    rect.size.height = height;
    return rect;
}

/// 用于居中运算
CG_INLINE CGFloat
CGFloatGetCenter(CGFloat parent, CGFloat child) {
    return (parent - child) / 2.0;
}


@interface LeeButton ()

@property(nonatomic, strong) CALayer *highlightedBackgroundLayer;
@property(nonatomic, strong) UIColor *originBorderColor;
@property(nonatomic, strong) UIColor *originBackgroundColor;

- (void)didInitialized;// UISubclassingHooks

@end

@implementation LeeButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self didInitialized];
        
        self.tintColor = [UIColor blueColor];
        if (!self.adjustsTitleTintColorAutomatically) {
            [self setTitleColor:self.tintColor forState:UIControlStateNormal];
        }
        
        // iOS7以后的button，sizeToFit后默认会自带一个上下的contentInsets，为了保证按钮大小即为内容大小，这里直接去掉，改为一个最小的值。
        self.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
    return self;
}

- (void)didInitialized {
    self.adjustsTitleTintColorAutomatically = NO;
    self.adjustsImageTintColorAutomatically = NO;
    
    // 默认接管highlighted和disabled的表现，去掉系统默认的表现
    self.adjustsImageWhenHighlighted = NO;
    self.adjustsImageWhenDisabled = NO;
    self.adjustsButtonWhenHighlighted = YES;
    self.adjustsButtonWhenDisabled = YES;
    
    // 图片默认在按钮左边，与系统UIButton保持一致
    self.imagePosition = LeeButtonImagePositionLeft;
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (CGSizeEqualToSize(self.bounds.size, size)) {
        size = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    }
    BOOL isImageViewShowing = self.imageView && !self.imageView.hidden;
    BOOL isTitleLabelShowing = self.titleLabel && !self.titleLabel.hidden;
    CGSize imageTotalSize = CGSizeZero;// 包含 imageEdgeInsets 那些空间
    CGSize titleTotalSize = CGSizeZero;// 包含 titleEdgeInsets 那些空间
    CGFloat spacingBetweenImageAndTitle = isImageViewShowing && isTitleLabelShowing ? self.spacingBetweenImageAndTitle : 0;// 如果图片或文字某一者没显示，则这个 spacing 不考虑进布局
    UIEdgeInsets contentEdgeInsets = self.contentEdgeInsets;
    CGSize resultSize = CGSizeZero;
    CGSize contentLimitSize = CGSizeMake(size.width - contentEdgeInsets.left - contentEdgeInsets.right, size.height - contentEdgeInsets.top - contentEdgeInsets.bottom);
    
    switch (self.imagePosition) {
        case LeeButtonImagePositionTop:
        case LeeButtonImagePositionBottom: {
            // 图片和文字上下排版时，宽度以文字或图片的最大宽度为最终宽度
            if (isImageViewShowing) {
                CGFloat imageLimitWidth = contentLimitSize.width - self.imageEdgeInsets.left - self.imageEdgeInsets.right;
                CGSize imageSize = [self.imageView sizeThatFits:CGSizeMake(imageLimitWidth, CGFLOAT_MAX)];// 假设图片高度必定完整显示
                imageSize.width = fmin(imageSize.width, imageLimitWidth);
                imageTotalSize = CGSizeMake(imageSize.width + self.imageEdgeInsets.left + self.imageEdgeInsets.right, imageSize.height + self.imageEdgeInsets.top + self.imageEdgeInsets.bottom);
            }
            
            if (isTitleLabelShowing) {
                CGSize titleLimitSize = CGSizeMake(contentLimitSize.width - self.titleEdgeInsets.left - self.titleEdgeInsets.right, contentLimitSize.height - imageTotalSize.height - spacingBetweenImageAndTitle - self.titleEdgeInsets.top - self.titleEdgeInsets.bottom);
                CGSize titleSize = [self.titleLabel sizeThatFits:titleLimitSize];
                titleSize.height = fmin(titleSize.height, titleLimitSize.height);
                titleTotalSize = CGSizeMake(titleSize.width + self.titleEdgeInsets.left + self.titleEdgeInsets.right, titleSize.height + self.titleEdgeInsets.top + self.titleEdgeInsets.bottom);
        
            }
            resultSize.width = contentEdgeInsets.left + contentEdgeInsets.right;
            resultSize.width += fmax(imageTotalSize.width, titleTotalSize.width);
            resultSize.height = contentEdgeInsets.top + contentEdgeInsets.bottom + imageTotalSize.height + spacingBetweenImageAndTitle + titleTotalSize.height;
        }
            break;
        case LeeButtonImagePositionLeft:
        case LeeButtonImagePositionRight:{
            if (isImageViewShowing) {
                CGFloat imageLimitHeight = contentLimitSize.height - self.imageEdgeInsets.top - self.imageEdgeInsets.bottom;
                CGSize imageSize = [self.imageView sizeThatFits:CGSizeMake(CGFLOAT_MAX, imageLimitHeight)];// 假设图片宽度必定完整显示，高度不超过按钮内容
                imageSize.height = fmin(imageSize.height, imageLimitHeight);
                imageTotalSize = CGSizeMake(imageSize.width + self.imageEdgeInsets.left + self.imageEdgeInsets.right, imageSize.height + self.imageEdgeInsets.top + self.imageEdgeInsets.bottom);
            }
            
            if (isTitleLabelShowing) {
                CGSize titleLimitSize = CGSizeMake(contentLimitSize.width - self.titleEdgeInsets.left - self.titleEdgeInsets.right - imageTotalSize.width - spacingBetweenImageAndTitle, contentLimitSize.height - self.titleEdgeInsets.top - self.titleEdgeInsets.bottom);
                CGSize titleSize = [self.titleLabel sizeThatFits:titleLimitSize];
                titleSize.height = fmin(titleSize.height, titleLimitSize.height);
                titleTotalSize = CGSizeMake(titleSize.width + self.titleEdgeInsets.left + self.titleEdgeInsets.right, titleSize.height + self.titleEdgeInsets.top + self.titleEdgeInsets.bottom);
            }
            
            resultSize.width = contentEdgeInsets.left + contentEdgeInsets.right + imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width;
            resultSize.height = contentEdgeInsets.top + contentEdgeInsets.bottom;
            resultSize.height += fmax(imageTotalSize.height, titleTotalSize.height);
        }
            break;
            
    }
    return resultSize;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    if (CGRectIsEmpty(self.bounds)) {
        return;
    }
    
    BOOL isImageViewShowing = self.imageView && !self.imageView.hidden;
    BOOL isTitleLabelShowing = self.titleLabel && !self.titleLabel.hidden;
    CGSize imageLimitSize = CGSizeZero;
    CGSize titleLimitSize = CGSizeZero;
    CGSize imageTotalSize = CGSizeZero;// 包含 imageEdgeInsets 那些空间
    CGSize titleTotalSize = CGSizeZero;// 包含 titleEdgeInsets 那些空间
    CGFloat spacingBetweenImageAndTitle = isImageViewShowing && isTitleLabelShowing ? self.spacingBetweenImageAndTitle : 0;// 如果图片或文字某一者没显示，则这个 spacing 不考虑进布局
    CGRect imageFrame = CGRectZero;
    CGRect titleFrame = CGRectZero;
    UIEdgeInsets contentEdgeInsets = self.contentEdgeInsets;
    CGSize contentSize = CGSizeMake(CGRectGetWidth(self.bounds) - contentEdgeInsets.left - contentEdgeInsets.right, CGRectGetHeight(self.bounds) - contentEdgeInsets.top - contentEdgeInsets.bottom);
    
    // 图片的布局原则都是尽量完整展示，所以不管 imagePosition 的值是什么，这个计算过程都是相同的
    if (isImageViewShowing) {
        imageLimitSize = CGSizeMake(contentSize.width - self.imageEdgeInsets.right - self.imageEdgeInsets.left, contentSize.height - self.imageEdgeInsets.top - self.imageEdgeInsets.bottom);
        CGSize imageSize = [self.imageView sizeThatFits:imageLimitSize];
        imageSize.width = fmin(imageLimitSize.width, imageSize.width);
        imageSize.height = fmin(imageLimitSize.height, imageSize.height);
        imageFrame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        imageTotalSize = CGSizeMake(imageSize.width + self.imageEdgeInsets.left + self.imageEdgeInsets.right, imageSize.height + self.imageEdgeInsets.top + self.imageEdgeInsets.bottom);
    }
    
    if (self.imagePosition == LeeButtonImagePositionTop || self.imagePosition == LeeButtonImagePositionBottom) {
        
        if (isTitleLabelShowing) {
            titleLimitSize = CGSizeMake(contentSize.width - self.titleEdgeInsets.left - self.titleEdgeInsets.right, contentSize.height - imageTotalSize.height - spacingBetweenImageAndTitle - self.titleEdgeInsets.top - self.titleEdgeInsets.bottom);
            CGSize titleSize = [self.titleLabel sizeThatFits:titleLimitSize];
            titleSize.width = fmin(titleLimitSize.width, titleSize.width);
            titleSize.height = fmin(titleLimitSize.height, titleSize.height);
            titleFrame = CGRectMake(0, 0, titleSize.width, titleSize.height);
            titleTotalSize = CGSizeMake(titleSize.width + self.titleEdgeInsets.left + self.titleEdgeInsets.right, titleSize.height + self.titleEdgeInsets.top + self.titleEdgeInsets.bottom);
        }
        
        switch (self.contentHorizontalAlignment) {
            case UIControlContentHorizontalAlignmentLeft:
                imageFrame = isImageViewShowing ? CGRectMake(contentEdgeInsets.left + self.imageEdgeInsets.left, imageFrame.origin.y, imageFrame.size.width, imageFrame.size.height) : imageFrame;
                titleFrame = isTitleLabelShowing ? CGRectMake(contentEdgeInsets.left + self.titleEdgeInsets.left, titleFrame.origin.y, titleFrame.size.width, titleFrame.size.height) : titleFrame;
                break;
            case UIControlContentHorizontalAlignmentCenter:
                imageFrame = isImageViewShowing ? CGRectMake(contentEdgeInsets.left + self.imageEdgeInsets.left + (imageLimitSize.width + CGRectGetWidth(imageFrame))/2.0, imageFrame.origin.y, imageFrame.size.width, imageFrame.size.height) : imageFrame;
                titleFrame = isTitleLabelShowing ? CGRectMake(contentEdgeInsets.left + self.titleEdgeInsets.left + (titleLimitSize.width + CGRectGetWidth(titleFrame))/2.0, titleFrame.origin.y, titleFrame.size.width, titleFrame.size.height) : titleFrame;
                break;
            case UIControlContentHorizontalAlignmentRight:
                imageFrame = isImageViewShowing ? CGRectSetX(imageFrame, CGRectGetWidth(self.bounds) - contentEdgeInsets.right - self.imageEdgeInsets.right - CGRectGetWidth(imageFrame)) : imageFrame;
                titleFrame = isTitleLabelShowing ? CGRectSetX(titleFrame, CGRectGetWidth(self.bounds) - contentEdgeInsets.right - self.titleEdgeInsets.right - CGRectGetWidth(titleFrame)) : titleFrame;
                break;
            case UIControlContentHorizontalAlignmentFill:
                if (isImageViewShowing) {
                    imageFrame = CGRectSetX(imageFrame, contentEdgeInsets.left + self.imageEdgeInsets.left);
                    imageFrame = CGRectSetWidth(imageFrame, imageLimitSize.width);
                }
                if (isTitleLabelShowing) {
                    titleFrame = CGRectSetX(titleFrame, contentEdgeInsets.left + self.titleEdgeInsets.left);
                    titleFrame = CGRectSetWidth(titleFrame, titleLimitSize.width);
                }
                break;
            default:
                break;
        }
        
        if (self.imagePosition == LeeButtonImagePositionTop) {
            switch (self.contentVerticalAlignment) {
                case UIControlContentVerticalAlignmentTop:
                    imageFrame = isImageViewShowing ? CGRectSetY(imageFrame, contentEdgeInsets.top + self.imageEdgeInsets.top) : imageFrame;
                    titleFrame = isTitleLabelShowing ? CGRectSetY(titleFrame, contentEdgeInsets.top + imageTotalSize.height + spacingBetweenImageAndTitle + self.titleEdgeInsets.top) : titleFrame;
                    break;
                case UIControlContentVerticalAlignmentCenter: {
                    CGFloat contentHeight = imageTotalSize.height + spacingBetweenImageAndTitle + titleTotalSize.height;
                    CGFloat minY = CGFloatGetCenter(contentSize.height, contentHeight) + contentEdgeInsets.top;
                    imageFrame = isImageViewShowing ? CGRectSetY(imageFrame, minY + self.imageEdgeInsets.top) : imageFrame;
                    titleFrame = isTitleLabelShowing ? CGRectSetY(titleFrame, minY + imageTotalSize.height + spacingBetweenImageAndTitle + self.titleEdgeInsets.top) : titleFrame;
                }
                    break;
                case UIControlContentVerticalAlignmentBottom:
                    titleFrame = isTitleLabelShowing ? CGRectSetY(titleFrame, CGRectGetHeight(self.bounds) - contentEdgeInsets.bottom - self.titleEdgeInsets.bottom - CGRectGetHeight(titleFrame)) : titleFrame;
                    imageFrame = isImageViewShowing ? CGRectSetY(imageFrame, CGRectGetHeight(self.bounds) - contentEdgeInsets.bottom - titleTotalSize.height - spacingBetweenImageAndTitle - self.imageEdgeInsets.bottom - CGRectGetHeight(imageFrame)) : imageFrame;
                    break;
                case UIControlContentVerticalAlignmentFill: {
                    if (isImageViewShowing && isTitleLabelShowing) {
                        
                        // 同时显示图片和 label 的情况下，图片高度按本身大小显示，剩余空间留给 label
                        imageFrame = isImageViewShowing ? CGRectSetY(imageFrame, contentEdgeInsets.top + self.imageEdgeInsets.top) : imageFrame;
                        titleFrame = isTitleLabelShowing ? CGRectSetY(titleFrame, contentEdgeInsets.top + imageTotalSize.height + spacingBetweenImageAndTitle + self.titleEdgeInsets.top) : titleFrame;
                        titleFrame = isTitleLabelShowing ? CGRectSetHeight(titleFrame, CGRectGetHeight(self.bounds) - contentEdgeInsets.bottom - self.titleEdgeInsets.bottom - CGRectGetMinY(titleFrame)) : titleFrame;
                        
                    } else if (isImageViewShowing) {
                        imageFrame = CGRectSetY(imageFrame, contentEdgeInsets.top + self.imageEdgeInsets.top);
                        imageFrame = CGRectSetHeight(imageFrame, contentSize.height - self.imageEdgeInsets.top - self.imageEdgeInsets.bottom);
                    } else {
                        titleFrame = CGRectSetY(titleFrame, contentEdgeInsets.top + self.titleEdgeInsets.top);
                        titleFrame = CGRectSetHeight(titleFrame, contentSize.height - self.titleEdgeInsets.top - self.titleEdgeInsets.bottom);
                    }
                }
                    break;
            }
        } else {
            switch (self.contentVerticalAlignment) {
                case UIControlContentVerticalAlignmentTop:
                    titleFrame = isTitleLabelShowing ? CGRectSetY(titleFrame, contentEdgeInsets.top + self.titleEdgeInsets.top) : titleFrame;
                    imageFrame = isImageViewShowing ? CGRectSetY(imageFrame, contentEdgeInsets.top + titleTotalSize.height + spacingBetweenImageAndTitle + self.imageEdgeInsets.top) : imageFrame;
                    break;
                case UIControlContentVerticalAlignmentCenter: {
                    CGFloat contentHeight = imageTotalSize.height + titleTotalSize.height + spacingBetweenImageAndTitle;
                    CGFloat minY = CGFloatGetCenter(contentSize.height, contentHeight) + contentEdgeInsets.top;
                    titleFrame = isTitleLabelShowing ? CGRectSetY(titleFrame, minY + self.titleEdgeInsets.top) : titleFrame;
                    imageFrame = isImageViewShowing ? CGRectSetY(imageFrame, minY + titleTotalSize.height + spacingBetweenImageAndTitle + self.imageEdgeInsets.top) : imageFrame;
                }
                    break;
                case UIControlContentVerticalAlignmentBottom:
                    imageFrame = isImageViewShowing ? CGRectSetY(imageFrame, CGRectGetHeight(self.bounds) - contentEdgeInsets.bottom - self.imageEdgeInsets.bottom - CGRectGetHeight(imageFrame)) : imageFrame;
                    titleFrame = isTitleLabelShowing ? CGRectSetY(titleFrame, CGRectGetHeight(self.bounds) - contentEdgeInsets.bottom - imageTotalSize.height - spacingBetweenImageAndTitle - self.titleEdgeInsets.bottom - CGRectGetHeight(titleFrame)) : titleFrame;
                    break;
                case UIControlContentVerticalAlignmentFill: {
                    if (isImageViewShowing && isTitleLabelShowing) {
                        
                        // 同时显示图片和 label 的情况下，图片高度按本身大小显示，剩余空间留给 label
                        imageFrame = CGRectSetY(imageFrame, CGRectGetHeight(self.bounds) - contentEdgeInsets.bottom - self.imageEdgeInsets.bottom - CGRectGetHeight(imageFrame));
                        titleFrame = CGRectSetY(titleFrame, contentEdgeInsets.top + self.titleEdgeInsets.top);
                        titleFrame = CGRectSetHeight(titleFrame, CGRectGetHeight(self.bounds) - contentEdgeInsets.bottom - imageTotalSize.height - spacingBetweenImageAndTitle - self.titleEdgeInsets.bottom - CGRectGetMinY(titleFrame));
                        
                    } else if (isImageViewShowing) {
                        imageFrame = CGRectSetY(imageFrame, contentEdgeInsets.top + self.imageEdgeInsets.top);
                        imageFrame = CGRectSetHeight(imageFrame, contentSize.height - self.imageEdgeInsets.top - self.imageEdgeInsets.bottom);
                    } else {
                        titleFrame = CGRectSetY(titleFrame, contentEdgeInsets.top + self.titleEdgeInsets.top);
                        titleFrame = CGRectSetHeight(titleFrame, contentSize.height - self.titleEdgeInsets.top - self.titleEdgeInsets.bottom);
                    }
                }
                    break;
            }
        }
        
        self.imageView.frame = imageFrame;
        self.titleLabel.frame = titleFrame;
        
    } else if (self.imagePosition == LeeButtonImagePositionLeft || self.imagePosition == LeeButtonImagePositionRight) {
        
        if (isTitleLabelShowing) {
            titleLimitSize = CGSizeMake(contentSize.width - self.titleEdgeInsets.left - self.titleEdgeInsets.right - imageTotalSize.width - spacingBetweenImageAndTitle, contentSize.height - self.titleEdgeInsets.top - self.titleEdgeInsets.bottom);
            CGSize titleSize = [self.titleLabel sizeThatFits:titleLimitSize];
            titleSize.width = fmin(titleLimitSize.width, titleSize.width);
            titleSize.height = fmin(titleLimitSize.height, titleSize.height);
            titleFrame = CGRectMake(0, 0, titleSize.width, titleSize.height);
            titleTotalSize = CGSizeMake(titleSize.width + self.titleEdgeInsets.left + self.titleEdgeInsets.right, titleSize.height + self.titleEdgeInsets.top + self.titleEdgeInsets.bottom);
        }
        
        switch (self.contentVerticalAlignment) {
            case UIControlContentVerticalAlignmentTop:
                imageFrame = isImageViewShowing ? CGRectSetY(imageFrame, contentEdgeInsets.top + self.imageEdgeInsets.top) : imageFrame;
                titleFrame = isTitleLabelShowing ? CGRectSetY(titleFrame, contentEdgeInsets.top + self.titleEdgeInsets.top) : titleFrame;
                
                break;
            case UIControlContentVerticalAlignmentCenter:
                imageFrame = isImageViewShowing ? CGRectSetY(imageFrame, contentEdgeInsets.top + CGFloatGetCenter(contentSize.height, CGRectGetHeight(imageFrame)) + self.imageEdgeInsets.top) : imageFrame;
                titleFrame = isTitleLabelShowing ? CGRectSetY(titleFrame, contentEdgeInsets.top + CGFloatGetCenter(contentSize.height, CGRectGetHeight(titleFrame)) + self.titleEdgeInsets.top) : titleFrame;
                break;
            case UIControlContentVerticalAlignmentBottom:
                imageFrame = isImageViewShowing ? CGRectSetY(imageFrame, CGRectGetHeight(self.bounds) - contentEdgeInsets.bottom - self.imageEdgeInsets.bottom - CGRectGetHeight(imageFrame)) : imageFrame;
                titleFrame = isTitleLabelShowing ? CGRectSetY(titleFrame, CGRectGetHeight(self.bounds) - contentEdgeInsets.bottom - self.titleEdgeInsets.bottom - CGRectGetHeight(titleFrame)) : titleFrame;
                break;
            case UIControlContentVerticalAlignmentFill:
                if (isImageViewShowing) {
                    imageFrame = CGRectSetY(imageFrame, contentEdgeInsets.top + self.imageEdgeInsets.top);
                    imageFrame = CGRectSetHeight(imageFrame, contentSize.height - self.imageEdgeInsets.top - self.imageEdgeInsets.bottom);
                }
                if (isTitleLabelShowing) {
                    titleFrame = CGRectSetY(titleFrame, contentEdgeInsets.top + self.titleEdgeInsets.top);
                    titleFrame = CGRectSetHeight(titleFrame, contentSize.height - self.titleEdgeInsets.top - self.titleEdgeInsets.bottom);
                }
                break;
        }
        
        if (self.imagePosition == LeeButtonImagePositionLeft) {
            switch (self.contentHorizontalAlignment) {
                case UIControlContentHorizontalAlignmentLeft:
                    imageFrame = isImageViewShowing ? CGRectSetX(imageFrame, contentEdgeInsets.left + self.imageEdgeInsets.left) : imageFrame;
                    titleFrame = isTitleLabelShowing ? CGRectSetX(titleFrame, contentEdgeInsets.left + imageTotalSize.width + spacingBetweenImageAndTitle + self.titleEdgeInsets.left) : titleFrame;
                    break;
                case UIControlContentHorizontalAlignmentCenter: {
                    CGFloat contentWidth = imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width;
                    CGFloat minX = contentEdgeInsets.left + CGFloatGetCenter(contentSize.width, contentWidth);
                    imageFrame = isImageViewShowing ? CGRectSetX(imageFrame, minX + self.imageEdgeInsets.left) : imageFrame;
                    titleFrame = isTitleLabelShowing ? CGRectSetX(titleFrame, minX + imageTotalSize.width + spacingBetweenImageAndTitle + self.titleEdgeInsets.left) : titleFrame;
                }
                    break;
                case UIControlContentHorizontalAlignmentRight: {
                    if (imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width > contentSize.width) {
                        // 图片和文字总宽超过按钮宽度，则优先完整显示图片
                        imageFrame = isImageViewShowing ? CGRectSetX(imageFrame, contentEdgeInsets.left + self.imageEdgeInsets.left) : imageFrame;
                        titleFrame = isTitleLabelShowing ? CGRectSetX(titleFrame, contentEdgeInsets.left + imageTotalSize.width + spacingBetweenImageAndTitle + self.titleEdgeInsets.left) : titleFrame;
                    } else {
                        // 内容不超过按钮宽度，则靠右布局即可
                        titleFrame = isTitleLabelShowing ? CGRectSetX(titleFrame, CGRectGetWidth(self.bounds) - contentEdgeInsets.right - self.titleEdgeInsets.right - CGRectGetWidth(titleFrame)) : titleFrame;
                        imageFrame = isImageViewShowing ? CGRectSetX(imageFrame, CGRectGetWidth(self.bounds) - contentEdgeInsets.right - titleTotalSize.width - spacingBetweenImageAndTitle - imageTotalSize.width + self.imageEdgeInsets.left) : imageFrame;
                    }
                }
                    break;
                case UIControlContentHorizontalAlignmentFill: {
                    if (isImageViewShowing && isTitleLabelShowing) {
                        // 同时显示图片和 label 的情况下，图片按本身宽度显示，剩余空间留给 label
                        imageFrame = CGRectSetX(imageFrame, contentEdgeInsets.left + self.imageEdgeInsets.left);
                        titleFrame = CGRectSetX(titleFrame, contentEdgeInsets.left + imageTotalSize.width + spacingBetweenImageAndTitle + self.titleEdgeInsets.left);
                        titleFrame = CGRectSetWidth(titleFrame, CGRectGetWidth(self.bounds) - contentEdgeInsets.right - self.titleEdgeInsets.right - CGRectGetMinX(titleFrame));
                    } else if (isImageViewShowing) {
                        imageFrame = CGRectSetX(imageFrame, contentEdgeInsets.left + self.imageEdgeInsets.left);
                        imageFrame = CGRectSetWidth(imageFrame, contentSize.width - self.imageEdgeInsets.left - self.imageEdgeInsets.right);
                    } else {
                        titleFrame = CGRectSetX(titleFrame, contentEdgeInsets.left + self.titleEdgeInsets.left);
                        titleFrame = CGRectSetWidth(titleFrame, contentSize.width - self.titleEdgeInsets.left - self.titleEdgeInsets.right);
                    }
                }
                    break;
                default:
                    break;
            }
        } else {
            switch (self.contentHorizontalAlignment) {
                case UIControlContentHorizontalAlignmentLeft: {
                    if (imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width > contentSize.width) {
                        // 图片和文字总宽超过按钮宽度，则优先完整显示图片
                        imageFrame = isImageViewShowing ? CGRectSetX(imageFrame, CGRectGetWidth(self.bounds) - contentEdgeInsets.right - self.imageEdgeInsets.right - CGRectGetWidth(imageFrame)) : imageFrame;
                        titleFrame = isTitleLabelShowing ? CGRectSetX(titleFrame, CGRectGetWidth(self.bounds) - contentEdgeInsets.right - imageTotalSize.width - spacingBetweenImageAndTitle - titleTotalSize.width + self.titleEdgeInsets.left) : titleFrame;
                    } else {
                        // 内容不超过按钮宽度，则靠左布局即可
                        titleFrame = isTitleLabelShowing ? CGRectSetX(titleFrame, contentEdgeInsets.left + self.titleEdgeInsets.left) : titleFrame;
                        imageFrame = isImageViewShowing ? CGRectSetX(imageFrame, contentEdgeInsets.left + titleTotalSize.width + spacingBetweenImageAndTitle + self.imageEdgeInsets.left) : imageFrame;
                    }
                }
                    break;
                case UIControlContentHorizontalAlignmentCenter: {
                    CGFloat contentWidth = imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width;
                    CGFloat minX = contentEdgeInsets.left + CGFloatGetCenter(contentSize.width, contentWidth);
                    titleFrame = isTitleLabelShowing ? CGRectSetX(titleFrame, minX + self.titleEdgeInsets.left) : titleFrame;
                    imageFrame = isImageViewShowing ? CGRectSetX(imageFrame, minX + titleTotalSize.width + spacingBetweenImageAndTitle + self.imageEdgeInsets.left) : imageFrame;
                }
                    break;
                case UIControlContentHorizontalAlignmentRight:
                    imageFrame = isImageViewShowing ? CGRectSetX(imageFrame, CGRectGetWidth(self.bounds) - contentEdgeInsets.right - self.imageEdgeInsets.right - CGRectGetWidth(imageFrame)) : imageFrame;
                    titleFrame = isTitleLabelShowing ? CGRectSetX(titleFrame, CGRectGetWidth(self.bounds) - contentEdgeInsets.right - imageTotalSize.width - spacingBetweenImageAndTitle - self.titleEdgeInsets.right - CGRectGetWidth(titleFrame)) : titleFrame;
                    break;
                case UIControlContentHorizontalAlignmentFill: {
                    if (isImageViewShowing && isTitleLabelShowing) {
                        // 图片按自身大小显示，剩余空间由标题占满
                        imageFrame = CGRectSetX(imageFrame, CGRectGetWidth(self.bounds) - contentEdgeInsets.right - self.imageEdgeInsets.right - CGRectGetWidth(imageFrame));
                        titleFrame = CGRectSetX(titleFrame, contentEdgeInsets.left + self.titleEdgeInsets.left);
                        titleFrame = CGRectSetWidth(titleFrame, CGRectGetMinX(imageFrame) - self.imageEdgeInsets.left - spacingBetweenImageAndTitle - self.titleEdgeInsets.right - CGRectGetMinX(titleFrame));
                        
                    } else if (isImageViewShowing) {
                        imageFrame = CGRectSetX(imageFrame, contentEdgeInsets.left + self.imageEdgeInsets.left);
                        imageFrame = CGRectSetWidth(imageFrame, contentSize.width - self.imageEdgeInsets.left - self.imageEdgeInsets.right);
                    } else {
                        titleFrame = CGRectSetX(titleFrame, contentEdgeInsets.left + self.titleEdgeInsets.left);
                        titleFrame = CGRectSetWidth(titleFrame, contentSize.width - self.titleEdgeInsets.left - self.titleEdgeInsets.right);
                    }
                }
                    break;
                default:
                    break;
            }
        }
        
        self.imageView.frame = imageFrame;
        self.titleLabel.frame = titleFrame;
    }
}

#pragma mark - getter & setter
- (void)setSpacingBetweenImageAndTitle:(CGFloat)spacingBetweenImageAndTitle {
    _spacingBetweenImageAndTitle = spacingBetweenImageAndTitle;
    
    [self setNeedsLayout];
}

-(void)setImagePosition:(LeeButtonImagePosition)imagePosition {
    _imagePosition = imagePosition;
    
    [self setNeedsLayout];
}

- (void)setHighlightedBackgroundColor:(UIColor *)highlightedBackgroundColor {
    _highlightedBackgroundColor = highlightedBackgroundColor;
    if (_highlightedBackgroundColor) {
        // 只要开启了highlightedBackgroundColor，就默认不需要alpha的高亮
        self.adjustsButtonWhenHighlighted = NO;
    }
}

- (void)setHighlightedBorderColor:(UIColor *)highlightedBorderColor {
    _highlightedBorderColor = highlightedBorderColor;
    if (_highlightedBorderColor) {
        // 只要开启了highlightedBorderColor，就默认不需要alpha的高亮
        self.adjustsButtonWhenHighlighted = NO;
        
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted && !self.originBorderColor) {
        // 手指按在按钮上会不断触发setHighlighted:，所以这里做了保护，设置过一次就不用再设置了
        self.originBorderColor = [UIColor colorWithCGColor:self.layer.borderColor];
    }
    
    // 渲染背景色
    if (self.highlightedBackgroundColor || self.highlightedBorderColor) {
        [self adjustsButtonHighlighted];
    }
    
    // 如果此时是disabled，则disabled的样式优先
    if (!self.enabled) {
        return;
    }
    
    //自定义hightlighted样式
    if (self.adjustsButtonWhenHighlighted) {
        if (highlighted) {
            self.alpha = 0.7;
        } else {
            [UIView animateWithDuration:0.25f animations:^{
                self.alpha = 1;
            }];
        }
    }
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    if (!enabled && self.adjustsButtonWhenDisabled) {
        self.alpha = 0.5;
    } else {
        [UIView animateWithDuration:0.25f animations:^{
            self.alpha = 1;
        }];
    }
}

- (void)setSelected:(BOOL)selected {
    if (self.isSelected != selected && selected == YES) {
        self.originBackgroundColor = self.backgroundColor;
    }
    [super setSelected:selected];
    if (selected && self.selectedBackgroundColor) {
        self.backgroundColor = self.selectedBackgroundColor;
    }else{
        self.backgroundColor = self.originBackgroundColor;
    }
}

- (void)adjustsButtonHighlighted {
    if (self.highlightedBackgroundColor) {
        if (!self.highlightedBackgroundLayer) {
            self.highlightedBackgroundLayer = [CALayer layer];
            [self.highlightedBackgroundLayer lee_removeDefaultAnimations];
            [self.layer insertSublayer:self.highlightedBackgroundLayer atIndex:0];
        }
        self.highlightedBackgroundLayer.frame = self.bounds;
        self.highlightedBackgroundLayer.cornerRadius = self.layer.cornerRadius;
        self.highlightedBackgroundLayer.backgroundColor = self.highlighted ? self.highlightedBackgroundColor.CGColor : [UIColor clearColor].CGColor;
    }
    
    if (self.highlightedBorderColor) {
        self.layer.borderColor = self.highlighted ? self.highlightedBorderColor.CGColor : self.originBorderColor.CGColor;
    }
}

- (void)setAdjustsTitleTintColorAutomatically:(BOOL)adjustsTitleTintColorAutomatically {
    _adjustsTitleTintColorAutomatically = adjustsTitleTintColorAutomatically;
    [self updateTitleColorIfNeeded];
}

- (void)updateTitleColorIfNeeded {
    if (self.adjustsTitleTintColorAutomatically && self.currentTitleColor) {
        [self setTitleColor:self.tintColor forState:UIControlStateNormal];
    }
    if (self.adjustsTitleTintColorAutomatically && self.currentAttributedTitle) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.currentAttributedTitle];
        [attributedString addAttribute:NSForegroundColorAttributeName value:self.tintColor range:NSMakeRange(0, attributedString.length)];
        [self setAttributedTitle:attributedString forState:UIControlStateNormal];
    }
}

- (void)setAdjustsImageTintColorAutomatically:(BOOL)adjustsImageTintColorAutomatically {
    BOOL valueDifference = _adjustsImageTintColorAutomatically != adjustsImageTintColorAutomatically;
    _adjustsImageTintColorAutomatically = adjustsImageTintColorAutomatically;
    
    if (valueDifference) {
        [self updateImageRenderingModeIfNeeded];
    }
}

- (void)updateImageRenderingModeIfNeeded {
    if (self.currentImage) {
        NSArray<NSNumber *> *states = @[@(UIControlStateNormal), @(UIControlStateHighlighted), @(UIControlStateDisabled)];
        
        // 实际上对于 UIButton 而言如果设置了 UIControlStateNormal 的 image，则其他所有 state 下的 image 默认都会返回 normal 这张图，所以这个判断只对 UIControlStateNormal 做就行了
        UIImage *normalImage = [self imageForState:UIControlStateNormal];
        if (!normalImage) return;
        
        for (NSNumber *number in states) {
            UIImage *image = [self imageForState:number.unsignedIntegerValue];
            if (number.unsignedIntegerValue > 0 && image == normalImage) {
                // 这个 state 下的 image 如果指针和 normal 一样，说明并没有对这个 state 设置特别的 image，所以不用处理
                continue;
            }
            
            if (self.adjustsImageTintColorAutomatically) {
                // 这里的 setImage: 操作不需要使用 renderingMode 对 image 重新处理，而是放到重写的 setImage:forState 里去做就行了
                [self setImage:image forState:[number unsignedIntegerValue]];
            } else {
                // 如果不需要用template的模式渲染，并且之前是使用template的，则把renderingMode改回Original
                [self setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:[number unsignedIntegerValue]];
            }
        }
    }
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    if (self.adjustsImageTintColorAutomatically) {
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    [super setImage:image forState:state];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    [self updateTitleColorIfNeeded];
    
    if (self.adjustsImageTintColorAutomatically) {
        [self updateImageRenderingModeIfNeeded];
    }
}

- (void)setTintColorAdjustsTitleAndImage:(UIColor *)tintColorAdjustsTitleAndImage {
    if (tintColorAdjustsTitleAndImage) {
        self.tintColor = tintColorAdjustsTitleAndImage;
        self.adjustsTitleTintColorAutomatically = YES;
        self.adjustsImageTintColorAutomatically = YES;
    }
}

- (UIColor *)tintColorAdjustsTitleAndImage {
    return self.tintColor;
}


@end
