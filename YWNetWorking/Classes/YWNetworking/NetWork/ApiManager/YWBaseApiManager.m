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
        unsigned managerCallAPIDidRepeated : 1;
        unsigned managerCallAPIDidFindedCacheSuccess : 1;
        unsigned managerCallAPIDidFindedCacheFailed : 1;
    } _delegateHas;
    struct {
        unsigned validatorParmas : 1;
    } _validatorHas;
    struct {
        unsigned retryCount : 1;
        unsigned continueFail : 1;
        unsigned beforeSuccess : 1;
    } _interceptorHas;
    struct {
        unsigned saveCache : 1;
        unsigned findCache : 1;
        unsigned continueFindCache : 1;
    } _cacheHas;
}
@property (nonatomic, assign, readwrite) BOOL isLoading;
@property (nonatomic, copy,   readwrite) NSString * userInfomation;
@property (nonatomic, strong           ) NSMutableArray *requestIdList;
@property (nonatomic, strong,  nullable) void (^successBlock)(YWBaseApiManager *apimanager);
@property (nonatomic, strong,  nullable) void (^failBlock)(YWBaseApiManager *apimanager);
@property (nonatomic, strong,  nullable) void (^repeatedBlock)(YWBaseApiManager *apimanager);
@property (nonatomic, assign           ) NSInteger currentRetryCount;
@property (nonatomic, assign, readwrite) NSInteger currentRequestId;

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
+ (NSInteger)sendRequestWithParams:(nullable NSDictionary *)params
                          repeated:(void (^ _Nullable)(YWBaseApiManager * _Nonnull apiManager))repeatedCallback
                           success:(void (^ _Nullable)(YWBaseApiManager * _Nonnull apiManager))successCallback
                              fail:(void (^ _Nullable)(YWBaseApiManager * _Nonnull apiManager))failCallback{
    return [[[self alloc] init] sendRequestWithParams:params repeated:repeatedCallback success:successCallback fail:failCallback];
}
+ (NSInteger)sendRequestWithParams:(NSDictionary *)params
                           success:(void (^)(YWBaseApiManager * _Nonnull))successCallback
                              fail:(void (^)(YWBaseApiManager * _Nonnull))failCallback{
    return [[[self alloc] init] sendRequestWithParams:params repeated:nil success:successCallback fail:failCallback];
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
        [self repeatedRequestsCallOnMainThread];
        return _currentRequestId;
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

- (NSInteger)sendRequestWithParams:(NSDictionary *)params
                          repeated:(void (^ _Nullable)(YWBaseApiManager * _Nonnull apiManager))repeatedCallback
                           success:(void (^)(YWBaseApiManager *))successCallback
                              fail:(void (^)(YWBaseApiManager *))failCallback{
    _repeatedBlock = repeatedCallback;
    _successBlock = successCallback;
    _failBlock = failCallback;
    return [self beforeSendRequest:params withRestCount:YES checkCache:YES];
}
- (NSInteger)sendRequestWithRestCount:(BOOL)rest checkCache:(BOOL)cache{
    if (self.isLoading) {
        [self repeatedRequestsCallOnMainThread];
        return _currentRequestId;
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
    if (!request.requestParams) {//如何外部没有赋值，则内部赋值
        request.requestParams = parmas;
    }
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
        if (response.isCallAction) {
            [weakSelf successedCallPrivate:response];
        }else{
            [weakSelf failedCallPrivate:response];
        }
    } fail:^(YWURLResponse * _Nonnull response) {
        if (response.isCallSucessAction) {
            [weakSelf successedCallPrivate:response];
        }else{
            [weakSelf failedCallPrivate:response];
        }
    }];
    
    [self.requestIdList addObject:taskIdentifier];
    
    _currentRequestId = [taskIdentifier integerValue];
    
    return [taskIdentifier integerValue];
}
- (void)successedCallPrivate:(YWURLResponse *)response{
    
    //1.移除当前的任务ID
    [self.requestIdList removeObject:@(response.requestId)];
    
    self.isLoading = NO;
    self.response = response;
    self.userInfomation = [NSString stringWithFormat:@"%@",response.userInformation];
    
    //2.缓存数据
    
    [self saveCache:response];
    
    //3.拦截器
    if (_interceptorHas.beforeSuccess) {
        [_interceptor manager:self beforePerformSuccessWithResponse:response];
    }
    
    //4.回调
    [self successCallOnMainThread];
}
- (void)failedCallPrivate:(YWURLResponse *)response{
    
    self.isLoading = NO;
    
    self.response = response;
    
    self.userInfomation = [NSString stringWithFormat:@"%@",response.userInformation];
    
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
    [self failedCallOnMainThread];
}
//MARK: --- private call on main thread --------
- (void)failedCallOnMainThread{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_delegateHas.managerCallAPIDidFailed) {
            [self.delegate managerCallAPIDidFailed:self];
        }else{
            self.failBlock(self);
        }
    });
}
- (void)successCallOnMainThread{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_delegateHas.managerCallAPIDidSuccess) {
            [self.delegate managerCallAPIDidSuccess:self];
        }else{
            self.successBlock(self);
        }
    });
}
- (void)repeatedRequestsCallOnMainThread{
    _userInfomation = @"请勿重复操作";
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_delegateHas.managerCallAPIDidRepeated) {
            [self.delegate managerCallAPIDidRepeatedRequests:self];
        }else{
            self.repeatedBlock(self);
        }
    });
}
- (void)successCallOnMainThreadWhenFindCache:(YWURLResponse *)response{
    
    self.response = response;
    self.userInfomation = [NSString stringWithFormat:@"%@",response.userInformation];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_delegateHas.managerCallAPIDidFindedCacheSuccess) {
            [self.delegate managerCallAPIDidFindCacheSuccess:self];
        }
    });
    
}
- (void)failedCallOnMainThreadWhenFindCache{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_delegateHas.managerCallAPIDidFindedCacheFailed) {
            [self.delegate managerCallAPIDidFindCacheFailed:self];
        }
    });
}
//MARK: --- add NotifiActio ----
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
//MARK: ----- check -----
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
    if (_cacheType == YWCacheTypeDefalut) {
        return YES;
    }
    if (_cacheType == YWCacheTypeMemory) {
        NSString *key = [NSString stringWithFormat:@"%@%d%@",self.child.requestAddress,(int)self.child.requestType,[self transformToUrlParamString:params]];
       YWURLResponse * respne = [YWCacheCenter findCache:YWCacheTypeMemory withKey:key];
        key = nil;
        
        if (!respne) {
            [self failedCallOnMainThreadWhenFindCache];
            return YES;
        }
        [self successCallOnMainThreadWhenFindCache:respne];
        
        if (_cacheHas.continueFindCache) {
            return [_cache managerIsContinueWhenFindCache:self];
        }
        
        return YES;
        
    }else if (_cacheType == YWCacheTypeCustom){
        if (_cacheHas.findCache) {
             id content = [_cache findCache:self];
            if (!content) {
                [self failedCallOnMainThreadWhenFindCache];
                return YES;
            }
            
            [self successCallOnMainThreadWhenFindCache:[[YWURLResponse alloc] initWithCacheResponseObject:content]];
            
            if (_cacheHas.continueFindCache) {
                return [_cache managerIsContinueWhenFindCache:self];
            }
            
            return YES;
        }
    }
    return YES;
}

