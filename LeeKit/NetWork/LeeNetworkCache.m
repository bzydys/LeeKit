//
//  LeeNetworkCache.m
//  LeeKit
//
//  Created by Lee on 2017/12/14.
//  Copyright © 2017年 Lee. All rights reserved.
//

#import "LeeNetworkCache.h"
#import "YYCache.h"

static NSString * const kLeeNetworkCache = @"LeeNetworkCache";


@implementation LeeNetworkCache

static YYCache *_dataCache;
+ (void)initialize
{
    if (self == [self class]) {
        _dataCache = [YYCache cacheWithName:kLeeNetworkCache];
    }
}

+ (NSString *)cacheKeyWithURL:(NSString *)url parameters:(NSDictionary *)parameters {
    
    if(!parameters || parameters.count == 0){return url;};
    // 将参数字典转换成字符串
    NSData *stringData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    NSString *paraString = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"%@%@",url,paraString];
}


+(void)setHttpCache:(id)httpData URL:(NSString *)url parameters:(id)parameters{
    NSString *cacheKey = [self cacheKeyWithURL:url parameters:parameters];
    [_dataCache setObject:httpData forKey:cacheKey withBlock:nil];
}

+(id)httpCacheForURL:(NSString *)url parameters:(id)parameters{
    NSString *cacheKey = [self cacheKeyWithURL:url parameters:parameters];
    return [_dataCache objectForKey:cacheKey];
}

+(NSInteger)getAllHttpCacheSize{
    return [_dataCache.diskCache totalCost];
}

+(void)removeAllHttpCache{
    [_dataCache.diskCache removeAllObjects];
}

@end
