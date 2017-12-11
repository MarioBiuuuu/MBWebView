//
//  MBWebViewController.m
//  MBWebViewControllerDemo
//
//  Created by ZhangXiaofei on 2017/11/16.
//  Copyright © 2017年 Mario. All rights reserved.
//

#import "MBWebViewController.h"

// 回调名
static NSString *baseMessagehandler = @"baseMessagehandler";

// 系统操作方法
static NSString *closeWebView = @"closeWebView";
static NSString *goBack = @"goBack";

@interface MBWebViewController () <WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIBarButtonItem *backItem;
@property (nonatomic, strong) UIBarButtonItem *closeItem;
@property (nonatomic, assign) UIBarStyle barStyle;
@property (nonatomic, strong) UIView *errorView;
@property (nonatomic, assign) BOOL translucent;

@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, copy) NSString *htmlString;
@property (nonatomic, strong) NSURL *baseURL;

// 交互回调消息体
@property (nonatomic, strong) MBWebMessage *message;
//@property (nonatomic, copy) void (^userDefiendCallBack)(WKScriptMessage *message);
//@property (nonatomic, copy) NSString *userdefinedHandlerName;
// 存储注册JS交互
@property (nonatomic, strong) NSMutableDictionary *registersDict;


@end

@implementation MBWebViewController

#pragma mark - LifeCycle

- (void)dealloc {
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [_webView removeObserver:self forKeyPath:@"canGoBack"];
    [_webView removeObserver:self forKeyPath:@"title"];
}

- (instancetype)initWithURLString:(NSString *)urlString {
    self = [super init];
    if (self) {
        _urlString = urlString;
    }
    
    return self;
}

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        _url = url;
    }
    
    return self;
}

- (instancetype)initWithRequest:(NSURLRequest *)request {
    self = [super init];
    if (self) {
        _request = request;
    }
    
    return self;
}

- (instancetype)initWithHTMLString:(NSString *)string baseURL:(NSURL *)baseURL {
    self = [super init];
    if (self) {
        _htmlString = string;
        _baseURL = baseURL;
    }
    
    return self;
}

- (instancetype)initWithURLString:(NSString *)urlString handlerName:(NSString *)name callBack:(void(^)(WKScriptMessage *message))callBack {
    self = [super init];
    if (self) {
        self.registersDict[name] = callBack;
        _urlString = urlString;
    }
    
    return self;
}

- (instancetype)initWithURL:(NSURL *)url handlerName:(NSString *)name callBack:(void(^)(WKScriptMessage *message))callBack {
    self = [super init];
    if (self) {
        self.registersDict[name] = callBack;
        _url = url;
    }
    
    return self;
}

- (instancetype)initWithRequest:(NSURLRequest *)request handlerName:(NSString *)name callBack:(void(^)(WKScriptMessage *message))callBack {
    self = [super init];
    if (self) {
        self.registersDict[name] = callBack;
        _request = request;
    }
    
    return self;
}

- (instancetype)initWithHTMLString:(NSString *)string baseURL:(NSURL *)baseURL handlerName:(NSString *)name callBack:(void(^)(WKScriptMessage *message))callBack {
    self = [super init];
    if (self) {
        self.registersDict[name] = callBack;
        _htmlString = string;
        _baseURL = baseURL;
    }
    
    return self;
}

- (instancetype)initWithURLString:(NSString *)urlString multiHandlerNameAndCallBack:(NSArray<MBWebHandlerObj *> *)registerData {
    self = [super init];
    if (self) {
        for (MBWebHandlerObj *obj in registerData) {
            self.registersDict[obj.handlerName] = obj.callBackBlock;
        }
        _urlString = urlString;
    }
    
    return self;
}

- (instancetype)initWithURL:(NSURL *)url multiHandlerNameAndCallBack:(NSArray<MBWebHandlerObj *> *)registerData {
    self = [super init];
    if (self) {
        for (MBWebHandlerObj *obj in registerData) {
            self.registersDict[obj.handlerName] = obj.callBackBlock;
        }
        _url = url;
    }
    
    return self;
}

- (instancetype)initWithRequest:(NSURLRequest *)request multiHandlerNameAndCallBack:(NSArray<MBWebHandlerObj *> *)registerData {
    self = [super init];
    if (self) {
        for (MBWebHandlerObj *obj in registerData) {
            self.registersDict[obj.handlerName] = obj.callBackBlock;
        }
        _request = request;
    }
    
    return self;
}

