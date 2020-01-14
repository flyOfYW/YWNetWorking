//
//  YWCacheCenter.h
//  YWNetworkingExamples
//
//  Created by Mr.Yao on 2019/9/12.
//  Copyright © 2019 姚威. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YWURLResponse;
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSUInteger, YWCacheType){
    YWCacheTypeDefalut = 0,//不需要缓存
    YWCacheTypeMemory = 1 ,//NSCache
};

@interface YWCacheCenter : NSObject
+ (instancetype)sharedInstance;
+ (nullable YWURLResponse *)findCache:(YWCacheType)cacheType withKey:(NSString *)key;
+ (void)saveRespone:(nonnull YWURLResponse *)respone cache:(YWCacheType)cacheType withKey:(NSString *)key;
+ (void)removeCacheForKey:(NSString *)key cache:(YWCacheType)cacheType;
- (void)cleanAllData;
@end

NS_ASSUME_NONNULL_END
