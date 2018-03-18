//
//  NSAttributedString+Lee.m
//  LeeKit
//
//  Created by Lee on 2018/3/6.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "NSAttributedString+Lee.h"

@implementation NSAttributedString (Lee)

+(instancetype)lee_attributedStringWithImage:(UIImage *)image{
    return [self lee_attributedStringWithImage:image baselineOffset:0 leftMargin:0 rightMargin:0];
}

+(instancetype)lee_attributedStringWithImage:(UIImage *)image baselineOffset:(CGFloat)offset leftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin{
    if (!image) {
        return nil;
    }
    NSTextAttachment *attachment = [NSTextAttachment new];
    attachment.image = image;
    attachment.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    NSMutableAttributedString *string = [[NSMutableAttributedString attributedStringWithAttachment:attachment] mutableCopy];
    [string addAttribute:NSBaselineOffsetAttributeName value:@(offset) range:NSMakeRange(0, string.length)];
    if (leftMargin > 0) {
        [string insertAttributedString:[self lee_attributedStringWithFixedSpace:leftMargin] atIndex:0];
    }
    if (rightMargin > 0) {
        [string appendAttributedString:[self lee_attributedStringWithFixedSpace:rightMargin]];
    }
    return string;
    
}

+ (instancetype)lee_attributedStringWithFixedSpace:(CGFloat)width {
    UIGraphicsBeginImageContext(CGSizeMake(width, 1));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [self lee_attributedStringWithImage:image];
}


@end
