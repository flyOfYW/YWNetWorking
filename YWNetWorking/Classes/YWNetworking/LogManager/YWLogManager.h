//
//  YWLogManager.h
//  YWNetworkingExamples
//
//  Created by Mr.Yao on 2019/9/11.
//  Copyright © 2019 姚威. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YWServiceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface YWLogManager : NSObject
/**
 对将要法请求的时候，日志处理

 @param request 当前的request
 @param apiName 端口地址
 @param service 服务管理对象
 @return 日志
 */
+ (NSString *)logDebugInfoWithRequest:(NSURLRequest *)request
                              apiName:(NSString *)apiName
                              service:(id<YWServiceProtocol>)service;
/**
 对将要回调给业务层的时候，日志管理

 @param response 请求的响应类
 @param responseObject 响应数据
 @param request 当前的request
 @param error 错误
 @return 日志
 */
+ (NSString *)logDebugInfoWithResponse:(NSHTTPURLResponse *)response
                        responseObject:(id)responseObject
                               request:(NSURLRequest *)request
                                 error:(NSError *)error;
/**
 重连日志

 @param apiName 端口名
 @param retryCount 次数
 @return 日志
 */
+ (NSString *)logDebugInfoWithRetryApiName:(NSString *)apiName retryCount:(NSInteger)retryCount;

@end

NS_ASSUME_NONNULL_END
