//
//  YWServiceManager.h
//  YWNetworkingExamples
//
//  Created by Mr.Yao on 2019/9/9.
//  Copyright © 2019 姚威. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YWServiceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_subclassing_restricted))
@interface YWServiceManager : NSObject
/**
 获取全局唯一的对象

 @return 对象
 */
+ (instancetype)sharedInstance;
/**
 获取遵守YWServiceProtocol的对象

 @param className 类型
 @return 对象
 */
- (id<YWServiceProtocol>)serviceWithClass:(NSString *)className;
/**
 释放一些对象
 */
- (void)deallocStorage;
@end

NS_ASSUME_NONNULL_END
