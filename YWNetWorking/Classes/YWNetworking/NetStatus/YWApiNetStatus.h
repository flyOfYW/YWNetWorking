//
//  YWApiNetStatus.h
//  YWNetworkingExamples
//
//  Created by Mr.Yao on 2019/9/9.
//  Copyright © 2019 姚威. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface YWApiNetStatus : NSObject

/**
 是否有网络
 */
@property (nonatomic, assign, readonly, getter=isReachable) BOOL reachable;
/**
 是否wifi，1-wift，2-手机流量,默认0
 */
@property (nonatomic, assign, readonly,      getter=isWifi) NSInteger wifi;

/**
 获取全局唯一的监听网络状态对象

 @return 对象
 */
+ (instancetype)sharedInstance;
/**
 开始监听网络状态
 */
- (void)startMonitoring;
/**
 获取当前网络类型

 @return 网络类型
 */
- (NSString *)getNetType;
@end

NS_ASSUME_NONNULL_END
