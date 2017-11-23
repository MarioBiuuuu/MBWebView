//
//  MBWebHandlerObj.h
//  MBWebViewDemo
//
//  Created by ZhangXiaofei on 2017/11/23.
//  Copyright © 2017年 Mario. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBWebHandlerObj : NSObject
@property (nonatomic, copy) NSString *handlerName;
@property (nonatomic, copy) id callBackBlock;
@end
