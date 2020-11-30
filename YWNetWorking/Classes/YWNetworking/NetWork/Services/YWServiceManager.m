//
//  YWServiceManager.m
//  YWNetworkingExamples
//
//  Created by Mr.Yao on 2019/9/9.
//  Copyright © 2019 姚威. All rights reserved.
//

#import "YWServiceManager.h"

@interface YWServiceManager ()
@property (nonatomic, strong) NSCache *serviceStorage;
@end

@implementation YWServiceManager
+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static YWServiceManager *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[YWServiceManager alloc] init];
    });
    return sharedInstance;
}
- (id<YWServiceProtocol>)serviceWithClass:(NSString *)className{
    NSString *identifier = [NSString stringWithFormat:@"identifier_%@",className];
    id <YWServiceProtocol>obj = [self.serviceStorage objectForKey:identifier];
    if ( obj == nil) {
         obj = [NSClassFromString(className) new];
        [self.serviceStorage setObject:obj forKey:identifier];
    }
    return obj;
}
- (NSCache *)serviceStorage{
    if (_serviceStorage == nil) {
        _serviceStorage = [[NSCache alloc] init];
    }
    return _serviceStorage;
}
- (void)deallocStorage{
    [self.serviceStorage removeAllObjects];
    self.serviceStorage = nil;
}

@end
