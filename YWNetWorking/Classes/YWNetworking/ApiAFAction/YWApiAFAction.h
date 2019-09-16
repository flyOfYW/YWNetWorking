//
//  YWApiAFAction.h
//  YWNetworkingExamples
//
//  Created by Mr.Yao on 2019/9/10.
//  Copyright © 2019 姚威. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YWServiceProtocol.h"
@class YWURLResponse;

NS_ASSUME_NONNULL_BEGIN

@interface YWApiAFAction : NSObject
/**
 当前对象

 @return 对象
 */
+ (instancetype)sharedInstance;
/**
 请求管理

 @param request NSURLRequest
 @param service service
 @param success success
 @param fail fail
 @return task id
 */
- (NSNumber *)sendRequest:(NSURLRequest *)request
                  service:(id<YWServiceProtocol>)service
                  success:(nullable void (^)(YWURLResponse *response))success
                     fail:(nullable void (^)(YWURLResponse *response))fail;
/// 根据任务id获取相应的任务
/// @param requestId 任务id
- (nullable NSURLSessionDataTask *)getTaskWithRequestId:(NSNumber *)requestId;
/**
 根据任务ids取消任务

 @param requestIdList 任务id集合
 */
- (void)cancelRequestWithRequestIdList:(NSArray *)requestIdList;
/**
 根据任务id取消任务

 @param requestId 任务id
 */
- (void)cancelRequestWithRequestId:(NSNumber *)requestId;
/**
 释放一些对象
 */
- (void)deallocDispatchTable;

@end

NS_ASSUME_NONNULL_END
