//
//  WYNetworkHelper.h
//  WYNetworkHelper
//
//  Created by Apple on 2017/10/10.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WYNetworkCache.h"

typedef NS_ENUM(NSInteger , WYNetworkStatusType){
    //未知网络
    WYNetworkStatusUnknow,
    //无网络
    WYNetworkStatusNotReachable,
    //手机网络
    WYNetworkStatusReachableViaWWAN,
    //WIFI
    WYNetworkStatusReachableViaWiFi
    
};


//请求成功的block
typedef void(^WYNetRequestSuccess)(id responseObject);

//请求失败的block
typedef void(^WYNetRequestFailure)(NSError *error);

//缓存的block
typedef void(^WYNetRequestCache)(id responseCache);

//上传或下载进度, progress.completedUnitCount:当前大小  -   progress.totalUnitCount:总大小
typedef void(^WYNetProgress)(NSProgress *progress);

//网络状态block
typedef void(^WYNetworkStatus)(WYNetworkStatusType status);

@interface WYNetworkHelper : NSObject

/**
 * 开始监听网络状态
 *
 * @param networkStatus 返回网络状态
 */
+ (void)networkStatusWithBlock:(WYNetworkStatus)networkStatus;

/**
 * GET (无缓存)
 *
 * @param url 服务器地址
 * @param parameters 请求参数
 * @param success 成功block
 * @param failure 失败block
 * @return 返回请求task
 */
+ (NSURLSessionTask *)GET:(NSString *)url
               parameters:(id)parameters
                  success:(WYNetRequestSuccess)success
                  failure:(WYNetRequestFailure)failure;

/**
 * GET (有缓存)
 *
 * @param url 服务器地址
 * @param parameters 请求参数
 * @param responseCache 缓存block
 * @param success 成功block
 * @param failure 失败block
 * @return 返回请求task
 */
+ (NSURLSessionTask *)GET:(NSString *)url
               parameters:(id)parameters
            responseCache:(WYNetRequestCache)responseCache
                  success:(WYNetRequestSuccess)success
                  failure:(WYNetRequestFailure)failure;

/**
 * POST (无缓存)
 *
 * @param url 服务器地址
 * @param parameters 请求参数
 * @param success 成功block
 * @param failure 失败block
 * @return 返回请求task
 */
+ (NSURLSessionTask *)POST:(NSString *)url
                parameters:(id)parameters
                   success:(WYNetRequestSuccess)success
                   failure:(WYNetRequestFailure)failure;
/**
 * POST (有缓存)
 *
 * @param url 服务器地址
 * @param parameters 请求参数
 * @param responseCache 缓存block
 * @param success 成功block
 * @param failure 失败block
 * @return 返回请求task
 */
+ (NSURLSessionTask *)POST:(NSString *)url
                parameters:(id)parameters
             responseCache:(WYNetRequestCache)responseCache
                   success:(WYNetRequestSuccess)success
                   failure:(WYNetRequestFailure)failure;

/**
 * 上传文件
 *
 * @param url 服务器地址
 * @param parameters 上传参数
 * @param name 文件名
 * @param filePath 文件地址
 * @param progress 进度block
 * @param success 成功block
 * @param failure 失败block
 * @return 返回上传task
 */
+ (NSURLSessionTask *)uploadFileWithUrl:(NSString *)url
                             parameters:(id)parameters
                                   name:(NSString *)name
                               filePath:(NSString *)filePath
                               progress:(WYNetProgress)progress
                                success:(WYNetRequestSuccess)success
                                failure:(WYNetRequestFailure)failure;

/**
 * 上传多张图片
 *
 * @param url 服务器地址
 * @param parameters 上传参数
 * @param name 名称
 * @param images 上传图片数组
 * @param fileNames 图片名称数组
 * @param imageScale 图片缩放比例
 * @param imageType 图片类型
 * @param progress 上传进度block
 * @param success 成功block
 * @param failure 失败block
 * @return 返回上传图片task
 */
+ (NSURLSessionTask *)uploadImageWithUrl:(NSString *)url
                              parameters:(id)parameters
                                    name:(NSString *)name
                                  images:(NSArray<UIImage *> *)images
                               fileNames:(NSArray<NSString *> *)fileNames
                              imageScale:(CGFloat)imageScale
                               imageType:(NSString *)imageType
                                progress:(WYNetProgress)progress
                                 success:(WYNetRequestSuccess)success
                                 failure:(WYNetRequestFailure)failure;

/**
 * 下载文件
 *
 * @param url 服务器地址
 * @param fileDir 图片保存的地址
 * @param progress 下载进度block
 * @param success 成功block
 * @param failure 失败block
 * @return 返回下载task
 */
+ (NSURLSessionTask *)downloadFileWithUrl:(NSString *)url
                                  fileDir:(NSString *)fileDir
                                 progress:(WYNetProgress)progress
                                  success:(WYNetRequestSuccess)success
                                  failure:(WYNetRequestFailure)failure;

/**
 * 关闭所有请求task
 */
+ (void)cancelAllRequest;

/**
 * 关闭指定url的task
 *
 * @param url 要关闭的task的url
 */
+ (void)cancelRequestWithUrl:(NSString *)url;
@end
