//
//  YWBaseApiManager.m
//  YWNetworkingExamples
//
//  Created by Mr.Yao on 2019/9/9.
//  Copyright © 2019 姚威. All rights reserved.
//

#import "YWBaseApiManager.h"
#import "YWConfigure.h"
#import "YWServiceManager.h"
#import "YWApiAFAction.h"
#import "YWLogManager.h"
#import "YWApiNetStatus.h"
#import "NSURLRequest+YWNetParams.h"

NSString * const YWManagerToContinueWhenUserTokenNotificationKey = @"YWManagerToContinueWhenUserTokenNotificationKey";


@interface YWBaseApiManager ()
{
    struct {//因为考虑到成功或失败的回调可能会经常调用，因此使用结构体缓存状态
        unsigned managerCallAPIDidSuccess : 1;
        unsigned managerCallAPIDidFailed : 1;
        
    } _delegateHas;
    struct {
        unsigned validatorParmas : 1;
    } _validatorHas;
    struct {
        unsigned retryCount : 1;
        unsigned continueFail : 1;
        unsigned beforeSuccess : 1;
    } _interceptorHas;
}
@property (nonatomic, assign, readwrite) BOOL isLoading;
@property (nonatomic, copy,   readwrite) NSString * userInfomation;
@property (nonatomic, strong           ) NSMutableArray *requestIdList;
@property (nonatomic, strong,  nullable) void (^successBlock)(YWBaseApiManager *apimanager);
@property (nonatomic, strong,  nullable) void (^failBlock)(YWBaseApiManager *apimanager);
@property (nonatomic, assign           ) NSInteger currentRetryCount;

@end


@implementation YWBaseApiManager

- (instancetype)init{
    self = [super init];
    if (self) {
        if ([self conformsToProtocol:@protocol(YWAPIManagerProtocol)]) {
            self.child = (id <YWAPIManagerProtocol>)self;
        } else {
            NSException *exception = [NSException exceptionWithName:@"YWAPIManagerProtocol" reason:@"继承于YWBaseApiManager的子类，必须遵守YWAPIManagerProtocol" userInfo:nil];
            @throw exception;
        }
    }
    return self;
}
- (id)copyWithZone:(NSZone *)zone{
    return self;
}
//MARK: ----------------------- Public Action --------------------------------
+ (NSInteger)sendRequestWithParams:(NSDictionary *)params success:(void (^)(YWBaseApiManager * _Nonnull))successCallback fail:(void (^)(YWBaseApiManager * _Nonnull))failCallback{
    return [[[self alloc] init] sendRequestWithParams:params success:successCallback fail:failCallback];
}
- (NSInteger)sendRequest{
    
    //1.check url&parma

    //2.check cache
    
    //3.send request
    
    //4.handle respone
    
    //5.call&cache
    
   return [self sendRequestWithRestCount:YES checkCache:YES];
    
}
- (NSInteger)retryRequest{
    if (self.isLoading) {
        return -1;
    }
    return [self retryRequestWhenTimeOutIsRestRequestCount:YES];
}

- (void)cancelAllRequests{
    [[YWApiAFAction sharedInstance] cancelRequestWithRequestIdList:self.requestIdList];
    [self.requestIdList removeAllObjects];
}

- (void)cancelRequestId:(NSInteger)requestId{
    if (requestId < 0) {
        [self.requestIdList removeObject:@(requestId)];
        return;
    }
    [[YWApiAFAction sharedInstance] cancelRequestWithRequestId:@(requestId)];
    [self.requestIdList removeObject:@(requestId)];
}

//MARK: ----------------------- Private Action ------------------------

- (NSInteger)sendRequestWithParams:(NSDictionary *)params success:(void (^)(YWBaseApiManager *))successCallback fail:(void (^)(YWBaseApiManager *))failCallback{
    
    return [self beforeSendRequest:params withRestCount:YES checkCache:YES];
}
- (NSInteger)sendRequestWithRestCount:(BOOL)rest checkCache:(BOOL)cache{
    if (self.isLoading) {
        return -1;
    }
    if (![self checkNetStatus]) {
        return -1;
    }
    NSDictionary *parmas = [self.paramSource paramsForApi:self];
    
    return [self beforeSendRequest:parmas withRestCount:rest checkCache:cache];
}

