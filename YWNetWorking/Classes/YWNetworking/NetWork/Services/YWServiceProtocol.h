//
//  YWServiceProtocol.h
//  YWNetworkingExamples
//
//  Created by Mr.Yao on 2019/9/9.
//  Copyright © 2019 姚威. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YWNetworkingProtocol.h"
#import <AFNetworking/AFNetworking.h>
NS_ASSUME_NONNULL_BEGIN


/** 业务层的数据 */
extern NSString * const YWApiValidateResultKeyResponseObject;
/** 界面的提示语 */
extern NSString * const YWApiValidateResultKeyResponseUserInfomation;
/** 请求成功或者失败 */
extern NSString * const YWApiValidateResultKeyResponseCallStatus;


/** ------- 通知的key -------- */
/** 登录 */
extern NSString * const YWApiValidateResultKeyNSNotificationLogin;
/** 刷新token */
extern NSString * const YWApiValidateResultKeyNSNotificationRefrenToken;


@protocol YWServiceProtocol <NSObject>
@required
/**
 创建NSURLRequest

 @param requestType 请求方式
 @param urlString 请求地址
 @param parameters 请求参数
 @return 返回NSURLRequest
 */
- (NSURLRequest *)requestWithMethod:(YWAPIRequestType)requestType URLString:(nonnull NSString *)urlString parameters:(nullable id)parameters;
/**
 创建AFHTTPSessionManager

 @return 返回manager
 */
- (AFHTTPSessionManager *)sessionManager;
/**
 环境配置

 @return 环境
 */
- (YWServiceAPIEnvironment)apiEnvironment;

/**
 *字典的格式
 key:YWTApiValidateResultKeyResponseObject|YWTApiValidateResultKeyResponseUserInfomation|YWTApiValidateResultKeyResponseObject:可选
 */
/**
 处理服务端返回的信息

 @param responseObject 服务端响应对象
 @param response 请求响应对象
 @param error 服务端返回可能存在的错误
 @return 内部需要的字典；具体返回数据怎么处理，内部不关注
 */
- (NSDictionary *)resultWithResponseObject:(nullable id)responseObject
                                  response:(NSURLResponse *)response
                                     error:(NSError **)error;



@end

NS_ASSUME_NONNULL_END
