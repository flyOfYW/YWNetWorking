//
//  YWBaseApiManager.h
//  YWNetworkingExamples
//
//  Created by Mr.Yao on 2019/9/9.
//  Copyright © 2019 姚威. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YWNetworkingProtocol.h"
#import "YWURLResponse.h"
#import "YWCacheCenter.h"


NS_ASSUME_NONNULL_BEGIN

@interface YWBaseApiManager : NSObject<NSCopying>
@property (nonatomic, weak) NSObject <YWAPIManagerProtocol>   * _Nullable child;
@property (nonatomic, weak) id <YWAPIManagerCallRelustDelegate> _Nullable delegate;
@property (nonatomic, weak) id <YWAPIManagerParamSource>        _Nullable paramSource;
@property (nonatomic, weak) id <YWAPIManagerInterceptor>        _Nullable interceptor;
@property (nonatomic, weak) id <YWAPIManagerValidator>          _Nullable validator;

@property (nonatomic, copy,  readonly) NSString * userInfomation;
@property (nonatomic, strong         ) YWURLResponse * _Nullable response;
@property (nonatomic, assign         ) NSInteger timeOutRetryCount;
@property (nonatomic, assign         ) YWCacheType cacheType;


@property (nonatomic, assign, readonly) BOOL isLoading;

/// 请求时，忽略网络状态，级别高于YWConfigure中的autoCheckNet
@property (nonatomic, assign) BOOL ignoreNetStatus;


/**
 类方法请求
 
 @param params 参数
 @param successCallback 成功的回调
 @param failCallback 失败的回调
 @return 对应的taskIdentifier
 */
+ (NSInteger)sendRequestWithParams:(nullable NSDictionary *)params success:(void (^ _Nullable)(YWBaseApiManager * _Nonnull apiManager))successCallback fail:(void (^ _Nullable)(YWBaseApiManager * _Nonnull apiManager))failCallback;
/**
 发起请求

 @return task 对应的taskIdentifier
 */
- (NSInteger)sendRequest;
/**
 重新请求上次任务(适合超时使用)

 @return 对应的taskIdentifier
 */
- (NSInteger)retryRequest;
/**
 取消当前管理类所有的请求任务
 */
- (void)cancelAllRequests;
/**
 取消指定id对应的任务

 @param requestId 任务id
 */
- (void)cancelRequestId:(NSInteger)requestId;


@end

NS_ASSUME_NONNULL_END
