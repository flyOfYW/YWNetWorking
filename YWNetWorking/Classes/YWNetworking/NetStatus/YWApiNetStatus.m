//
//  YWApiNetStatus.m
//  YWNetworkingExamples
//
//  Created by Mr.Yao on 2019/9/9.
//  Copyright © 2019 姚威. All rights reserved.
//

#import "YWApiNetStatus.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#if __has_include(<AFNetworking/AFNetworkReachabilityManager.h>)
#import <AFNetworking/AFNetworkReachabilityManager.h>
#elif __has_include("AFNetworkReachabilityManager.h")
#import "AFNetworkReachabilityManager.h"
#endif


#if __has_include(<Reachability/Reachability.h>)
#import <Reachability/Reachability.h>
#elif __has_include("Reachability.h")
#import "Reachability.h"
#endif


#define HasAFNetworkReachability (__has_include(<AFNetworking/AFNetworkReachabilityManager.h>) || __has_include("AFNetworkReachabilityManager.h"))
#define HasAppleReachability (__has_include(<Reachability/Reachability.h>) || __has_include("Reachability.h"))


/** 设置代理的通知key */
NSString * const YWApiNetStatus_proxyStatus_key         = @"YWApiNetStatus_proxyStatus_key";

/** 网络发生变化 */
NSString * const YWApiNetStatus_netStatus_key           = @"YWApiNetStatus_netStatus_key";

@interface YWApiNetStatus ()
@property (nonatomic, assign, readwrite, getter=isReachable) BOOL reachable;
@property (nonatomic, assign, readwrite,      getter=isWifi) NSInteger wifi;
@property (nonatomic, assign, readwrite, getter=isProxyStatus) BOOL proxyStatus;
@end

@implementation YWApiNetStatus

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static YWApiNetStatus *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[YWApiNetStatus alloc] init];
    });
    return sharedInstance;
}
- (void)startMonitoring{
#if HasAFNetworkReachability
    [self startMonitoringOnAFNetworkReachabilityManager];
#elif HasAppleReachability
    [self startMonitoringOnReachability];
#else
    NSAssert(NO, @"请导入AFNetworking/Reachability后再使用网络检测功能");
#endif
}
- (void)startMonitoringOnReachability{
#if HasAppleReachability
    //注册通知，异步加载，判断网络连接情况
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    [reachability startNotifier];
#endif
    
}
- (void)startMonitoringOnAFNetworkReachabilityManager{
#if HasAFNetworkReachability
    
    // 创建网络监听管理者
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    // 监听网络状态
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
            case AFNetworkReachabilityStatusUnknown://未知网络
                self.reachable = NO;
                self.wifi = 0;
                break;
            case AFNetworkReachabilityStatusNotReachable://暂无网络
                self.reachable = NO;
                self.wifi = 0;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN://蜂窝数据
                self.reachable = YES;
                self.wifi = 2;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi://WiFi
                self.reachable = YES;
                self.wifi = YES;
                self.wifi = 1;
                break;
            default:
                break;
        }
        //业务层可能涉及UI操作，因此保证在主线程发出通知
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:YWApiNetStatus_netStatus_key object:nil];
        });
    }];
    // 开启监测
    [manager startMonitoring];
#endif
}
- (void)reachabilityChanged:(NSNotification *)notifiy{
#if HasAppleReachability
    Reachability* curReach = [notifiy object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    NetworkStatus curStatus = [curReach currentReachabilityStatus];
    if (curStatus == NotReachable) {
        self.reachable = NO;
        self.wifi = 0;
    }else if (curStatus == ReachableViaWiFi){
        self.reachable = YES;
        self.wifi = 1;
    }else if (curStatus == ReachableViaWWAN){
        self.reachable = YES;
        self.wifi = 2;
    }
    //业务层可能涉及UI操作，因此保证在主线程发出通知
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:YWApiNetStatus_netStatus_key object:nil];
    });
#endif
    
}

- (void)simpleCheckProxyStatus {
    
    NSDictionary *proxySettings = (__bridge NSDictionary *)(CFNetworkCopySystemProxySettings());
    
    NSArray *proxies = (__bridge NSArray *)(CFNetworkCopyProxiesForURL((__bridge CFURLRef _Nonnull)([NSURL URLWithString:@"https://www.baidu.com"]), (__bridge CFDictionaryRef _Nonnull)(proxySettings)));
    
    NSDictionary *settings = [proxies objectAtIndex:0];
    
    if ([[settings objectForKey:(NSString *)kCFProxyTypeKey]
         isEqualToString:@"kCFProxyTypeNone"]){
        //没有设置代理
        @synchronized (self) {
            self.proxyStatus = NO;
        }
    }else{
        //设置代理了
        @synchronized (self) {
            self.proxyStatus = YES;
        }
        //业务层可能涉及UI操作，因此保证在主线程发出通知
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:YWApiNetStatus_proxyStatus_key object:nil];
        });
    }
}


- (NSString *)getNetType{
    
    if (!self.reachable) {
        return nil;
    }
    if (self.isWifi == 1) {
        return @"wifi";
    }
    if (self.isWifi != 2) {
        return nil;
    }
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    NSString *currentStatus = nil;
    if (@available(iOS 12.0, *)) {
        NSDictionary *d = info.serviceCurrentRadioAccessTechnology;
        if (d) {
            currentStatus = [[d allValues] lastObject];
        }
    } else {
        currentStatus = info.currentRadioAccessTechnology;
    }
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyGPRS"]) {
        return @"GPRS";
    }
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMA1x"]){
        return @"2G";
    }
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyEdge"]) {
        return @"3G";//2.75G EDGE 接近于3G，（2G->3G的过度期）
    }
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyWCDMA"]){
        return @"3G";
    }
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSDPA"]){
        return @"3G";//3.5G HSDPA
    }
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSUPA"]){
        return @"3G";//3.5G HSUPA
    }
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORev0"]){
        return @"3G";//国际标准3G
    }
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevA"]){
        return @"3G";
    }
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevB"]){
        return @"3G";
    }
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyeHRPD"]){
        return @"3G";//HRPD
    }
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyLTE"]){
        return @"4G";
    }
    return currentStatus;
}
- (BOOL)isVpnOn{
    //ios 9 以上
    BOOL flag = NO;
    NSDictionary *dict = CFBridgingRelease(CFNetworkCopySystemProxySettings());
    NSArray *keys = [dict[@"__SCOPED__"] allKeys];
    for (NSString *key in keys) {
        if ([key rangeOfString:@"tap"].location != NSNotFound ||
            [key rangeOfString:@"tun"].location != NSNotFound ||
            [key rangeOfString:@"ipsec"].location != NSNotFound ||
            [key rangeOfString:@"ppp"].location != NSNotFound){
            flag = YES;
            break;
        }
    }
    return flag;
}
@end
