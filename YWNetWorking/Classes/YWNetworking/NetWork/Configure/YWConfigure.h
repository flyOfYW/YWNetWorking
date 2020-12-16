//
//  YWConfigure.h
//  YWNetworkingExamples
//
//  Created by Mr.Yao on 2019/9/9.
//  Copyright © 2019 姚威. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
__attribute__((objc_subclassing_restricted))
@interface YWConfigure : NSObject<NSCopying>
/**
 * 控制台日志开关，默认不开启
 */
@property (nonatomic, assign) BOOL consolelogEnable;
/**
 * 网络状态检测，是否自动开启，默认NO
 */
@property (nonatomic, assign) BOOL autoCheckNet;

/**
 启用检测手机网络是否设置代理，当检测到设置了代理，
 1：刚请求时，会直接取消请求，返回请求失败，
 2：请求成功时，数据未到业务层时，此时检测到，则会不回调数据给业务层，返回请求失败
 */
@property (nonatomic, assign) BOOL autoProxyStatus;

/**
 * 网络状态有误的提示，供内部使用,默认"网络似乎不畅通!"
 */
@property (nonatomic,   copy) NSString *netError;
/**
 * 当请求成功的时候，如果需要缓存，缓存的个数
 */
@property (nonatomic,   assign) NSUInteger countLimit;
/**
 获取全局唯一的对象
 
 @return 对象
 */
+ (instancetype)sharedInstance;
/**
 获取当前库的版本号

 @return 版本号
 */
+ (NSString *)version;
/**
 外部收到内存警告的时候，可以使用此方法释放一些框架内部持有的对象(可以在AppDelegate中监听applicationDidReceiveMemoryWarning)
 */
+ (void)clearMemory;

@end

NS_ASSUME_NONNULL_END
