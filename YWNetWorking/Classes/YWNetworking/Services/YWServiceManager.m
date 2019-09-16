//
//  YWServiceManager.m
//  YWNetworkingExamples
//
//  Created by Mr.Yao on 2019/9/9.
//  Copyright © 2019 姚威. All rights reserved.
//

#import "YWServiceManager.h"

@interface YWServiceManager ()

@property (nonatomic, strong) NSMutableDictionary *serviceStorage;

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
    if (self.serviceStorage[identifier] == nil) {
        self.serviceStorage[identifier] = [NSClassFromString(className) new];
    }
    return self.serviceStorage[identifier];
}
- (void)deallocStorage{
    [self.serviceStorage removeAllObjects];
    self.serviceStorage = nil;
}
- (NSMutableDictionary *)serviceStorage{
    if (_serviceStorage == nil) {
        _serviceStorage = [[NSMutableDictionary alloc] init];
    }
    return _serviceStorage;
}
@end
