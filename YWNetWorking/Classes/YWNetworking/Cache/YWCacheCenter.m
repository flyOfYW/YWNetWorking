//
//  YWCacheCenter.m
//  YWNetworkingExamples
//
//  Created by Mr.Yao on 2019/9/12.
//  Copyright © 2019 姚威. All rights reserved.
//

#import "YWCacheCenter.h"
#import "YWMemCache.h"

@interface YWCacheCenter ()

@property (nonatomic, strong) YWMemCache *memoryCache;

@end

@implementation YWCacheCenter

+ (instancetype)sharedInstance{
    static YWCacheCenter *cacheCenter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cacheCenter = [[YWCacheCenter alloc] init];
    });
    return cacheCenter;
}

+ (nullable YWURLResponse *)findCache:(YWCacheType)cacheType withKey:(NSString *)key{
    if (cacheType == YWCacheTypeMemory) {
       return [[YWCacheCenter sharedInstance].memoryCache findCachedRecordWithKey:key];
    }
    return nil;
}
+ (void)saveRespone:(nonnull YWURLResponse *)respone cache:(YWCacheType)cacheType withKey:(NSString *)key{
    if (cacheType == YWCacheTypeMemory) {
        [[YWCacheCenter sharedInstance].memoryCache saveRespone:respone withKey:key];
    }
}
- (void)cleanAllData{
    [self.memoryCache cleanAllData];
}
+ (void)removeCacheForKey:(NSString *)key cache:(YWCacheType)cacheType{
    if (cacheType == YWCacheTypeMemory) {
        [[YWCacheCenter sharedInstance].memoryCache removeCacheForKey:key];
    }
}
- (YWMemCache *)memoryCache{
    if (_memoryCache == nil) {
        _memoryCache = [[YWMemCache alloc] init];
    }
    return _memoryCache;
}
@end
