//
//  LeeNetworkHelper.h
//  LeeKit
//
//  Created by Lee on 2017/12/14.
//  Copyright © 2017年 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeeNetworkCache.h"

#ifdef DEBUG
#define Log(...) printf("[%s] %s [第%d行]: %s\n", __TIME__ ,__PRETTY_FUNCTION__ ,__LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String])
#else
#define Log(...)
#endif

#ifndef kIsNetwork
#define kIsNetwork     [LeeNetworkHelper isNetwork]  // 一次性判断是否有网的宏
#endif

#ifndef kIsWWANNetwork
#define kIsWWANNetwork [LeeNetworkHelper isWWANNetwork]  // 一次性判断是否为手机网络的宏
#endif

#ifndef kIsWiFiNetwork
#define kIsWiFiNetwork [LeeNetworkHelper isWiFiNetwork]  // 一次性判断是否为WiFi网络的宏
#endif

typedef NS_ENUM(NSInteger, LeeNetworkStatusType){
    ///未知网络
    LeeNetworkStatusUnknow,
    ///无网
    LeeNetworkStatusNotReachable,
    ///手机网络
    LeeNetworkStatusViaWWAN,
    ///wifi
    LeeNetworkStatusViaWiFi
};

typedef NS_ENUM(NSUInteger, LeeRequestSerializerType) {
    /// 设置请求数据为JSON格式
    LeeRequestSerializerJSON,
    /// 设置请求数据为二进制格式
    LeeRequestSerializerHTTP,
};

typedef NS_ENUM(NSUInteger, LeeResponseSerializerType) {
    /// 设置响应数据为JSON格式
    LeeResponseSerializerJSON,
    /// 设置响应数据为二进制格式
    LeeResponseSerializerHTTP,
};

/**
 <#Description#>

 @param status <#status description#>
 */
typedef void(^LeeNetworkStatus)(LeeNetworkStatusType status);

/**
 请求成功的block

 @param responseObject 请求成功的block
 */
typedef void(^LeeHttpRequestSuccess)(id responseObject);


/**
 请求失败的block

 @param error 请求失败的block
 */
typedef void(^LeeHttpRequestFailed)(NSError *error);


/**
 请求缓存的block

 @param responseCache 请求缓存的block
 */
typedef void(^LeeHttpRequestCache)(id responseCache);


/**
 下载或者上传进度

 @param progress 下载或者上传进度的回调
 */
typedef void(^LeeHttpProgress)(NSProgress *progress);

@class AFHTTPSessionManager;

@interface LeeNetworkHelper : NSObject


/**
 判断网络状态

 @return 网络是否可链接
 */
+(BOOL)isCanEnterNetwork;

/**
 判断网络状态

 @return 是否为手机网络
 */
+(BOOL)isWWANNetwork;

/**
 判断网络状态

 @return 是否为wifi
 */
+(BOOL)isWiFiNetwork;

/**
 取消所有网络请求
 */
+(void)cancelAllRequest;

/**
 实时获取网络状态,通过Block回调实时获取(此方法可多次调用)

 @param networkStatus 网络状态的回调
 */
+(void)networkStatusWithBlock:(LeeNetworkStatus)networkStatus;

/**
 取消指定URL的HTTP请求

 @param url 请求路径
 */
+(void)cancelRequestWithURL:(NSString *)url;

/**
 开启日志打印
 */
+(void)openLog;

/**
 关闭日志打印，默认关闭
 */
+(void)closeLog;

/**
 无缓存的get请求

 @param url 请求地址
 @param parameters 请求参数
 @param success 成功回调
 @param failure 失败回调
 @return 返回的对象可取消请求,调用cancel方法
 */
+(__kindof NSURLSessionTask *)GET:(NSString *)url
                       parameters:(id)parameters
                          success:(LeeHttpRequestSuccess)success
                          failure:(LeeHttpRequestFailed)failure;

/**
 GET请求,自动缓存

 @param url 请求地址
 @param parameters 请求参数
 @param responseCache 缓存数据的回调
 @param success 成功回调
 @param failure 失败回调
 @return 返回的对象可取消请求,调用cancel方法
 */
+(__kindof NSURLSessionTask *)GET:(NSString *)url
                       parameters:(id)parameters
                    responseCache:(LeeHttpRequestCache)responseCache
                          success:(LeeHttpRequestSuccess)success
                          failure:(LeeHttpRequestFailed)failure;

/**
 POST请求,无缓存

 @param url 请求地址
 @param parameters 请求参数
 @param success 请求成功的回调
 @param failure 请求失败的回调
 @return 返回的对象可取消请求,调用cancel方法
 */
