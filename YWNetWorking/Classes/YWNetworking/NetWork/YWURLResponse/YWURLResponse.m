//
//  YWURLResponse.m
//  YWNetworkingExamples
//
//  Created by Mr.Yao on 2019/9/10.
//  Copyright © 2019 姚威. All rights reserved.
//

#import "YWURLResponse.h"
#import "YWConfigure.h"
#import "NSURLRequest+YWNetParams.h"

@interface YWURLResponse ()
@property (nonatomic, assign, readwrite) NSInteger status;
@property (nonatomic, copy,   readwrite) id content;
@property (nonatomic, assign, readwrite) NSInteger requestId;
@property (nonatomic, strong, readwrite) NSString *userInformation;
@property (nonatomic, assign, readwrite) BOOL isCache;
//默认YES
@property (nonatomic, assign, readwrite) BOOL isCallAction;
@property (nonatomic, assign, readwrite) BOOL isCallSucessAction;

@property (nonatomic, copy,   readwrite) NSDictionary *requestParams;

@end



@implementation YWURLResponse


- (instancetype)initWithResponseObject:(id)responseObject
                               request:(NSURLRequest *)request
                             requestId:(NSNumber *)requestId
                       userInformation:(NSString *)userInformation
                            callStatus:(id)callStatus
                                 error:(NSError *)error{
    self = [super init];
    if (self) {
        self.content = responseObject;
        self.requestId = [requestId integerValue];
        self.userInformation = userInformation ? userInformation: [self responseStatusWithError:error];
        self.status = error ? error.code : 200;
        _isCallAction = YES;
        _isCallSucessAction = NO;
        if (callStatus) {
            _isCallAction = [callStatus[@"YWApiValidateResultKeyResponseCallStatus"] boolValue];
            _isCallSucessAction = [callStatus[@"YWApiValidateResultKeyFailCallStatus"] boolValue];
        }
        self.requestParams = request.requestParams;
    }
    return self;
}
+ (instancetype)getObjWithData:(NSData *)responseData{
    NSError *error = nil;
    if (!responseData) {
        return nil;
    }
    id cotent = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
    if (error) {
        return nil;
    }
    YWURLResponse *obj = [YWURLResponse new];
    obj.userInformation = @"成功";
    obj.status = 200;
    obj.content = cotent;
    obj.isCallAction = YES;
    obj.isCache = YES;
    obj.requestId = 0;
    return obj;
}
- (NSString *)responseStatusWithError:(NSError *)error{
    if (error) {
        if (error.code == NSURLErrorTimedOut) {
            return @"请求超时";
        }
        if (error.code == NSURLErrorCancelled) {
            return @"请求取消";
        }
        if (error.code == NSURLErrorNotConnectedToInternet) {
            return [YWConfigure sharedInstance].netError;
        }
    }
    return @"成功";
}

@end
