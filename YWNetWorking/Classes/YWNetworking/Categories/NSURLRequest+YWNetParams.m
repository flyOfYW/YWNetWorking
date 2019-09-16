//
//  NSURLRequest+YWNetParams.m
//  YWNetworkingExamples
//
//  Created by Mr.Yao on 2019/9/12.
//  Copyright © 2019 姚威. All rights reserved.
//

#import "NSURLRequest+YWNetParams.h"
#import <objc/runtime.h>

static void *YWNetworkingRequestParams = &YWNetworkingRequestParams;

@implementation NSURLRequest (YWNetParams)
- (void)setRequestParams:(NSDictionary *)requestParams{
    objc_setAssociatedObject(self, YWNetworkingRequestParams, requestParams, OBJC_ASSOCIATION_COPY);
}
- (NSDictionary *)requestParams{
    return objc_getAssociatedObject(self, YWNetworkingRequestParams);
}
@end