- (instancetype)initWithHTMLString:(NSString *)string baseURL:(NSURL *)baseURL multiHandlerNameAndCallBack:(NSArray<MBWebHandlerObj *> *)registerData {
    self = [super init];
    if (self) {
        for (MBWebHandlerObj *obj in registerData) {
            self.registersDict[obj.handlerName] = obj.callBackBlock;
        }
        _htmlString = string;
        _baseURL = baseURL;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    for (NSString *name in self.registersDict.allKeys) {
        [self registerUserDefinedMessageHandlerName:name callBack:self.registersDict[name]];
    }
    
    [self registerMessageHandler];
    [self addObserver];
    [self loadPage];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.barStyle = self.navigationController.navigationBar.barStyle;
    self.translucent = self.navigationController.navigationBar.translucent;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barStyle = self.barStyle;
    self.navigationController.navigationBar.translucent = self.translucent;
}

#pragma mark - Getter
- (NSMutableDictionary *)registersDict {
    if (!_registersDict) {
        _registersDict = [NSMutableDictionary dictionary];
    }
    return _registersDict;
}

- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
        NSArray *viewControllers = self.navigationController.viewControllers;
        if (viewControllers.count > 1) {
            if ([viewControllers objectAtIndex:viewControllers.count - 1]==self) { //push方式
                _webView.frame = self.view.bounds;
            }
        } else { //present方式
            _webView.frame = CGRectMake(0, 20, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 20);
        }
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
    }
    
    return _webView;
}

- (void)setNoBoundces:(BOOL)noBoundces {
    _noBoundces = noBoundces;
    self.webView.scrollView.bounces = !noBoundces;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
        _progressView.tintColor = [UIColor greenColor];
        _progressView.trackTintColor = [UIColor clearColor];
        _progressView.hidden = YES;
    }
    
    return _progressView;
}

- (UIBarButtonItem *)backItem {
    if (!_backItem) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setImage:[UIImage imageNamed:@"MBCommonNav_back"] forState:UIControlStateNormal];
        [button setTitle:@"返回" forState:UIControlStateNormal];
        button.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 0);
        [button addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        _backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    
    return _backItem;
}

- (UIBarButtonItem *)closeItem {
    if (!_closeItem) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        button.titleEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 0);
        [button setTitle:@"关闭" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
        _closeItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    
    return _closeItem;
}

- (UIView *)errorView {
    if (!_errorView) {
        _errorView = [[UIView alloc] initWithFrame:self.view.bounds];
        _errorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _errorView.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refreshPage)];
        _errorView.userInteractionEnabled = YES;
        [_errorView addGestureRecognizer:gesture];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 140, 60)];
        [button setTitle:@"轻触重新加载" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(refreshPage) forControlEvents:UIControlEventTouchUpInside];
        button.center = _errorView.center;
        [_errorView addSubview:button];
    }
    
    return _errorView;
}

#pragma mark - Action
- (void)backAction {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    } else {
        [self closeSelf];
    }
}

