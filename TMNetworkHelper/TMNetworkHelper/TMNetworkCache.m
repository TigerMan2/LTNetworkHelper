//
//  TMNetworkCache.m
//  TMNetworkHelper
//
//  Created by Apple on 2017/10/10.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "TMNetworkCache.h"

#import "YYCache.h"

@implementation TMNetworkCache

static NSString *const TMNetworkResponseCache = @"TMNetworkResponseCache";
static YYCache *_dataCache;

+ (void)initialize
{
    _dataCache = [YYCache cacheWithName:TMNetworkResponseCache];
}

+ (void)setHttpCache:(id)httpData URL:(NSString *)URL parameters:(NSDictionary *)parameters {
    
    NSString *cacheKey = [self cacheWithUrl:URL parameters:parameters];
    //异步缓存数据，不会阻塞主线程
    [_dataCache setObject:httpData forKey:cacheKey withBlock:nil];
    
}
+ (id) httpCacheWithUrl:(NSString *)url parameters:(NSDictionary *)parameters {
    NSString *cackeKey = [self cacheWithUrl:url parameters:parameters];
    return [_dataCache objectForKey:cackeKey];
}

+ (NSInteger)getAllHttpCacheSzie {
    return [_dataCache.diskCache totalCost];
}

+ (void)removeAllHttpCache {
    [_dataCache.diskCache removeAllObjects];
}

+ (NSString *)cacheWithUrl:(NSString *)url parameters:(NSDictionary *)parameters {
    if (!parameters || parameters.count == 0) {
        return url;
    }
    NSData *stringData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    NSString *paraString = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
    NSString *cacheKey = [NSString stringWithFormat:@"%@%@",url,paraString];
    return [NSString stringWithFormat:@"%ld",cacheKey.hash];
}


@end
