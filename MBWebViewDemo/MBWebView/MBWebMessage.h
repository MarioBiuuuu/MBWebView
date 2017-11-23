//
//  MBWebMessage.h
//  MBWebViewDemo
//
//  Created by ZhangXiaofei on 2017/11/23.
//  Copyright © 2017年 Mario. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MBWebMessage : NSObject
// 交互方法名
@property (nonatomic, copy) NSString *methodName;
// 交互回调参数
@property (nonatomic, copy) NSDictionary *params;
// 交互回调JS方法
@property (nonatomic, copy) NSString *callbackMethod;

@end
