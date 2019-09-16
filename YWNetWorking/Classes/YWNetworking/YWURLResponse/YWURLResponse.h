//
//  YWURLResponse.h
//  YWNetworkingExamples
//
//  Created by Mr.Yao on 2019/9/10.
//  Copyright © 2019 姚威. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YWURLResponse : NSObject
@property (nonatomic, assign, readonly) NSInteger status;
@property (nonatomic, copy,   readonly) id content;
@property (nonatomic, assign, readonly) NSInteger requestId;
@property (nonatomic, strong, readonly) NSString *userInformation;
@property (nonatomic, assign, readonly) BOOL isCache;
//默认YES
@property (nonatomic, assign,  readonly) BOOL isCallAction;
@property (nonatomic, copy,    readonly) NSDictionary *_Nullable requestParams;
@property (nonatomic, assign           ) BOOL needLogin;
@property (nonatomic, assign           ) BOOL refreshToken;


- (instancetype)initWithResponseObject:(id)responseObject
                               request:(NSURLRequest *)request
                             requestId:(NSNumber *)requestId
                       userInformation:(NSString *)userInformation
                            callStatus:(id)callStatus
                                 error:(NSError *)error;
+ (instancetype)getObjWithData:(NSData *)responseData;
@end

NS_ASSUME_NONNULL_END
