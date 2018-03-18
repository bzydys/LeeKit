//
//  LeeGridView.m
//  LeeKit
//
//  Created by Lee on 2018/3/10.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "LeeGridView.h"
#import "CALayer+Lee.h"

static inline UIColor * UIColorMake(NSInteger r,NSInteger g,NSInteger b){
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1];
}

@interface LeeGridView ()

@property(nonatomic, strong) CAShapeLayer *separatorLayer;

@end

@implementation LeeGridView

- (instancetype)initWithFrame:(CGRect)frame column:(NSInteger)column rowHeight:(CGFloat)rowHeight {
    if (self = [super initWithFrame:frame]) {
        [self didInitialized];
        self.columnCount = column;
        self.rowHeight = rowHeight;
    }
    return self;
}

- (instancetype)initWithColumn:(NSUInteger)column rowHeight:(CGFloat)rowHeight {
    return [self initWithFrame:CGRectZero column:column rowHeight:rowHeight];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame column:0 rowHeight:0];
}

- (void)didInitialized{
    self.separatorLayer = [CAShapeLayer layer];
    [self.separatorLayer lee_removeDefaultAnimations];
    self.separatorLayer.hidden = YES;
    [self.layer addSublayer:self.separatorLayer];
    self.separatorColor = UIColorMake(222, 224, 226);
}

-(void)setSeparatorWidth:(CGFloat)separatorWidth{
    _separatorWidth = separatorWidth;
    self.separatorLayer.lineWidth = _separatorWidth;
    self.separatorLayer.hidden = _separatorWidth <= 0;
}

-(void)setSeparatorColor:(UIColor *)separatorColor{
    _separatorColor = separatorColor;
    self.separatorLayer.strokeColor = separatorColor.CGColor;
}

// 返回最接近平均列宽的值，保证其为整数向下取整，因此所有columnWidth加起来可能比总宽度要小
- (CGFloat)stretchColumnWidth {
    return floor((CGRectGetWidth(self.bounds) - self.separatorWidth * (self.columnCount - 1)) / self.columnCount);
}

-(NSUInteger)rowCount{
    NSUInteger subViewsCount = self.subviews.count;
    return ((subViewsCount - 1) / self.columnCount) + 1;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if (self.subviews.count == 0) return;
    
    if (self.bounds.size.width == 0 || self.bounds.size.height == 0) {
        return;
    }
    
    CGFloat columnWidth = [self stretchColumnWidth];
    CGFloat rowHeight = self.rowHeight;
    NSUInteger rowCount = self.columnCount;
    
    BOOL shouldShowSeparator = self.separatorWidth > 0;
    CGFloat lineOffSet = shouldShowSeparator ? self.separatorWidth/2.0 : 0;
    UIBezierPath *separatorPath = shouldShowSeparator ? [UIBezierPath bezierPath] : nil;
    for (NSUInteger row = 0; row < rowCount; row++) {
        for (NSUInteger column = 0; column < self.columnCount; column++) {
            NSInteger index = row * self.columnCount + column;
            if (index < self.subviews.count) {
                BOOL isLastColumn = column == self.columnCount - 1;
                BOOL isLastRow = row == rowCount - 1;
                UIView *subview = self.subviews[index];
                CGRect subviewFrame = CGRectMake(columnWidth * column + self.separatorWidth * column, rowHeight * row + self.separatorWidth * row, columnWidth, rowHeight);
                
                if (isLastColumn) {
                    // 每行最后一个item要占满剩余空间，否则可能因为strecthColumnWidth不精确导致右边漏空白
                    subviewFrame.size.width = self.bounds.size.width - columnWidth * (self.columnCount - 1) - self.separatorWidth * (self.columnCount - 1);
                }
                if (isLastRow) {
                    // 最后一行的item要占满剩余空间，避免一些计算偏差
                    subviewFrame.size.height = self.bounds.size.height - rowHeight * (rowCount - 1) - self.separatorWidth * (rowCount - 1);
                }
                
                subview.frame = subviewFrame;
                [subview setNeedsLayout];
                
                if (shouldShowSeparator) {
                    // 每个 item 都画右边和下边这两条分隔线
                    CGPoint rightTopPoint = CGPointMake(CGRectGetMaxX(subviewFrame) + lineOffSet, CGRectGetMinY(subviewFrame));
                    CGPoint rightBottomPoint = CGPointMake(rightTopPoint.x - (isLastColumn ? lineOffSet : 0), CGRectGetMaxY(subviewFrame) + (!isLastRow ? lineOffSet : 0));
                    CGPoint leftBottomPoint = CGPointMake(CGRectGetMinX(subviewFrame), rightBottomPoint.y);
                    
                    if (!isLastColumn) {
                        [separatorPath moveToPoint:rightTopPoint];
                        [separatorPath addLineToPoint:rightBottomPoint];
                    }
                    if (!isLastRow) {
                        [separatorPath moveToPoint:rightBottomPoint];
                        [separatorPath addLineToPoint:leftBottomPoint];
                    }
                }
            }
        }
    }
    if (shouldShowSeparator) {
        self.separatorLayer.path = separatorPath.CGPath;
        if (_shouldSeparatorDashed) {
            self.separatorLayer.lineDashPhase = 2;
            self.separatorLayer.lineDashPattern = @[@2,@1];
        }
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    NSInteger rowCount = [self rowCount];
    CGFloat totalHeight = rowCount * self.rowHeight + (rowCount - 1) * self.separatorWidth;
    size.height = totalHeight;
    return size;
}

@end
