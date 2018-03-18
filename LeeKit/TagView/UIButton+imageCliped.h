//
//  UIButton+imageCliped.h
//  LeeKit
//
//  Created by Lee on 2018/2/27.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (imageCliped)

/**
 *    处理图片过大问题，要求button本身的size已经确定有值，否则不处理.
 *  若要设置生成图片的背景颜色，直接设置self.backgroundColor即可
 *
 *    @param image                图片名称或图片对象，也只可以是图片的NSData。
 *    @param state                状态
 *    @param cornerRadius    圆角
 *    @param isEqualScale    是否是等比例压缩
 */
-(void)lee_setImage:(id)image
           forState:(UIControlState)state
       cornerRadius:(CGFloat)cornerRadius
       isEqualScale:(BOOL)isEqualScale;

/**
 *    处理图片过大问题，要求button本身的size已经确定有值，否则不处理
 *  若要设置生成图片的背景颜色，直接设置self.backgroundColor即可*
 *
 *    @param image                图片名称或图片对象，也只可以是图片的NSData。
 *    @param state                状态
 *  @param targetSize   图片最终大小
 *    @param cornerRadius    圆角
 *    @param isEqualScale    是否是等比例压缩
 */
- (void)lee_setImage:(id)image
            forState:(UIControlState)state
              toSize:(CGSize)targetSize
        cornerRadius:(CGFloat)cornerRadius
        isEqualScale:(BOOL)isEqualScale;

#pragma mark - 设置按钮背景图片
/**
 *    处理图片大小与控件大小不一致问题。设置背景图片。要求按钮本身已经有确定的大小。
 *  若要设置生成图片的背景颜色，直接设置self.backgroundColor即可
 *
 *    @param image        图片名称或图片对象，也只可以是图片的NSData。
 *    @param state                状态
 *    @param cornerRadius    圆角大小
 *    @param isEqualScale    是否是等比例压缩
 */
- (void)lee_setBackgroundImage:(id)image
                      forState:(UIControlState)state
                  cornerRadius:(CGFloat)cornerRadius
                  isEqualScale:(BOOL)isEqualScale;

/**
 *    处理图片大小与控件大小不一致问题。设置背景图片。要求按钮本身已经有确定的大小。
 *  若要设置生成图片的背景颜色，直接设置self.backgroundColor即可
 *
 *    @param image        图片名称或图片对象，也只可以是图片的NSData。
 *    @param state                状态
 *  @param targetSize   图片最终大小
 *    @param cornerRadius    圆角大小
 *    @param isEqualScale    是否是等比例压缩
 */
- (void)lee_setBackgroundImage:(id)image
                      forState:(UIControlState)state
                        toSize:(CGSize)targetSize
                  cornerRadius:(CGFloat)cornerRadius
                  isEqualScale:(BOOL)isEqualScale;

@end
