//
//  UIView+corner.h
//  LeeKit
//
//  Created by Lee on 2018/2/26.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^Callback)(UIImage *clipedImage);

@interface UIView (corner)

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
 *  内部默认是会缓存corner所生成的圆角或者添加曲线之类的，如果view需要动态地调整，则
 *  每次复用时，应该设置它为YES,则不会缓存。
 *  默认为NO
 */
@property(nonatomic, assign) BOOL shouldRefreshCache;

#pragma mark - 给任意UIView添加圆角（非图片，性能不如直接使用cornerRadius，但是下面的API支持任意圆角


/**
 给控件本身添加圆角，不是通过图片实现的。要求控件本身的frame是确定的，非自动布局才行

 @param corner 多个圆角可通过UIRectCornerTopLeft | UIRectCornerTopRight这样来使用
 @param cornerRadius 圆角大小
 */
-(void)lee_addCorner:(UIRectCorner)corner cornerRadius:(CGFloat)cornerRadius;


/**
 圆角颜色不应该与背景色相同时，传过来

 @param corner 圆角类型
 @param cornerRadius 大小
 @param backgroundColor 圆角背景色
 */
- (void)lee_addCorner:(UIRectCorner)corner cornerRadius:(CGFloat)cornerRadius backgroundColor:(UIColor *)backgroundColor;

/**
 * corner为UIRectCornerAllCorners，bounds大小已经有才能使用
 *
 * @Example
 * 添加一个圆角：[view1 lee_addCornerRadius:10];
 */
- (void)lee_addCornerRadius:(CGFloat)cornerRadius;

/**
 *  corner为UIRectCornerAllCorners，bounds要外部指定
 *
 *    @param cornerRadius    加钱大小
 *    @param targetSize        指frame.size
 */
- (void)lee_addCornerRadius:(CGFloat)cornerRadius size:(CGSize)targetSize;

/**
 *  给控件本身添加圆角，不是通过图片实现的。
 *
 *    @param corner       添加哪些圆角
 *    @param cornerRadius    圆角大小
 *    @param targetSize        目标大小，即控件的frame.size
 *  @param backgroundColor 控件的背景色与剪裁后的背景色是一样的时候，若需要指定为不一样，传此参数。
 *                         若没有传此参数，默认取最顶层父视图的背景色，若为透明，则取本身背景色，若也为透明，则取白色
 */
- (void)lee_addCorner:(UIRectCorner)corner
         cornerRadius:(CGFloat)cornerRadius
                 size:(CGSize)targetSize
      backgroundColor:(UIColor *)backgroundColor;

#pragma mark - 生成适应大小的图片显示
/**
 *    使用指定的图片来填充，充当UIImageView。
 *  对于自动布局的控件，如果在设置图片时，没有指定大小，就无法得到正确的图片大小。
 *
 *    @param image    图片名称或者图片对象，甚至支持NSData
 *    @param isEqualScale 是否是等比例缩放
 *  @param targetSize 图片大小。如果没有此参数，表示使用控件本身的大小。
 *  @parma callback   只有当图片真正被裁剪成功后，才会回调，返回裁剪后的图片
 *
 *    @return 裁剪前的图片
 */
- (UIImage *)lee_setImage:(id)image size:(CGSize)targetSize isEqualScale:(BOOL)isEqualScale onCliped:(Callback)callback;

/**
 使用指定的图片来填充图片。对于在填充图片之前，肯定有控件大小的，可以直接使用些API。

 @param image 指定的图片
 @param isEqualScale 是否等比缩放
 @param callback 回调
 @return 裁剪的图片
 */
- (UIImage *)lee_setImage:(id)image isEqualScale:(BOOL)isEqualScale onCliped:(Callback)callback;

#pragma mark - 生成圆形图片显示
/**
 *    使用指定的图片来填充，但是生成的是圆形图片，背景颜色为白色。
 *
 *    @param image            图片名称或者图片对象，甚至支持NSData
 *    @param targetSize    生成指定大小的图片
 *    @param isEqualScale    是否等比例缩放图片
 *  @param backgroundColor 默认取最顶层父视图的背景色，若为透明，则取本身背景色，若也为透明，则取白色
 *  @parma callback   只有当图片真正被裁剪成功后，才会回调，返回裁剪后的图片
 *
 *    @return 裁剪前的图片
 */
- (UIImage *)lee_setCircleImage:(id)image
                           size:(CGSize)targetSize
                   isEqualScale:(BOOL)isEqualScale
                 backgrounColor:(UIColor *)backgroundColor
                       onCliped:(Callback)callback;

/// 使用指定的图片来填充，但是生成的是圆形图片，背景颜色为白色。
- (UIImage *)lee_setCircleImage:(id)image
                           size:(CGSize)targetSize
                   isEqualScale:(BOOL)isEqualScale
                       onCliped:(Callback)callback;
