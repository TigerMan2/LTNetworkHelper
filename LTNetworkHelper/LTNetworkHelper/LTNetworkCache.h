//
//  LTNetworkCache.h
//  LTNetworkHelper
//
//  Created by Apple on 2017/10/10.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LTNetworkCache : NSObject

/**
 * 异步缓存网络数据 根据url和parameter 做key存储数据
 *
 * @param httpData      获取的网络数据
 * @param URL           请求的URL地址
 * @param parameters    请求的参数
 */
+ (void)setHttpCache:(id)httpData URL:(NSString *)URL parameters:(NSDictionary *)parameters;

/**
 * 根据key获取缓存的数据
 *
 * @param url           请求的URL地址
 * @param parameters    请求的参数
 * @return              本地缓存的数据
 */
+ (id) httpCacheWithUrl:(NSString *)url parameters:(NSDictionary *)parameters;

/**
 * 获取缓存数据的大小 bytes(字节)
 *
 * @return              返回本地缓存数据的大小
 */
+ (NSInteger)getAllHttpCacheSzie;

/**
 * 删除所有网络缓存
 */
+ (void)removeAllHttpCache;

@end