- (NSInteger)retryRequestWhenTimeOutIsRestRequestCount:(BOOL)rest{
    if (![self checkNetStatus]) {
        return -1;
    }
    NSNumber *taskIdentifier = self.requestIdList.firstObject;
    
    if (!taskIdentifier) {
        return [self sendRequestWithRestCount:rest checkCache:NO];
    }
    NSURLSessionDataTask *task = [[YWApiAFAction sharedInstance] getTaskWithRequestId:taskIdentifier];
    if (!task || !task.originalRequest) {
        return [self sendRequestWithRestCount:rest checkCache:NO];
    }
    id <YWServiceProtocol>serviceManager = [[YWServiceManager sharedInstance] serviceWithClass:self.child.serviceClassName];
    self.isLoading = YES;
    return [self startSendRequest:task.originalRequest service:serviceManager withRestCount:rest];
}
- (NSInteger)beforeSendRequest:(nullable NSDictionary *)params withRestCount:(BOOL)rest checkCache:(BOOL)cache{
    self.isLoading = YES;
    if (![self checkConditionSend:params]) {
        self.isLoading = NO;
        [self failedCallOnMainThread];
        return -1;
    }
    return [self startSendRequest:params withRestCount:rest checkCache:cache];
}
- (NSInteger)startSendRequest:(NSDictionary *)parmas withRestCount:(BOOL)rest checkCache:(BOOL)cache{
    
    if (![self checkCacheStatus:cache params:parmas]) {
        return -1;
    }
    
    id <YWServiceProtocol>serviceManager = [[YWServiceManager sharedInstance] serviceWithClass:self.child.serviceClassName];
    
    NSURLRequest *request = [serviceManager requestWithMethod:self.child.requestType URLString:self.child.requestAddress parameters:parmas];
    request.requestParams = parmas;
    if (!request) {
        self.isLoading = NO;
        self.userInfomation = @"初始化请求任务失败";
        [self failedCallOnMainThread];
        return -1;
    }
    
    return [self startSendRequest:request service:serviceManager withRestCount:rest];
    
}
- (NSInteger)startSendRequest:(NSURLRequest *)request service:(id<YWServiceProtocol>)service withRestCount:(BOOL)rest{
    
    [YWLogManager logDebugInfoWithRequest:request apiName:self.child.requestAddress service:service];
    
    if (rest) {
        self.currentRetryCount = self.timeOutRetryCount;
    }
    
    __weak typeof(self)weakSelf = self;

    NSNumber *taskIdentifier = [[YWApiAFAction sharedInstance] sendRequest:request service:service success:^(YWURLResponse * _Nonnull response) {
        [weakSelf successedCallPrivate:response];
    } fail:^(YWURLResponse * _Nonnull response) {
        [weakSelf failedCallPrivate:response];
    }];
    
    [self.requestIdList addObject:taskIdentifier];
    
    return [taskIdentifier integerValue];
}
- (void)successedCallPrivate:(YWURLResponse *)response{
    
    if (!response.isCallAction) {
        [self failedCallPrivate:response];
        return;
    }
    
    //1.移除当前的任务ID
    [self.requestIdList removeObject:@(response.requestId)];
    self.isLoading = NO;

    //2.缓存数据
    
    [self saveCache:response];
    
    //3.拦截器
    if (_interceptorHas.beforeSuccess) {
        [_interceptor manager:self beforePerformSuccessWithResponse:response];
    }
    
    //4.回调
    if (_delegateHas.managerCallAPIDidSuccess) {
        self.response = response;
        self.userInfomation = [NSString stringWithFormat:@"%@",response.userInformation];
        [self successCallOnMainThread];
    }
}
- (void)failedCallPrivate:(YWURLResponse *)response{
    
    self.isLoading = NO;
    
    [self addNotifiAction:response.needLogin refreshToken:response.refreshToken];
    
    //1.拦截器(处理一些错误，比如登录/刷新token)
    BOOL isContinue = YES;
    if (_interceptorHas.continueFail) {
       isContinue = [_interceptor manager:self beforePerformFailWithResponse:response];
    }
    if (!isContinue) {
        
        return;
    }

    //2.超时重试机制
    
    if (response.status == NSURLErrorTimedOut) {
        if (self.timeOutRetryCount != 0) {//启用重试
            if (self.currentRetryCount != 0) {//当前剩余的次数
                self.currentRetryCount -= 1;
                NSInteger retry = self.timeOutRetryCount - self.currentRetryCount;
                [YWLogManager logDebugInfoWithRetryApiName:self.child.requestAddress retryCount:retry];
                [self retryRequestWhenTimeOutIsRestRequestCount:NO];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self->_interceptorHas.retryCount) {
                        [self.interceptor manager:self retryCount:retry];
                    }
                });
                return;
            }
        }
    }
    
    //3.移除当前的任务ID
    [self.requestIdList removeObject:@(response.requestId)];

    //4.回调
    if (_delegateHas.managerCallAPIDidFailed) {
        self.response = response;
        self.userInfomation = [NSString stringWithFormat:@"%@",response.userInformation];
        [self failedCallOnMainThread];
    }
}
- (void)failedCallOnMainThread{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate managerCallAPIDidFailed:self];
    });
}
- (void)successCallOnMainThread{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate managerCallAPIDidSuccess:self];
    });
}
- (void)addNotifiAction:(BOOL)needLogin refreshToken:(BOOL)refreshToken{
    if (needLogin) {
        [[NSNotificationCenter defaultCenter] postNotificationName:YWApiValidateResultKeyNSNotificationLogin
                                                            object:nil
                                                          userInfo:@{
                                                                     YWManagerToContinueWhenUserTokenNotificationKey:self
                                                                     }];
    }
    if (refreshToken) {
        [[NSNotificationCenter defaultCenter] postNotificationName:YWApiValidateResultKeyNSNotificationRefrenToken
                                                            object:nil
                                                          userInfo:@{
                                                                     YWManagerToContinueWhenUserTokenNotificationKey:self
                                                                     }];
    }
}

