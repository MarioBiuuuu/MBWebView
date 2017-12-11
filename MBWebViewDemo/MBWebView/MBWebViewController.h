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
#import "MBWebMessage.h"
#import "MBWebHandlerObj.h"

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
// 设置是否用弹簧效果
@property (nonatomic, assign) BOOL noBoundces;

// 初始化WebViewController加载文件或网络地址
- (instancetype)initWithURLString:(NSString *)urlString;

- (instancetype)initWithURL:(NSURL *)url;

- (instancetype)initWithRequest:(NSURLRequest *)request;

- (instancetype)initWithHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;

// 初始化WebViewController加载文件或网络地址 附带注册JS交互回调
- (instancetype)initWithURLString:(NSString *)urlString handlerName:(NSString *)name callBack:(void(^)(WKScriptMessage *message))callBack;

- (instancetype)initWithURL:(NSURL *)url handlerName:(NSString *)name callBack:(void(^)(WKScriptMessage *message))callBack;

- (instancetype)initWithRequest:(NSURLRequest *)request handlerName:(NSString *)name callBack:(void(^)(WKScriptMessage *message))callBack;

- (instancetype)initWithHTMLString:(NSString *)string baseURL:(NSURL *)baseURL handlerName:(NSString *)name callBack:(void(^)(WKScriptMessage *message))callBack;

// 初始化WebViewController加载文件或网络地址 附带注册多个JS交互回调
- (instancetype)initWithURLString:(NSString *)urlString multiHandlerNameAndCallBack:(NSArray<MBWebHandlerObj *> *)registerData;

- (instancetype)initWithURL:(NSURL *)url multiHandlerNameAndCallBack:(NSArray<MBWebHandlerObj *> *)registerData;

- (instancetype)initWithRequest:(NSURLRequest *)request multiHandlerNameAndCallBack:(NSArray<MBWebHandlerObj *> *)registerData;

- (instancetype)initWithHTMLString:(NSString *)string baseURL:(NSURL *)baseURL multiHandlerNameAndCallBack:(NSArray<MBWebHandlerObj *> *)registerData;

// 子类继承实现
// 注册JS交互回调
- (void)registerMessageHandler;

// 调用JS方法
- (void)callJSMethod:(NSString *)argumentsJson completionHandler:(void (^)(id response, NSError *error))completionHandler;

// 处理JS交互回调
- (BOOL)dealWithMessage:(WKScriptMessage *)message;

@end

