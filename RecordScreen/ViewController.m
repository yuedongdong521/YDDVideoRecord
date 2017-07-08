//
//  ViewController.m
//  RecordScreen
//
//  Created by ispeak on 2017/4/24.
//  Copyright © 2017年 ydd. All rights reserved.
//

#import "ViewController.h"
#import "RecordViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(0, 0, 100, 50);
    button.center = CGPointMake(ScreenWidth / 2.0, ScreenHeight - 100);
    [button setTitle:@"ScreenRecord" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(pushRecordVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}


- (void)pushRecordVC
{
    RecordViewController *VC = [[RecordViewController alloc] init];
    VC.view.backgroundColor = [UIColor whiteColor];
    [self presentViewController:VC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
