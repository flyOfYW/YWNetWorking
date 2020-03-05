//
//  YWConfigure.m
//  YWNetworkingExamples
//
//  Created by Mr.Yao on 2019/9/9.
//  Copyright © 2019 姚威. All rights reserved.
//

#import "YWConfigure.h"
#import "YWApiNetStatus.h"
#import "YWServiceManager.h"
#import "YWApiAFAction.h"
#import "YWCacheCenter.h"

@interface YWConfigure ()
@end


@implementation YWConfigure

static YWConfigure *sharedInstance;

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super allocWithZone:NULL] init];
        sharedInstance.netError = @"网络似乎不畅通!";
    });
    return sharedInstance;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    return [YWConfigure sharedInstance];
}
+ (NSString *)version{
    return @"0.1.14";
}
+ (void)clearMemory{
    [[YWServiceManager sharedInstance] deallocStorage];
    [[YWApiAFAction sharedInstance] deallocDispatchTable];
    [[YWCacheCenter sharedInstance] cleanAllData];
}
- (id)copyWithZone:(NSZone *)zone{
    return self;
}
- (void)setAutoCheckNet:(BOOL)autoCheckNet{
    _autoCheckNet = autoCheckNet;
    if (autoCheckNet) {
        [[YWApiNetStatus sharedInstance] startMonitoring];
    }
}

@end
