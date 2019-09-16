//
//  NSURLRequest+YWNetParams.h
//  YWNetworkingExamples
//
//  Created by Mr.Yao on 2019/9/12.
//  Copyright © 2019 姚威. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface NSURLRequest (YWNetParams)
@property (nonatomic, copy) NSDictionary * _Nullable requestParams;
@end

NS_ASSUME_NONNULL_END
