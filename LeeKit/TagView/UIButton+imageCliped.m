//
//  UIButton+imageCliped.m
//  LeeKit
//
//  Created by Lee on 2018/2/27.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "UIButton+imageCliped.h"
#import "UIImage+corner.h"
#import "UIView+corner.h"

@implementation UIButton (imageCliped)

- (void)lee_setImage:(id)image
            forState:(UIControlState)state
        cornerRadius:(CGFloat)cornerRadius
        isEqualScale:(BOOL)isEqualScale {
    [self lee_setImage:image
              forState:state
                toSize:self.frame.size
          cornerRadius:cornerRadius
          isEqualScale:isEqualScale];
}

- (void)lee_setImage:(id)image
            forState:(UIControlState)state
              toSize:(CGSize)targetSize
        cornerRadius:(CGFloat)cornerRadius
        isEqualScale:(BOOL)isEqualScale {
    [self _private_lee_setImage:image
                       forState:state
              isBackgroundImage:NO
                         toSize:targetSize
                   cornerRadius:cornerRadius
                   isEqualScale:isEqualScale];
}

- (void)lee_setBackgroundImage:(id)image
                      forState:(UIControlState)state
                  cornerRadius:(CGFloat)cornerRadius
                  isEqualScale:(BOOL)isEqualScale {
    [self lee_setBackgroundImage:image
                        forState:state
                          toSize:self.frame.size
                    cornerRadius:cornerRadius
                    isEqualScale:isEqualScale];
}

- (void)lee_setBackgroundImage:(id)image
                      forState:(UIControlState)state
                        toSize:(CGSize)targetSize
                  cornerRadius:(CGFloat)cornerRadius
                  isEqualScale:(BOOL)isEqualScale {
    [self _private_lee_setImage:image
                       forState:state
              isBackgroundImage:YES
                         toSize:targetSize
                   cornerRadius:cornerRadius
                   isEqualScale:isEqualScale];
}

#pragma mark - Private
- (void)_private_lee_setImage:(id)image
                     forState:(UIControlState)state
            isBackgroundImage:(BOOL)isBackImage
                       toSize:(CGSize)targetSize
                 cornerRadius:(CGFloat)cornerRadius
                 isEqualScale:(BOOL)isEqualScale {
    if (image == nil || targetSize.width == 0 || targetSize.height == 0) {
        return;
    }
    
    UIImage *willBeClipedImage = image;
    if ([image isKindOfClass:[NSString class]]) {
        willBeClipedImage = [UIImage imageNamed:image];
    } else if ([image isKindOfClass:[UIImage class]]) {
        willBeClipedImage = image;
    } else if ([image isKindOfClass:[NSData class]]) {
        willBeClipedImage = [UIImage imageWithData:image];
    }
    
    if (willBeClipedImage == nil) {
        return;
    }
    
    __block UIImage *clipedImage = nil;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @autoreleasepool {
            willBeClipedImage.lee_pathColor = self.lee_pathColor;
            willBeClipedImage.lee_pathWidth = self.lee_pathWidth;
            willBeClipedImage.lee_borderColor = self.lee_borderColor;
            willBeClipedImage.lee_borderWidth = self.lee_borderWidth;
            
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                clipedImage = [willBeClipedImage lee_clipToSize:targetSize
                                                   cornerRadius:cornerRadius
                                                     cornerType:UIRectCornerAllCorners
                                                backgroundColor:self.backgroundColor
                                                    shouldScale:isEqualScale
                                                       isCircle:NO];
                if (clipedImage) {
                    if (isBackImage) {
                        [self setBackgroundImage:clipedImage forState:state];
                    } else {
                        [self setImage:clipedImage forState:state];
                    }
                }
            });
        }
    });
}

@end
