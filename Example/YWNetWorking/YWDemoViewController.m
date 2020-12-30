//
//  YWDemoViewController.m
//  YWNetWorking_Example
//
//  Created by Mr.Yao on 2019/9/16.
//  Copyright © 2019 flyOfYW. All rights reserved.
//

#import "YWDemoViewController.h"
#import <YWNetWorking/YWConfigure.h>
#import <YWNetWorking/YWApiNetStatus.h>
#import <YWNetWorking/YWServiceProtocol.h>
#import "YWDemoApi.h"

@interface YWDemoViewController ()<YWAPIManagerCallRelustDelegate,YWAPIManagerParamSource,YWAPIManagerInterceptor>

@property (nonatomic, strong) YWDemoApi *api;
@property (nonatomic, strong) YWDemoApi *retryApi;

@end

@implementation YWDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAction:) name:YWApiValidateResultKeyNSNotificationRefrenToken object:nil];//监听刷新token的通知
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationLogingAction:) name:YWApiValidateResultKeyNSNotificationLogin object:nil];//需要登录的通知
    
}

- (void)notificationLogingAction:(NSNotification *)noti{
//    YWBaseApiManager *manater = noti.object[YWManagerToContinueWhenUserTokenNotificationKey];
    
    
}
- (void)notificationAction:(NSNotification *)noti{

    //业务场景，当某个请求时，token失效了，如果服务器支持刷新token，则可以先刷新token，然后在进行之前的请求，如下
    YWBaseApiManager *manater = noti.object[YWManagerToContinueWhenUserTokenNotificationKey];

    //刷新token
    
    //进一步的优化，可以拦截之前的请求，回调失败的方法，因此可以给之前的api的对象，设置拦截器
    //manager:(YWBaseApiManager *)manager beforePerformFailWithResponse:(YWURLResponse *)response，返回no，则之前的请求即不回走失败的回调
    
    
    //重新请求之前的请求
    
    [manater retryRequest];
    
}
//请求失败（回调）前的拦截方法
- (BOOL)manager:(YWBaseApiManager *)manager beforePerformFailWithResponse:(YWURLResponse *)response{
    return NO;
}
//请求成功回调）前的拦截方法，可以进行一些其他操作，比如开启一个异步线程，进行对数据的缓存
- (void)manager:(YWBaseApiManager *)manager beforePerformSuccessWithResponse:(YWURLResponse *)response{
    
}
- (IBAction)agentAction:(id)sender {
    [[YWApiNetStatus sharedInstance] simpleCheckProxyStatus];
    NSLog(@"proxy status is :%d", (int)[YWApiNetStatus sharedInstance].isProxyStatus);
}
- (IBAction)vpnAction:(id)sender {
    
    NSLog(@"vpn is open :%d", (int)[[YWApiNetStatus sharedInstance] isVpnOn]);
}

- (IBAction)netTypeAction:(id)sender {
    
    NSLog(@"网络类型：%@",[YWApiNetStatus sharedInstance].getNetType);
    
}
- (IBAction)checkNetStatusAction:(id)sender {
    NSLog(@"网络类型：%@",[YWApiNetStatus sharedInstance].isReachable ? @"有网络":@"无网络");
}

- (IBAction)requestAction:(id)sender {
    [self.api sendRequest];
}
- (IBAction)retryRequestAction:(id)sender {
    //同样的api，内部自动实现，超时重试
    [self.retryApi sendRequest];
}

- (void)managerCallAPIDidFailed:(YWBaseApiManager *)manager{
    NSLog(@"失败的提示语：%@",manager.userInfomation);
}
- (void)managerCallAPIDidSuccess:(YWBaseApiManager *)manager{
    NSLog(@"成功的提示语：%@",manager.userInfomation);
    NSLog(@"返回的数据:%@",manager.response.content);
}
- (NSDictionary *)paramsForApi:(YWBaseApiManager *)manager{
    return nil;
}
- (YWDemoApi *)api{
    if (!_api) {
        _api = [[YWDemoApi alloc] init];
        _api.delegate = self;
        _api.paramSource = self;
        _api.interceptor = self;//拦截器，非必须的时候，拦截器应当设置一个管理类，进行一些特殊的业务处理
    }
    return _api;
}
- (YWDemoApi *)retryApi{
    if (!_retryApi) {
        _retryApi = [[YWDemoApi alloc] init];
        _retryApi.delegate = self;
        _retryApi.paramSource = self;
        _retryApi.timeOutRetryCount = 2;//请求超时，重试2
        _retryApi.cacheType = YWCacheTypeMemory;//内存缓存
    }
    return _retryApi;
}


@end
