//
//  LeeNetworkCache.h
//  LeeKit
//
//  Created by Lee on 2017/12/14.
//  Copyright © 2017年 Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LeeNetworkCache : NSObject


/**
 根据url和参数实现缓存的存储，可分页存储
 
 @param httpData 请求返回的数据
 @param url 请求的路径
 @param parameters 请求的参数
 */
+ (void)setHttpCache:(id)httpData URL:(NSString *)url parameters:(id)parameters;


/**
 通过请求路径返回缓存数据
 
 @param url 请求的路径
 @param parameters 请求的参数
 @return 缓存数据
 */
+ (id)httpCacheForURL:(NSString *)url parameters:(id)parameters;

/**
 获取缓存的大小，byte
 
 @return 缓存的大小
 */
+ (NSInteger)getAllHttpCacheSize;

/**
 删除所有的缓存
 */
+ (void)removeAllHttpCache;

@end
