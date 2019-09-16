//
//  YWLogManager.m
//  YWNetworkingExamples
//
//  Created by Mr.Yao on 2019/9/11.
//  Copyright © 2019 姚威. All rights reserved.
//

#import "YWLogManager.h"
#import "YWConfigure.h"


@interface NSMutableString (Request)
- (void)appendRequest:(NSURLRequest *)request;
@end

@implementation NSMutableString (Request)
- (void)appendRequest:(NSURLRequest *)request{
    [self appendFormat:@"Method：\t\t%@\n\n",request.HTTPMethod];
    [self appendFormat:@"HTTP URL：\t%@\n\n",request.URL];
    [self appendFormat:@"HTTP Header：\n\t%@\n\n",request.allHTTPHeaderFields ? request.allHTTPHeaderFields : @"\t\t\t\t\tN/A"];
    NSData *data = request.HTTPBody;
    if (data && data.length > 0) {
        NSString *bodyString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self appendFormat:@"HTTP Body：\n\t%@\n",bodyString];
    }
}
@end

@implementation YWLogManager

+ (NSString *)logDebugInfoWithRetryApiName:(NSString *)apiName retryCount:(NSInteger)retryCount{
    NSMutableString *logString = nil;
    
    if ([YWConfigure sharedInstance].consolelogEnable) {
        logString = [[NSMutableString alloc] initWithString:@"\n\n*********************** 重试 请求 *****************************\n\n"];
        [logString appendFormat:@"api address：\t%@\n\n",apiName];
        [logString appendFormat:@"api retry count：\t%zi\n\n",retryCount];
        [logString appendFormat:@"\n***************************** 重试 end ***************************\n"];
        NSLog(@"%@", logString);
    }
    return logString;
}

+ (NSString *)logDebugInfoWithResponse:(NSHTTPURLResponse *)response responseObject:(id)responseObject request:(NSURLRequest *)request error:(NSError *)error{
    
    NSMutableString *logString = nil;
    
    if ([YWConfigure sharedInstance].consolelogEnable) {
        
        BOOL isSuccess = error ? NO : YES;
        
        logString = [[NSMutableString alloc] initWithString:@"\n\n*********************** API response *****************************\n\n"];
        
        [logString appendFormat:@"Request URL:\n\t%@\n\n", request.URL];
        
        [logString appendFormat:@"Response Status:\n\t%zi\n\n", response.statusCode];
        
        if (isSuccess) {
            [logString appendFormat:@"Response content:\n\t%@\n\n", responseObject];
        }else{
            [logString appendFormat:@"\n\n************************* 错误描述 ❌ *****************************\n\n"];
            [logString appendFormat:@"Error Domain:\t\t\t\t\t\t\t%@\n", error.domain];
            [logString appendFormat:@"Error Domain Code:\t\t\t\t\t\t%ld\n", (long)error.code];
            [logString appendFormat:@"Error Localized Description:\t\t\t%@\n", error.localizedDescription];
            [logString appendFormat:@"Error Localized Failure Reason:\t\t\t%@\n", error.localizedFailureReason];
            [logString appendFormat:@"Error Localized Recovery Suggestion:\t%@\n\n", error.localizedRecoverySuggestion];
            [logString appendRequest:request];
        }
        [logString appendFormat:@"\n***************************** API response end ***************************\n"];
        NSLog(@"%@", logString);

    }
    
    return logString;
    
}

+ (NSString *)logDebugInfoWithRequest:(NSURLRequest *)request
                              apiName:(NSString *)apiName
                              service:(id<YWServiceProtocol>)service{
    NSMutableString *logString = nil;
    
    if ([YWConfigure sharedInstance].consolelogEnable) {
        NSString *apiEnvironment = nil;
        switch (service.apiEnvironment) {
            case YWServiceAPIEnvironmentDevelop:
                apiEnvironment = @"Develop";
                break;
            case YWServiceAPIEnvironmentRelease:
                apiEnvironment = @"Release";
                break;
            default:
                apiEnvironment = @"Spare Release";
                break;
        }
        logString = [[NSMutableString alloc] initWithString:@"\n\n*********************** send request message *****************************\n\n"];
        [logString appendFormat:@"api apiEnvironment：\t%@\n\n",apiEnvironment];
        [logString appendFormat:@"api address：\t%@\n\n",apiName];
        [logString appendRequest:request];
        [logString appendFormat:@"\n***************************** request end ***************************\n"];
        NSLog(@"%@", logString);
    }
    
    return logString;
}
@end

