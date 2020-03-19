//
//  ViewController.m
//  TMNetworkHelper
//
//  Created by Apple on 2017/10/10.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "ViewController.h"
#import "TMNetworkHelper.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
//    [TMNetworkHelper GET:@"https://api.map.baidu.com/location/ip" parameters:nil success:^(id responseObject) {
//        NSLog(@"获取的数据---%@",responseObject);
//        
//    } failure:^(NSError *error) {
//        
//    }];
    [TMNetworkHelper GET:@"https://api.map.baidu.com/location/ip" parameters:nil responseCache:^(id responseCache) {
        NSLog(@"缓存数据---%@",responseCache);
    } success:^(id responseObject) {
        NSLog(@"成功数据---%@",responseObject);
    } failure:^(NSError *error) {
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
