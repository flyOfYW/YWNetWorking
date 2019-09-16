//
//  YWMemCache.h
//  YWNetworkingExamples
//
//  Created by Mr.Yao on 2019/9/12.
//  Copyright © 2019 姚威. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YWURLResponse;

NS_ASSUME_NONNULL_BEGIN

@interface YWMemCache : NSObject
- (nullable YWURLResponse *)findCachedRecordWithKey:(nonnull NSString *)key;
- (void)saveRespone:(nonnull YWURLResponse *)respone withKey:(NSString *)key;
- (void)cleanAllData;
- (void)removeCacheForKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