- (void)closeSelf {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private
- (void)initUI {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = self.backItem;
    [self.view addSubview:self.webView];
    [self.view addSubview:self.progressView];
}

- (void)updateButtonItems {
    if (self.webView.canGoBack && self.navigationItem.leftBarButtonItems.count != 2) {
        self.navigationItem.leftBarButtonItems = @[self.backItem, self.closeItem];
    }
}

- (void)setErrorViewHidden:(BOOL)hidden {
    if (hidden) {
        [self.errorView removeFromSuperview];
    } else {
        [self.view addSubview:self.errorView];
    }
}

- (void)addObserver {
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.webView addObserver:self forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)loadPage {
    if (self.urlString.length > 0) {
        [self loadURLString:self.urlString];
    } else if (self.url) {
        [self loadURL:self.url];
    } else if (self.request) {
        [self loadRequest:self.request];
    } else if (self.htmlString.length > 0 || self.baseURL) {
        [self loadHTMLString:self.htmlString baseURL:self.baseURL];
    }
}

- (void)refreshPage {
    if (self.webView.URL) {
        [self.webView reload];
    } else {
        [self loadPage];
    }
}

- (void)hideProgress {
    self.progressView.hidden = YES;
    [self.progressView setProgress:0 animated:NO];
}

- (void)updateProgress:(float)progress {
    self.progressView.hidden = NO;
    [self.progressView setProgress:progress animated:YES];
}

- (void)loadURLString:(NSString *)urlString {
    [self loadURL:[NSURL URLWithString:urlString]];
}

- (void)loadURL:(NSURL *)url {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [self loadRequest:request];
}

- (void)loadRequest:(NSURLRequest *)request {
    [self.webView loadRequest:request];
}

- (void)loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL {
    [self.webView loadHTMLString:string baseURL:baseURL];
}

#pragma mark - Public
- (void)setHiddeProgressView:(BOOL)hiddeProgressView {
    _hiddeProgressView = hiddeProgressView;
    self.progressView.hidden = YES;
}

- (void)setProgressViewTintColor:(UIColor *)progressViewTintColor {
    _progressViewTintColor = progressViewTintColor;
    self.progressView.tintColor = progressViewTintColor;
}

- (void)setBackTitle:(NSString *)backTitle {
    _backTitle = backTitle;
    if (backTitle.length > 0) {
        self.navigationItem.leftBarButtonItem = nil;
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        if (self.backImg) {
            [button setImage:self.backImg forState:UIControlStateNormal];
        } else {
            [button setImage:[UIImage imageNamed:@"MBCommonNav_back"] forState:UIControlStateNormal];
        }
        [button setTitle:backTitle forState:UIControlStateNormal];
        button.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 0);
        [button addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        _backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.leftBarButtonItem = _backItem;
    }
}

- (void)setBackImg:(UIImage *)backImg {
    _backImg = backImg;
    if (backImg && [backImg isKindOfClass:[UIImage class]]) {
        self.navigationItem.leftBarButtonItem = nil;
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setImage:backImg forState:UIControlStateNormal];
        if (self.backTitle.length > 0) {
            [button setTitle:self.backTitle forState:UIControlStateNormal];
        } else {
            [button setTitle:@"返回" forState:UIControlStateNormal];
        }
        button.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 0);
        [button addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        _backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.leftBarButtonItem = _backItem;
        
    }
}

- (void)registerMessageHandler {
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:baseMessagehandler];
}

- (void)registerUserDefinedMessageHandlerName:(NSString *)name callBack:(void(^)(WKScriptMessage *message))callBack {
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:name];
}

- (BOOL)dealWithMessage:(WKScriptMessage *)message {
    BOOL canDeal = NO;
    if ([message.body isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)message.body;
        self.message = [[MBWebMessage alloc] init];
        self.message.methodName = dic[METHODNAMEKEY];
        self.message.params = dic[PARAMSKEY];
        self.message.callbackMethod = dic[CALLBACKMETHODKEY];
    }
    
    if ([message.name isEqualToString:baseMessagehandler]) {
        if ([self.message.methodName isEqualToString:closeWebView]) {
            [self closeSelf];
            canDeal = YES;
        } else if ([self.message.methodName isEqualToString:goBack]) {
            [self backAction];
            canDeal = YES;
        }
    } else {
        void (^userDefiendCallBack)(WKScriptMessage *message) = self.registersDict[message.name];
        
        if (userDefiendCallBack) {
            userDefiendCallBack(message);
        }
    }
    
    if (canDeal && self.message.callbackMethod.length > 0) {
        
    }
    
    return canDeal;
}

- (void)callJSMethod:(NSString *)argumentsJson completionHandler:(void (^)(id response, NSError *error))completionHandler {
    if (self.message.callbackMethod.length > 0) {
        NSString *jsonStr = (argumentsJson.length > 0 ? argumentsJson : @"");
        
        [self.webView evaluateJavaScript:[NSString stringWithFormat:@"%@('%@')",self.message.callbackMethod, jsonStr] completionHandler:^(id _Nullable response, NSError * _Nullable error) {
            
        }];
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.webView) {
        if ([keyPath isEqualToString:@"estimatedProgress"]) {
            CGFloat progress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
            if (progress == 1) {
                [self hideProgress];
            } else {
                [self updateProgress:progress];
            }
        } else if ([keyPath isEqualToString:@"canGoBack"]) {
            [self updateButtonItems];
        } else if ([keyPath isEqualToString:@"title"]) {
            self.title = self.webView.title;
        }
    }
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [self hideProgress];
    [self setErrorViewHidden:NO];
    self.title = @"加载失败";
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    webView.scrollView.bounces = !self.noBoundces;
    [self hideProgress];
    [self setErrorViewHidden:YES];
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [self dealWithMessage:message];
}

#pragma mark - WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alertVC addAction:confirmAction];
    [self presentViewController:alertVC animated:YES completion:nil];
    completionHandler();
}

@end