/**
 *  使用指定的图片来填充，但是生成的是圆形图片，默认背景颜色为白色。当调用此API时，若控件本身
 *  已经有确定的大小，则可以直接使用此API
 */
- (UIImage *)lee_setCircleImage:(id)image
                   isEqualScale:(BOOL)isEqualScale
                       onCliped:(Callback)callback;

#pragma mark - 生成四个带圆角图片来填充
/**
 *    使用指定图片来填充，生成带四个圆角的图片来填充。生成的图片带有圆角后，为了解决图层混合，需要指定
 *  背景颜色，以便在生成的图片颜色与控件背景颜色一致，可提高性能。
 *
 *    @param image                        图片名称或者图片对象，甚至支持NSData
 *    @param targetSize              生成的图片目标大小
 *    @param cornerRaidus          圆角大小
 *    @param backgroundColor    背景颜色，用于解决图层混合。默认取最顶层父视图的背景色，若为透明，则取本身背景色，若也为透明，则取白色
 *    @param isEqualScale            是否等比例缩放图片
 *  @parma callback   只有当图片真正被裁剪成功后，才会回调，返回裁剪后的图片
 *
 *    @return 裁剪前的图片
 */
- (UIImage *)lee_setImage:(id)image
                     size:(CGSize)targetSize
             cornerRadius:(CGFloat)cornerRaidus
          backgroundColor:(UIColor *)backgroundColor
             isEqualScale:(BOOL)isEqualScale
                 onCliped:(Callback)callback;
/**
 * 生成带四个圆角的图片，默认使用白色背景、isEqualScale=YES
 */
- (UIImage *)lee_setImage:(id)image
                     size:(CGSize)targetSize
             cornerRadius:(CGFloat)cornerRaidus
                 onCliped:(Callback)callback;
/**
 * 生成带四个圆角的图片，默认使用白色背景、isEqualScale=YES。当调用此API时，若控件本身大小是确定的，才能起效！
 */
- (UIImage *)lee_setImage:(id)image
             cornerRadius:(CGFloat)cornerRaidus
                 onCliped:(Callback)callback;
#pragma mark - 生成任意圆角图片来填充
/**
 *    生成任意圆角的图片来填充控件。
 *
 *    @param image                        图片名称或者图片对象，甚至支持NSData
 *    @param targetSize              生成图片大小
 *    @param cornerRaidus          圆角大小
 *    @param rectCorner              指定哪些添加圆角。如果有多个圆角，可以这样UIRectCornerTopRight|UIRectCornerTopLeft
 *    @param backgroundColor    当带有圆角时，背景颜色可用于解决图层混合问题。默认取最顶层父视图的背景色，若为透明，则取本身背景色，若也为透明，则取白色
 *    @param isEqualScale            是否等比例缩放图片
 *  @parma callback   只有当图片真正被裁剪成功后，才会回调，返回裁剪后的图片
 *
 *    @return 裁剪前的图片
 */
- (UIImage *)lee_setImage:(id)image
                     size:(CGSize)targetSize
             cornerRadius:(CGFloat)cornerRaidus
               rectCorner:(UIRectCorner)rectCorner
          backgroundColor:(UIColor *)backgroundColor
             isEqualScale:(BOOL)isEqualScale
                 onCliped:(Callback)callback;
/**
 * 生成任意圆角的图片来填充控件。默认取最顶层父视图的背景色，若为透明，则取本身背景色，若也为透明，则取白色、isEqualScale=YES
 */
- (UIImage *)lee_setImage:(id)image
                     size:(CGSize)targetSize
             cornerRadius:(CGFloat)cornerRaidus
               rectCorner:(UIRectCorner)rectCorner
                 onCliped:(Callback)callback;

/**
 * 生成任意圆角的图片来填充控件。默认取最顶层父视图的背景色，若为透明，则取本身背景色，若也为透明，则取白色。如果控件本身大小确定，
 * 可以直接使用此API来生成与控件大小相同的图片来填充。
 */
- (UIImage *)lee_setImage:(id)image
             cornerRadius:(CGFloat)cornerRaidus
               rectCorner:(UIRectCorner)rectCorner
             isEqualScale:(BOOL)isEqualScale
                 onCliped:(Callback)callback;
/**
 * 生成任意圆角的图片来填充控件。默认取最顶层父视图的背景色，若为透明，则取本身背景色，若也为透明，则取白色、isEqualScale=YES。如果控件本身大小确定，
 * 可以直接使用此API来生成与控件大小相同的图片来填充。
 */
- (UIImage *)lee_setImage:(id)image
             cornerRadius:(CGFloat)cornerRaidus
               rectCorner:(UIRectCorner)rectCorner
                 onCliped:(Callback)callback;

@end
