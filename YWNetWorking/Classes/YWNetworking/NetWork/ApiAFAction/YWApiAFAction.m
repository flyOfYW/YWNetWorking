//
//  YWApiAFAction.m
//  YWNetworkingExamples
//
//  Created by Mr.Yao on 2019/9/10.
//  Copyright © 2019 姚威. All rights reserved.
//

#import "YWApiAFAction.h"
#import "YWURLResponse.h"
#import "YWLogManager.h"

/** 业务层的数据 */
NSString * const YWApiValidateResultKeyResponseObject         = @"YWApiValidateResultKeyResponseObject";
/** 界面的提示语 */
NSString * const YWApiValidateResultKeyResponseUserInfomation = @"YWApiValidateResultKeyResponseUserInfomation";
/**当session请求成功时，业务层控制回调 成功或者失败 的方法*/
NSString * const YWApiValidateResultKeyResponseCallStatus   = @"YWApiValidateResultKeyResponseCallStatus";
/**当session请求失败时，业务层控制回调 成功或者失败 的方法*/
NSString * const YWApiValidateResultKeyFailCallStatus   = @"YWApiValidateResultKeyFailCallStatus";

/** 登录 */
NSString * const YWApiValidateResultKeyNSNotificationLogin   = @"YWApiValidateResultKeyNSNotificationLogin";
/** 刷新token */
NSString * const YWApiValidateResultKeyNSNotificationRefrenToken   = @"YWApiValidateResultKeyNSNotificationRefrenToken";




@interface YWApiAFAction ()
/** 主要管理requestId */
@property (nonatomic, strong) NSMutableDictionary *dispatchTable;

@end

@implementation YWApiAFAction

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static YWApiAFAction *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[YWApiAFAction alloc] init];
    });
    return sharedInstance;
}
- (AFHTTPSessionManager *)sessionManagerWithService:(id<YWServiceProtocol>)service{
    return  service.sessionManager;
}
- (NSNumber *)sendRequest:(NSURLRequest *)request
                  service:(id<YWServiceProtocol>)service
                  success:(nullable void (^)(YWURLResponse *response))success
                     fail:(nullable void (^)(YWURLResponse *response))fail{
    /**
     * 0.发送请求
     * 1.从任务管理移除当前任务
     * 2.处理返回的数据
     * 3.包装数据
     * 4.日志处理
     */
    __weak typeof(self)weakSelf = self;
    __block AFHTTPSessionManager *manager = [self sessionManagerWithService:service];
    __block NSURLSessionDataTask *task = [manager dataTaskWithRequest:request
                                                       uploadProgress:nil
                                                     downloadProgress:nil
                                                    completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                                        
                                                        NSNumber *requestId = @([task taskIdentifier]);
                                                        [weakSelf.dispatchTable removeObjectForKey:requestId];
                                                        
                                                        NSDictionary *dict = [service resultWithResponseObject:responseObject response:response error:error];
                                                        
                                                        YWURLResponse *respne = [[YWURLResponse alloc] initWithResponseObject:dict[YWApiValidateResultKeyResponseObject]
                                                                                                                      request:request
                                                                                                                    requestId:requestId userInformation:dict[YWApiValidateResultKeyResponseUserInfomation]
                                                                                                                   callStatus:dict
                                                                                                                        error:error];
                                                        
                                                        respne.needLogin = dict[YWApiValidateResultKeyNSNotificationLogin] ? [dict[YWApiValidateResultKeyNSNotificationLogin] boolValue] : NO;
                                                        respne.refreshToken = dict[YWApiValidateResultKeyNSNotificationRefrenToken] ? [dict[YWApiValidateResultKeyNSNotificationRefrenToken] boolValue] : NO;
                                                        
                                                        [YWLogManager logDebugInfoWithResponse:(NSHTTPURLResponse *)response responseObject:dict[YWApiValidateResultKeyResponseObject] request:request error:error];
                                                        requestId = nil;
                                                        [manager.session finishTasksAndInvalidate];
                                                        if (error) {
                                                            fail ? fail(respne) : nil;
                                                        }else{
                                                            success ? success(respne) : nil;
                                                        }
                                                        
                                                    }];
    [task resume];
    NSNumber *requestId = @([task taskIdentifier]);
    self.dispatchTable[requestId] = task;
    return requestId;
}
- (nullable NSURLSessionDataTask *)getTaskWithRequestId:(NSNumber *)requestId{
    return self.dispatchTable[requestId];
}

- (void)cancelRequestWithRequestIdList:(NSArray *)requestIdList{
    for (NSNumber *requestId in requestIdList) {
        [self cancelRequestWithRequestId:requestId];
    }
}
- (void)cancelRequestWithRequestId:(NSNumber *)requestId{
    NSURLSessionDataTask *requestOperation = self.dispatchTable[requestId];
    [requestOperation cancel];
    [self.dispatchTable removeObjectForKey:requestId];
}



- (void)deallocDispatchTable{
    [self.dispatchTable removeAllObjects];
    self.dispatchTable = nil;
}
- (NSMutableDictionary *)dispatchTable{
    if (_dispatchTable == nil) {
        _dispatchTable = [[NSMutableDictionary alloc] init];
    }
    return _dispatchTable;
}

@end
