//
//  ViewController.m
//  MBWebViewDemo
//
//  Created by ZhangXiaofei on 2017/11/16.
//  Copyright © 2017年 Mario. All rights reserved.
//

#import "ViewController.h"
#import "MBWebViewController.h"

@interface ViewController ()
@property (nonatomic, strong) MBWebViewController *webVC;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"Temp01" ofType:@"html"];
    NSString *htmlCont = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    __weak __typeof(self)weakSelf = self;
    self.webVC = [[MBWebViewController alloc] initWithHTMLString:htmlCont baseURL:baseURL handlerName:@"functionMessagehandler" callBack:^(WKScriptMessage *message) {
        NSLog(@"1233333");
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if ([message.name isEqualToString:@"functionMessagehandler"] && [strongSelf.webVC.message.methodName isEqualToString:@"function"]) {
            if (strongSelf.webVC.message.callbackMethod.length > 0) {
               //callback js
            }
        }
        [strongSelf.webVC callJSMethod:@"123123128737129" completionHandler:^(id response, NSError *error) {
            NSLog(@"%@", error.localizedDescription);
        }];
        
    }];
    self.webVC.noBoundces = NO;
    [self.navigationController pushViewController:self.webVC animated:YES];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
