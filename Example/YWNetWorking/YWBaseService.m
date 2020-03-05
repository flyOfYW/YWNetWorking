//
//  YWBaseService.m
//  YWNetWorking_Example
//
//  Created by Mr.Yao on 2019/9/17.
//  Copyright © 2019 flyOfYW. All rights reserved.
//



#import "YWBaseService.h"

@interface YWBaseService ()

@property (nonatomic, strong) AFHTTPRequestSerializer *requestSerializer;

@property (nonatomic,   copy) NSString *baseURL;

@end


@implementation YWBaseService

/**
 * 该类遵守协议，并且实现协议的方法，更灵活
 * 比如，统一设置一些公钥或者验签
 */

//- (NSURLRequest *)requestWithMethod:(YWAPIRequestType)requestType URLString:(NSString *)urlString parameters:(id)parameters{
//    NSURLRequest *request = nil;
//    NSMutableDictionary *par = [NSMutableDictionary new];
//    [par setValue:[self publicKey] forKey:@"apikey"];
//    if (parameters) {
//        [par addEntriesFromDictionary:parameters];
//    }
//    switch (requestType) {
//        case YWAPIRequestTypeGet:
//            request = [self.requestSerializer requestWithMethod:@"GET" URLString:[NSString stringWithFormat:@"%@%@",self.baseURL,urlString] parameters:par error:nil];
//            break;
//
//        default:
//            break;
//    }
//    return request;
//}
//- (NSString *)publicKey{
//    return @"d99fa506c7cdf209261f6652";
//}

- (NSURLRequest *)requestWithMethod:(YWAPIRequestType)requestType URLString:(NSString *)urlString parameters:(id)parameters{
    NSURLRequest *request = nil;
    switch (requestType) {
        case YWAPIRequestTypeGet:
            request = [self.requestSerializer requestWithMethod:@"GET" URLString:[NSString stringWithFormat:@"%@%@",self.baseURL,urlString] parameters:parameters error:nil];
            break;
        case YWAPIRequestTypePut:
            request = [self.requestSerializer requestWithMethod:@"PUT" URLString:[NSString stringWithFormat:@"%@%@",self.baseURL,urlString] parameters:parameters error:nil];
            break;
        case YWAPIRequestTypePost:
            request = [self.requestSerializer requestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"%@%@",self.baseURL,urlString] parameters:parameters error:nil];
            break;
            
        default:
            break;
    }
    return request;
}
- (AFHTTPSessionManager *)sessionManager{
    return [AFHTTPSessionManager manager];
}
/**
 更灵活的环境配置
 
 @return 环境
 */
- (YWServiceAPIEnvironment)apiEnvironment{
    return YWServiceAPIEnvironmentDevelop;
}
- (NSString *)baseURL{
    if (self.apiEnvironment == YWServiceAPIEnvironmentDevelop) {//开放环境
        return @"https://api.weibo.cn/";
    }else if (self.apiEnvironment == YWServiceAPIEnvironmentRelease){//正式环境
        return @"https://api.weibo.cn/";
    }else {//备用环境
        return @"https://api.weibo.cn/";
    }
}

/**
 *字典的格式
 key:YWTApiValidateResultKeyResponseObject|YWTApiValidateResultKeyResponseUserInfomation|YWTApiValidateResultKeyResponseObject:可选
 */

- (NSDictionary *)resultWithResponseObject:(id)responseObject request:(NSURLRequest *)request response:(NSURLResponse *)response error:(NSError *)error{
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    if (error) {
        
        NSHTTPURLResponse * httpRespone = (NSHTTPURLResponse *)response;
        
        if (httpRespone.statusCode == 401) {//需要登录
            dict[YWApiValidateResultKeyNSNotificationLogin] = @(YES);
            //或者需要刷新token
            //            dict[YWApiValidateResultKeyNSNotificationRefrenToken] = @(YES);
        }
        return dict;
    }
    
    //写接口的工程师，可以选择性处理，如下的例子
    
    //{code:0,date:[],msg:操作成功}|{code:0,data:{},msg:操作成功}|{code:1,data:null,msg:未登录}|{code:2,data:null,msg:参数有误}
    
    //    if ([responseObject[@"code"] isEqual:@1]) {//需要登录
    //        dict[YWApiValidateResultKeyNSNotificationLogin] = @(YES);//只需要监听通知，key：YWApiValidateResultKeyNSNotificationLogin
    //    }else if ([responseObject[@"code"] isEqual:@2]){
    //        /*框架内部实现，控制回调的去向，因为可能业务工程师不需要关注api内部过多的逻辑，
    //        他只需要知道成功和失败即可，类似code=2，也是失败，所以写接口的工程师，可以控制的回调，根据需要选吧
    //        */
    //        dict[YWApiValidateResultKeyResponseCallStatus] = @(NO);//NO-代表，走失败的回调（- (void)managerCallAPIDidFailed:(nonnull YWBaseApiManager *)manager）
    //        //同时支持设置界面的提示语
    //        dict[YWApiValidateResultKeyResponseUserInfomation] = responseObject[@"msg"];
    //    }else{
    //        dict[YWApiValidateResultKeyResponseObject] = responseObject[@"data"];
    //    }
    //
    
    //当前的数据
    dict[YWApiValidateResultKeyResponseObject] = responseObject;
    return dict;
    
}
- (AFHTTPRequestSerializer *)requestSerializer{
    if (!_requestSerializer) {
        _requestSerializer = [AFJSONRequestSerializer serializer];
    }
    return _requestSerializer;
}

@end
