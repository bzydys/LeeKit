//
//  UIImage+corner.h
//  LeeKit
//
//  Created by Lee on 2018/2/20.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (corner)

/**
 边框宽度
 */
@property(nonatomic, assign) CGFloat lee_borderWidth;

/**
 画笔宽度
 */
@property(nonatomic, assign) CGFloat lee_pathWidth;

/**
 边框颜色
 */
@property(nonatomic, strong) UIColor *lee_borderColor;

/**
 画笔颜色
 */
@property(nonatomic, strong) UIColor *lee_pathColor;

/**
 根据颜色生成矩形图片

 @param color 待生成图片的颜色
 @param size 生成图片的大小
 @return 生成的图片
 */
+(UIImage *)lee_imageWithColor:(UIColor *)color size:(CGSize)size;

/**
 根据颜色生成带圆角的图片

 @param color 待生成图片的颜色
 @param size 生成图片的大小
 @param cornerRadius 圆角大小
 @return 生成的图片
 */
+(UIImage *)lee_imageWithColor:(UIColor *)color size:(CGSize)size cornerRadius:(CGFloat)cornerRadius;

/**
 根据颜色生成带圆角的图片

 @param color 待生成图片的颜色
 @param size 生成图片的大小
 @param cornerRadius 圆角大小
 @param backgroundColor 圆角部分颜色
 @return 生成的图片
 */
+(UIImage *)lee_imageWithColor:(UIColor *)color size:(CGSize)size cornerRadius:(CGFloat)cornerRadius backgroundColor:(UIColor *)backgroundColor;

/**
 根据颜色生成带圆角的图片

 @param color 待生成图片的颜色
 @param size 生成图片的大小
 @param cornerRadius 圆角大小
 @param backgroundColor 圆角部分颜色
 @param borderColor 边框颜色
 @param borderWidth 边框宽度
 @return 生成的图片
 */
+(UIImage *)lee_imageWithColor:(UIColor *)color size:(CGSize)size cornerRadius:(CGFloat)cornerRadius backgroundColor:(UIColor *)backgroundColor borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth;

/**
 裁剪图片到指定大小

 @param size 指定大小
 @param scale 是否需要缩放
 @return 生成的图片
 */
-(UIImage *)lee_clipToSize:(CGSize)size shouldScale:(BOOL)scale;

/**
 裁剪图片到指定大小

 @param size 指定大小
 @param radius 圆角大小
 @param backgroundColor 背景颜色
 @param scale 是否需要缩放
 @return 生成的图片
 */
-(UIImage *)lee_clipToSize:(CGSize)size
              cornerRadius:(CGFloat)radius
           backgroundColor:(UIColor *)backgroundColor shouldScale:(BOOL)scale;

/**
 裁剪图片到指定大小

 @param size 指定大小
 @param radius 圆角大小
 @return 生成的图片
 */
-(UIImage *)lee_clipToSize:(CGSize)size cornerRadius:(CGFloat)radius;

/**
 裁剪图片到指定大小

 @param size 指定大小
 @param radius 圆角大小
 @param type 圆角类型
 @param backgroundColor 圆角背景色
 @param scale 是否缩放
 @return 生成的图片
 */
-(UIImage *)lee_clipToSize:(CGSize)size cornerRadius:(CGFloat)radius
                cornerType:(UIRectCorner)type
           backgroundColor:(UIColor *)backgroundColor shouldScale:(BOOL)scale;

/**
 裁剪图片到指定大小

 @param size 指定大小
 @param radius 圆角大小
 @param type 圆角类型
 @return 生成的图片
 */
-(UIImage *)lee_clipToSize:(CGSize)size
              cornerRadius:(CGFloat)radius
                cornerType:(UIRectCorner)type;

/**
 裁剪圆形图片到指定大小

 @param size 指定大小
 @param backgroundColor 圆角图片背景色
 @param scale 是否缩放
 @return 生成的图片
 */
-(UIImage *)lee_clipCircleToSize:(CGSize)size backgroundColor:(UIColor *)backgroundColor shouldScale:(BOOL)scale;

/**
 裁剪圆形图片到指定大小

 @param size 指定大小
 @return 生成的图片
 */
-(UIImage *)lee_clipCircleToSize:(CGSize)size;

/**
 裁剪图片到指定大小

 @param size 指定大小
 @param radius 圆角大小
 @param type 圆角类型
 @param backgroundColor 背景色
 @param scale 是否缩放
 @param isCircle 是否是圆形
 @return 生成的图片
 */
-(UIImage *)lee_clipToSize:(CGSize)size
              cornerRadius:(CGFloat)radius
                   cornerType:(UIRectCorner)type
           backgroundColor:(UIColor *)backgroundColor
              shouldScale:(BOOL)scale
                  isCircle:(BOOL)isCircle;


@end
