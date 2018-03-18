//
//  LeeUILabel.m
//  LeeKit
//
//  Created by Lee on 2018/3/9.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "LeeUILabel.h"

@implementation LeeUILabel

-(void)setContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets{
    _contentEdgeInsets = contentEdgeInsets;
    [self setNeedsDisplay];
}
//调用sizetofit会自动调用此方法，该方法不会改变frame
-(CGSize)sizeThatFits:(CGSize)size{
    size = [super sizeThatFits:size];
    size.width += (_contentEdgeInsets.left + _contentEdgeInsets.right);
    size.height += (_contentEdgeInsets.top + _contentEdgeInsets.bottom);
    return size;
}

-(void)drawTextInRect:(CGRect)rect{
    if (_shouldStroke) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetTextDrawingMode(context, kCGTextStroke);
        CGContextSetLineJoin(context, kCGLineJoinRound);
    }
    [super drawTextInRect:CGRectMake(rect.origin.x + _contentEdgeInsets.left, rect.origin.y + _contentEdgeInsets.top, rect.size.width - _contentEdgeInsets.left - _contentEdgeInsets.right, rect.size.height - _contentEdgeInsets.top - _contentEdgeInsets.bottom)];
}

@end
