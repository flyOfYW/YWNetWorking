//
//  YWDemoApi.m
//  YWNetWorking_Example
//
//  Created by Mr.Yao on 2019/9/17.
//  Copyright © 2019 flyOfYW. All rights reserved.
//

#import "YWDemoApi.h"

@implementation YWDemoApi

- (YWAPIRequestType)requestType{
    return YWAPIRequestTypeGet;
}
- (NSString *)requestAddress{
    return @"2/statuses/unread_friends_timeline?gsid=_2A25weym0DeRxGeNH7VEW-SnFzD-IHXVRETp8rDV6PUJbkdAKLXPYkWpNSoP5xBW5qUSBQAcIf777yHz3N7MSpviR&sensors_mark=0&wm=3333_2001&sensors_is_first_day=false&from=1098493010&b=0&c=iphone&networktype=wifi&skin=default&v_p=76&v_f=1&s=e34a5e80&sensors_device_id=27A1949B-BF4E-494A-9AFC-0917280D3C59&lang=zh_CN&sflag=1&ua=iPhone9,1__weibo__9.8.4__iphone__os13.0&ft=11&aid=01AngspwM-eumWwlXSJGCLBTREwKhEL6AGS-v5kfOpKwoWjls.&cum=A41B5798";
}
/**
 使用哪个管理类

 @return 管理类
 */
- (NSString *)serviceClassName{
    return @"YWBaseService";
}
@end
