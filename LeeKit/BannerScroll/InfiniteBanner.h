//
//  InfiniteBanner.h
//  LeeKit
//
//  Created by Lee on 2018/1/22.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^loadMethod)(NSURL *url, UIImageView *imgView);

@class InfiniteConfiguration;

@interface InfiniteBanner : UIView

@property(nonatomic, strong) InfiniteConfiguration *config;


/**
 显示图片

 @param imgs 传入的图片数组
 */
-(void)showImages:(NSArray<UIImage *> *)imgs;

/**
 加载图片

 @param urls 传入的图片地址
 */
-(void)showImagesWithUrls:(NSArray<NSURL *> *)urls loadMethod:(loadMethod)loadFunc;

@end
