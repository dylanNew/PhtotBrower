//
//  ViewController.m
//  PhotoBrower
//
//  Created by udspj on 14-10-28.
//  Copyright (c) 2014年 wangdi. All rights reserved.
//

#import "ViewController.h"
#import "PhotoBrowerViewController.h"

@interface ViewController ()<PhotoBrowerViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)showPhotoBrowerVC:(id)sender
{
    NSArray *imageArray = @[@"http://rongyi.b0.upaiyun.com/system/app_content/picture/266/201408201443141921.jpg",
                            @"http://rongyi.b0.upaiyun.com/system/app_content/picture/266/201408201443111658.jpg",
                            @"http://rongyi.b0.upaiyun.com/system/app_content/picture/266/201408201408362917.jpg",
                            @"http://rongyi.b0.upaiyun.com/system/app_content/picture/266/201408201408325958.jpg"];
    PhotoBrowerViewController *vc = [[PhotoBrowerViewController alloc] initWIthDataSource:imageArray andCurrentPage:0];
    [vc setDelegate:self];
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

- (void)phototBrowerShareBtnDidClick:(PhotoBrowerViewController *)photoVC object:(NSString *)obj
{
    //分享相关
}

@end