+(__kindof NSURLSessionTask *)POST:(NSString *)url
                        parameters:(id)parameters
                           success:(LeeHttpRequestSuccess)success
                           failure:(LeeHttpRequestFailed)failure;

/**
 POST请求,自动缓存

 @param url 请求地址
 @param parameters 请求参数
 @param responseCache 缓存数据的回调
 @param success 请求成功的回调
 @param failure 请求失败的回调
 @return 返回的对象可取消请求,调用cancel方法
 */
+(__kindof NSURLSessionTask *)POST:(NSString *)url
                        parameters:(id)parameters
                     responseCache:(LeeHttpRequestCache)responseCache
                           success:(LeeHttpRequestSuccess)success
                           failure:(LeeHttpRequestFailed)failure;


/**---------------------------------上传下载--------------------------------------------**/

/**
 上传文件

 @param url 请求地址
 @param parameters 请求参数
 @param name 文件对应服务器上的字段
 @param filePath 文件本地的沙盒路径
 @param progress 上传进度信息
 @param success 请求成功的回调
 @param failure 请求失败的回调
 @return 返回的对象可取消请求,调用cancel方法
 */
+(__kindof NSURLSessionTask *)uploadFileWithURL:(NSString *)url
                                     parameters:(id)parameters
                                           name:(NSString *)name
                                       filePath:(NSString *)filePath
                                       progress:(LeeHttpProgress)progress
                                        success:(LeeHttpRequestSuccess)success
                                        failure:(LeeHttpRequestFailed)failure;

/**
 上传单/多张图片

 @param url 请求地址
 @param parameters 请求参数
 @param name 图片对应服务器上的字段
 @param images 图片数组
 @param fileNames 图片文件名数组, 可以为nil, 数组内的文件名默认为当前日期时间"yyyyMMddHHmmss"
 @param scale 图片文件压缩比 范围 (0.f ~ 1.f)
 @param imageType 图片文件的类型,例:png、jpg(默认类型)....
 @param progress 上传进度信息
 @param success 请求成功的回调
 @param failure 请求失败的回调
 @return 返回的对象可取消请求,调用cancel方法
 */
+(__kindof NSURLSessionTask *)uploadFileWithURL:(NSString *)url
                                     parameters:(id)parameters name:(NSString *)name
                                         images:(NSArray<UIImage *> *)images
                                      fileNames:(NSArray<NSString *> *)fileNames
                                  compressScale:(CGFloat)scale
                                      imageType:(NSString *)imageType
                                       progress:(LeeHttpProgress)progress
                                        success:(LeeHttpRequestSuccess)success
                                        failure:(LeeHttpRequestFailed)failure;

/**
 下载文件

 @param url 请求地址
 @param fileDir 文件存储目录(默认存储目录为Download)
 @param progress 文件下载的进度信息
 @param success 下载成功的回调(回调参数filePath:文件的路径)
 @param failure 下载失败的回调
 @return 返回NSURLSessionDownloadTask实例，可用于暂停继续，暂停调用suspend方法，开始下载调用resume方法
 */
+(__kindof NSURLSessionTask *)downloadWithURL:(NSString *)url
                                      fileDir:(NSString *)fileDir
                                     progress:(LeeHttpProgress)progress
                                      success:(void(^)(NSString *filePath))success
                                      failure:(LeeHttpRequestFailed)failure;

/**
 拿到manager对request和response设置

 @param sessionManager 设置的代码块
 */
+ (void)setAFHTTPSessionManagerProperty:(void(^)(AFHTTPSessionManager *sessionManager))sessionManager;

/**
 设置请求参数的格式化方式

 @param requestSerializer 格式化方式
 */
+ (void)setRequestSerializer:(LeeRequestSerializerType)requestSerializer;

/**
 设置服务器响应数据格式:默认为JSON格式

 @param responseSerializer 格式化方式
 */
+ (void)setResponseSerializer:(LeeResponseSerializerType)responseSerializer;

/**
 设置请求超时时间:默认为30S

 @param time 超时时间
 */
+ (void)setRequestTimeoutInterval:(NSTimeInterval)time;

/**
 设置请求头

 @param value 头部的值
 @param field 头部的属性
 */
+ (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;

/**
 是否打开网络状态转圈菊花:默认打开

 @param open 是否打开
 */
+ (void)openNetworkActivityIndicator:(BOOL)open;

/**
 配置自建证书的Https请求

 @param cerPath 自建Https证书的路径
 @param validatesDomainName 是否需要验证域名，默认为YES
 */
+ (void)setSecurityPolicyWithCerPath:(NSString *)cerPath validatesDomainName:(BOOL)validatesDomainName;
@end