- (void)saveCache:(YWURLResponse *)respone{
    if (_cacheType == YWCacheTypeDefalut) {
        return;
    }
    if (_cacheType == YWCacheTypeMemory) {//NSCache线程安全
       __block NSString *key = @"";
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            key = [NSString stringWithFormat:@"%@%d%@",self.child.requestAddress,(int)self.child.requestType,[self transformToUrlParamString:respone.requestParams]];
            [YWCacheCenter saveRespone:respone cache:YWCacheTypeMemory withKey:key];
            dispatch_async(dispatch_get_main_queue(), ^{
                key = nil;
            });
            
        });
    }else if (_cacheType == YWCacheTypeCustom){
        if (_cacheHas.saveCache) {
            [_cache manager:self saveCache:respone];
        }
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
    if (_ignoreNetStatus) {
        return YES;
    }
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
    _delegateHas.managerCallAPIDidRepeated = [delegate respondsToSelector:@selector(managerCallAPIDidRepeatedRequests:)];
    _delegateHas.managerCallAPIDidFindedCacheSuccess = [delegate respondsToSelector:@selector(managerCallAPIDidFindCacheSuccess:)];
    _delegateHas.managerCallAPIDidFindedCacheFailed = [delegate respondsToSelector:@selector(managerCallAPIDidFindCacheFailed:)];

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
- (void)setCache:(id<YWAPIManagerCacheInterceptor>)cache{
    _cache = cache;
    _cacheHas.saveCache = [cache respondsToSelector:@selector(manager:saveCache:)];
    _cacheHas.findCache = [cache respondsToSelector:@selector(findCache:)];
    _cacheHas.continueFindCache = [cache respondsToSelector:@selector(managerIsContinueWhenFindCache:)];
}
- (void)dealloc{
    [self cancelAllRequests];
    self.requestIdList = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
