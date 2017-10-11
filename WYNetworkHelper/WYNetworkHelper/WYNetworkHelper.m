//
//  WYNetworkHelper.m
//  WYNetworkHelper
//
//  Created by Apple on 2017/10/10.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "WYNetworkHelper.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"

#ifdef DEBUG
#define WYLog(...) printf("[%s] %s [第%d行]: %s\n", __TIME__ ,__PRETTY_FUNCTION__ ,__LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String])
#else
#define WYLog(...)
#endif

@implementation WYNetworkHelper

static NSMutableArray *_allSessionTasks;
static AFHTTPSessionManager *_sessionManager;

#pragma mark - 初始化AFHTTPSessionManager相关属性
+ (void)initialize{
    _sessionManager = [AFHTTPSessionManager manager];
    _sessionManager.requestSerializer.timeoutInterval = 30.0f;
    _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript", @"text/xml", @"image/*", nil];
    //打开状态栏的菊花
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
}

+ (void)cancelAllRequest {
    //加锁
    @synchronized (self) {
        [[self allSessionTasks] enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            [task cancel];
        }];
        [[self allSessionTasks] removeAllObjects];
    }
}
+ (void)cancelRequestWithUrl:(NSString *)url {
    
    if (!url) {
        return;
    }
    @synchronized (self) {
        [[self allSessionTasks] enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task.currentRequest.URL.absoluteString hasPrefix:url]) {
                [task cancel];
                [[self allSessionTasks] removeObject:task];
                *stop = YES;
            }
        }];
    }
}

#pragma mark - 开始网络监听
+ (void)networkStatusWithBlock:(WYNetworkStatus)networkStatus{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                networkStatus ? networkStatus(WYNetworkStatusUnknow) : nil;
                break;
            case AFNetworkReachabilityStatusNotReachable:
                networkStatus ? networkStatus(WYNetworkStatusNotReachable) : nil;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                networkStatus ? networkStatus(WYNetworkStatusReachableViaWWAN) : nil;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                networkStatus ? networkStatus(WYNetworkStatusReachableViaWiFi) : nil;
                break;
                
            default:
                break;
        }
    }];
}

#pragma mark - GET请求无缓存
+ (NSURLSessionTask *)GET:(NSString *)url
 parameters:(id)parameters
    success:(WYNetRequestSuccess)success
    failure:(WYNetRequestFailure)failure
{
    return [self GET:url parameters:parameters responseCache:nil success:success failure:failure];
}

#pragma mark - POST请求无缓存
+ (NSURLSessionTask *)POST:(NSString *)url
  parameters:(id)parameters
     success:(WYNetRequestSuccess)success
     failure:(WYNetRequestFailure)failure
{
    return [self POST:url parameters:parameters responseCache:nil success:success failure:failure];
}

#pragma mark - GET请求自动缓存
+ (NSURLSessionTask *)GET:(NSString *)url
               parameters:(id)parameters
            responseCache:(WYNetRequestCache)responseCache
                  success:(WYNetRequestSuccess)success
                  failure:(WYNetRequestFailure)failure{
    
    responseCache != nil ? responseCache([WYNetworkCache httpCacheWithUrl:url parameters:parameters]) : nil;
    
    NSURLSessionTask *sessionTask = [_sessionManager GET:url parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        //移除task
        [[self allSessionTasks] removeObject:task];
        //传值出去
        success ? success(responseObject) : nil;
        //对数据异步缓存
        responseCache !=nil ? [WYNetworkCache setHttpCache:responseObject URL:url parameters:parameters] : nil;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [[self allSessionTasks] removeObject:task];
        failure ? failure(error) : nil;
        
    }];
    
    //添加最新sessionTask到数组中
    sessionTask ? [[self allSessionTasks] addObject:sessionTask] : nil;
    
    return sessionTask;
    
}

#pragma mark - POST请求自动缓存
+ (NSURLSessionTask *)POST:(NSString *)url
                parameters:(id)parameters
             responseCache:(WYNetRequestCache)responseCache
                   success:(WYNetRequestSuccess)success
                   failure:(WYNetRequestFailure)failure {
    
    //获取本地缓存
    responseCache != nil ? responseCache([WYNetworkCache httpCacheWithUrl:url parameters:parameters]) : nil;
    
    NSURLSessionTask *sessionTask = [_sessionManager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        //移除task
        [[self allSessionTasks] removeObject:task];
        success ? success(responseObject) : nil;
        
        responseCache != nil ? [WYNetworkCache setHttpCache:responseObject URL:url parameters:parameters] : nil;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        //移除
        [[self allSessionTasks] removeObject:task];
        
        failure ? failure(error) : nil;
        
    }];
    
    //添加sessionTask到数组中
    [[self allSessionTasks] addObject:sessionTask];
    
    return sessionTask;
    
}

#pragma mark - 上传文件
+ (NSURLSessionTask *)uploadFileWithUrl:(NSString *)url
                             parameters:(id)parameters
                                   name:(NSString *)name
                               filePath:(NSString *)filePath
                               progress:(WYNetProgress)progress
                                success:(WYNetRequestSuccess)success
                                failure:(WYNetRequestFailure)failure {
    
    NSURLSessionTask *sessionTask = [_sessionManager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSError *error = nil;
        [formData appendPartWithFileURL:[NSURL URLWithString:filePath] name:name error:&error];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        //上传进度
        dispatch_sync(dispatch_get_main_queue(), ^{
           progress ? progress(uploadProgress) : nil;
        });
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        //移除
        [[self allSessionTasks] removeObject:task];
        success ? success(responseObject) : nil;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        //移除
        [[self allSessionTasks] removeObject:task];
        failure ? failure(error) : nil;
        
    }];
    //添加sessionTask到数组
    sessionTask ? [[self allSessionTasks] addObject:sessionTask] : nil;
    
    return sessionTask;
}

#pragma mark - 上传多张图片
+ (NSURLSessionTask *)uploadImageWithUrl:(NSString *)url
                              parameters:(id)parameters
                                    name:(NSString *)name
                                  images:(NSArray<UIImage *> *)images
                               fileNames:(NSArray<NSString *> *)fileNames
                              imageScale:(CGFloat)imageScale
                               imageType:(NSString *)imageType
                                progress:(WYNetProgress)progress
                                 success:(WYNetRequestSuccess)success
                                 failure:(WYNetRequestFailure)failure {
    
    NSURLSessionTask *sessionTask = [_sessionManager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            //图片等比压缩后得到的二进制文件
            NSData *imageData = UIImageJPEGRepresentation(images[idx], imageScale ?:1.f);
            //默认图片的文件名，若fileName为nil，则为下面的格式
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            NSString *imageFileName = [NSString stringWithFormat:@"%@%ld%@",str,idx,imageType?:@".jpg"];
            
            [formData appendPartWithFileData:imageData name:name fileName:fileNames ? [NSString stringWithFormat:@"%@.%@",fileNames[idx],imageType?:@".jpg"] : imageFileName mimeType:[NSString stringWithFormat:@"image/%@",imageType ?: @"jpg"]];
            
        }];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(uploadProgress) : nil;
        });
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [[self allSessionTasks] removeObject:task];
        success ? success(responseObject) : nil;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [[self allSessionTasks] removeObject:task];
        failure ? failure(error) : nil;
        
    }];
    
    //添加
    sessionTask ? [[self allSessionTasks] addObject:sessionTask] : nil;
    return sessionTask;
}

#pragma mark - 下载文件
+ (NSURLSessionTask *)downloadFileWithUrl:(NSString *)url
                                  fileDir:(NSString *)fileDir
                                 progress:(WYNetProgress)progress
                                  success:(WYNetRequestSuccess)success
                                  failure:(WYNetRequestFailure)failure {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    __block NSURLSessionDownloadTask *downloadTask = [_sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //下载进度
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(downloadProgress) : nil;
        });
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //拼接缓存目录
        NSString *downloadDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileDir ? fileDir : @"Download"];
        //打开文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //创建Download目录
        [fileManager createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:nil];
        //拼接文件路径
        NSString *filePath = [downloadDir stringByAppendingPathComponent:response.suggestedFilename];
        //返回文件位置的URL路径
        return [NSURL URLWithString:filePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        [[self allSessionTasks] removeObject:downloadTask];
        
        if (failure && error) {
            failure(error);
            return ;
        }
        
        //NSURL转换为NSString
        success ? success(filePath.absoluteString) : nil;
        
    }];
    //开始下载
    [downloadTask resume];
    //添加到数组
    downloadTask ? [[self allSessionTasks] addObject:downloadTask] : nil;
    return downloadTask;
}

/**
 * 所有请求任务task的数组
 *
 */
+ (NSMutableArray *)allSessionTasks {
    if (_allSessionTasks == nil){
        _allSessionTasks = [[NSMutableArray alloc] init];
    }
    return _allSessionTasks;
}

@end
