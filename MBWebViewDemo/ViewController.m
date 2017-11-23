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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    MBWebViewController *vc = [[MBWebViewController alloc] initWithURLString:@"https://www.baidu.com"];
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
