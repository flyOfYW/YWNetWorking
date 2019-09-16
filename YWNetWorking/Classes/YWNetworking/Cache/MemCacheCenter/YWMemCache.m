//
//  YWMemCache.m
//  YWNetworkingExamples
//
//  Created by Mr.Yao on 2019/9/12.
//  Copyright © 2019 姚威. All rights reserved.
//

#import "YWMemCache.h"
#import "YWConfigure.h"
#import "YWURLResponse.h"

@interface YWMemCache ()

@property (nonatomic, strong) NSCache *cache;

@end

@implementation YWMemCache


- (nullable YWURLResponse *)findCachedRecordWithKey:(nonnull NSString *)key{
    NSData *cacheData = [self.cache objectForKey:key];
    return [YWURLResponse getObjWithData:cacheData];
}
- (void)saveRespone:(nonnull YWURLResponse *)respone withKey:(NSString *)key{
    if (respone.content) {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:respone.content options:0 error:&error];
        if (!error) {
            [self removeCacheForKey:key];
            [self.cache setValue:data forKey:key];
        }
    }
}
- (void)cleanAllData{
    [self.cache removeAllObjects];
}
- (void)removeCacheForKey:(NSString *)key{
    [self.cache removeObjectForKey:key];
}
- (NSCache *)cache{
    if (_cache == nil) {
        _cache = [[NSCache alloc] init];
        _cache.countLimit = [[YWConfigure sharedInstance] countLimit];
    }
    return _cache;
}

@end