///检查该请求是否合理（地址以及参数等）
- (BOOL)checkConditionSend:(NSDictionary *)parmas{
    if (!self.child.requestAddress || self.child.requestAddress.length <= 0) {
        return NO;
    }
    if (self.validator) {
        if (_validatorHas.validatorParmas) {
            YWAPIValidatorErrorType error = [self.validator manager:self validatorWithParamsData:parmas];
            if (error == YWAPIValidatorErrorTypeParamsError) {
                self.userInfomation = @"参数错误";
                return NO;//参数错误
            }
        }
    }
    return YES;
}
- (BOOL)checkNetStatus{
    if (![self isReachable]) {
         self.isLoading = NO;
         self.userInfomation = [NSString stringWithFormat:@"%@",[YWConfigure sharedInstance].netError];
         [self failedCallOnMainThread];
         return NO;
     }
    return YES;
}
- (BOOL)checkCacheStatus:(BOOL)cache params:(NSDictionary *)params{
    if (!cache) {
        return YES;
    }
    if (self.cacheType == YWCacheTypeDefalut) {
        return YES;
    }
    if (self.cacheType == YWCacheTypeMemory) {
        NSString *key = [NSString stringWithFormat:@"%@%d%@",self.child.requestAddress,(int)self.child.requestType,[self transformToUrlParamString:params]];
       YWURLResponse * respne = [YWCacheCenter findCache:YWCacheTypeMemory withKey:key];
        key = nil;
        if (!respne) {
            return YES;
        }
        [self successedCallPrivate:respne];
        return NO;
    }
    return YES;
}

- (void)saveCache:(YWURLResponse *)respone{
    if (self.cacheType == YWCacheTypeDefalut) {
        return;
    }
    if (self.cacheType == YWCacheTypeMemory) {//NSCache线程安全
       __block NSString *key = @"";
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            key = [NSString stringWithFormat:@"%@%d%@",self.child.requestAddress,(int)self.child.requestType,[self transformToUrlParamString:respone.requestParams]];
            [YWCacheCenter saveRespone:respone cache:YWCacheTypeMemory withKey:key];
            dispatch_async(dispatch_get_main_queue(), ^{
                key = nil;
            });
            
        });
    }
}
- (NSString *)transformToUrlParamString:(NSDictionary *)params{
    NSMutableString *paramString = [NSMutableString string];
    for (int i = 0; i < params.count; i ++) {
        NSString *string;
        if (i == 0) {
            string = [NSString stringWithFormat:@"?%@=%@", params.allKeys[i], params[params.allKeys[i]]];
        } else {
            string = [NSString stringWithFormat:@"&%@=%@", params.allKeys[i], params[params.allKeys[i]]];
        }
        [paramString appendString:string];
    }
    return paramString;
}
//MARK: ------------------------------ Getter & Setter ----------------------------------
- (BOOL)isReachable{
    
    if ([YWConfigure sharedInstance].autoCheckNet) {//config控制
        return [YWApiNetStatus sharedInstance].isReachable;
    }
    return YES;
}
- (NSMutableArray *)requestIdList{
    if (_requestIdList == nil) {
        _requestIdList = [[NSMutableArray alloc] init];
    }
    return _requestIdList;
}
- (void)setDelegate:(id<YWAPIManagerCallRelustDelegate>)delegate{
    _delegate = delegate;
    _delegateHas.managerCallAPIDidSuccess = [delegate respondsToSelector:@selector(managerCallAPIDidSuccess:)];
    _delegateHas.managerCallAPIDidFailed = [delegate respondsToSelector:@selector(managerCallAPIDidFailed:)];
}
- (void)setValidator:(id<YWAPIManagerValidator>)validator{
    _validator = validator;
    _validatorHas.validatorParmas = [validator respondsToSelector:@selector(manager:validatorWithParamsData:)];
}
- (void)setInterceptor:(id<YWAPIManagerInterceptor>)interceptor{
    _interceptor = interceptor;
    _interceptorHas.retryCount = [interceptor respondsToSelector:@selector(manager:retryCount:)];
    _interceptorHas.continueFail = [interceptor respondsToSelector:@selector(manager:beforePerformFailWithResponse:)];
    _interceptorHas.beforeSuccess = [interceptor respondsToSelector:@selector(manager:beforePerformSuccessWithResponse:)];
}

- (void)dealloc{
    [self cancelAllRequests];
    self.requestIdList = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
