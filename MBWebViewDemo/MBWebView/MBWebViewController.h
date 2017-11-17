//
//  MBWebViewController.h
//  MBWebViewControllerDemo
//
//  Created by ZhangXiaofei on 2017/11/16.
//  Copyright © 2017年 Mario. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface MBWebMessage : NSObject
// 交互方法名
@property (nonatomic, copy) NSString *methodName;
// 交互回调参数
@property (nonatomic, copy) NSDictionary *params;
// 交互回调JS方法
@property (nonatomic, copy) NSString *callbackMethod;

@end

@implementation MBWebMessage

@end


// 交互方法名
#define METHODNAMEKEY @"methodName"
// 交互回调参数
#define PARAMSKEY     @"params"
// 交互回调方法
#define CALLBACKMETHODKEY  @"callbackMethod"

@interface MBWebViewController : UIViewController <WKScriptMessageHandler>
// 自定义返回图标
@property (nonatomic, strong) UIImage *backImg;
// 自定义返回标题
@property (nonatomic, copy) NSString *backTitle;
// webView
@property (nonatomic, strong) WKWebView *webView;
// 进度条开关  默认NO
@property (nonatomic, assign) BOOL hiddeProgressView;
// 进度条颜色
@property (nonatomic, strong) UIColor *progressViewTintColor;
// 回调消息体
@property (nonatomic, strong, readonly) MBWebMessage *message;

// 初始化WebViewController加载文件或网络地址
- (instancetype)initWithURLString:(NSString *)urlString;

- (instancetype)initWithURL:(NSURL *)url;

- (instancetype)initWithRequest:(NSURLRequest *)request;

- (instancetype)initWithHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;

// 子类继承实现
// 注册JS交互回调
- (void)registerMessageHandler;
- (void)registerUserDefinedMessageHandlerName:(NSString *)name callBack:(void(^)(WKScriptMessage *message))callBack;
- (void)registerUserDefinedMessageHandlerNames:(NSArray *)names callBack:(void(^)(WKScriptMessage *message))callBack;
// 调用JS方法
- (void)callJSMethod:(NSString *)argumentsJson completionHandler:(void (^)(id response, NSError *error))completionHandler;
// 处理JS交互回调
- (BOOL)dealWithMessage:(WKScriptMessage *)message;

@end
