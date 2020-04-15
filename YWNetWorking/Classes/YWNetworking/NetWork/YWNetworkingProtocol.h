//
//  YWNetworkingProtocol.h
//  YWNetworkingExamples
//
//  Created by Mr.Yao on 2019/9/9.
//  Copyright © 2019 姚威. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YWBaseApiManager;
@class YWURLResponse;


NS_ASSUME_NONNULL_BEGIN

/** 当登录或者刷新token，以通知的形式通知业务处理者 */
extern NSString * const YWManagerToContinueWhenUserTokenNotificationKey;

typedef NS_ENUM (NSUInteger, YWServiceAPIEnvironment){
    YWServiceAPIEnvironmentDevelop,
    YWServiceAPIEnvironmentRelease,
    YWServiceAPIEnvironmentReleaseSpare
};

typedef NS_ENUM (NSUInteger, YWAPIRequestType){
    YWAPIRequestTypeGet,
    YWAPIRequestTypePost,
    YWAPIRequestTypePut,
    YWAPIRequestTypeDelete,
};
typedef NS_ENUM (NSUInteger, YWAPIValidatorErrorType){
    YWAPIValidatorErrorTypeDefalut,
    YWAPIValidatorErrorTypeParamsError,
};



@protocol YWAPIManagerProtocol <NSObject>

@required
/**
 请求方式
 
 @return 请求方式
 */
- (YWAPIRequestType)requestType;
/**
 不为空的请求地址
 
 @return 请求地址
 */
- (nonnull NSString *)requestAddress;
/**
 管理service的类
 
 @return 类名
 */
- (nonnull NSString *)serviceClassName;

@end

@protocol YWAPIManagerParamSource <NSObject>

- (nullable NSDictionary *)paramsForApi:(nonnull YWBaseApiManager *)manager;


@end


@protocol YWAPIManagerCallRelustDelegate <NSObject>
@optional
/**
 成功的回调
 
 @param manager api管理者
 */
- (void)managerCallAPIDidSuccess:(nonnull YWBaseApiManager *)manager;
/**
 失败的回调
 
 @param manager api管理者
 */
- (void)managerCallAPIDidFailed:(nonnull YWBaseApiManager *)manager;
@end


@protocol YWAPIManagerInterceptor <NSObject>
@optional
/**
 超时自动请求前的回调
 
 @param manager api管理者
 @param retryCount 当前重连的次数
 */
- (void)manager:(nonnull YWBaseApiManager *)manager retryCount:(NSInteger)retryCount;
/**
 请求失败前的回调
 
 @param manager api管理者
 @param response 请求结果的管理者
 @return YES/NO,YES-继续往下执行，继续回调managerCallAPIDidFailed，NO-代码执行到当前，不需要回调managerCallAPIDidFailed了
 */
- (BOOL)manager:(nonnull YWBaseApiManager *)manager beforePerformFailWithResponse:(nonnull YWURLResponse *)response;
/**
 请求成功前的回调
 
 @param manager api管理者
 @param response 请求结果的管理者
 */
- (void)manager:(nonnull YWBaseApiManager *)manager beforePerformSuccessWithResponse:(nonnull YWURLResponse *)response;


@end

@protocol YWAPIManagerValidator <NSObject>
@optional
/**
 发送请求前的参数检验
 
 @param manager api管理者
 @param data 请求参数
 @return 错误定义
 */
- (YWAPIValidatorErrorType)manager:(nonnull YWBaseApiManager *)manager validatorWithParamsData:(nonnull NSDictionary *)data;


@end


@protocol YWAPIManagerCacheInterceptor <NSObject>
@optional
/**
 拦截返回的数据进行自定义的缓存处理
 
 @param manager api管理者
 @param response 返回的数据对象
 */
- (void)manager:(nonnull YWBaseApiManager *)manager saveCache:(nullable YWURLResponse *)response;
/**
 查询缓存数据进行
 @param manager api管理者
 @return 返回的数据对象
 */
- (nullable id)findCache:(nonnull YWBaseApiManager *)manager;

@end




NS_ASSUME_NONNULL_END
