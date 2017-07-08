//
//  RecordViewController.m
//  RecordScreen
//
//  Created by ispeak on 2017/4/24.
//  Copyright © 2017年 ydd. All rights reserved.
//

#import "RecordViewController.h"
#import "BarrageView.h"
#import "ScreenRecordView.h"
#import <ReplayKit/ReplayKit.h>
#import "PlayerView.h"

@interface RecordViewController ()<RPPreviewViewControllerDelegate, PlayerViewDelegate>

@property (nonatomic, strong) BarrageView *barrageView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) ScreenRecordView *screenRecordView;
@property (nonatomic, strong) UIButton *recordBtn;
@property (nonatomic, strong) PlayerView *playerView;
@end

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _barrageView = [[BarrageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 200)];
    _barrageView.maxLineCount = 5;
    _barrageView.isUniform = YES;
    [self.view addSubview:_barrageView];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setFrame:CGRectMake(20, 100, 80, 50)];
    button.center = CGPointMake(ScreenWidth / 2.0, ScreenHeight - 100);
    [button setTitle:@"开始录制" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(recordAction:) forControlEvents:UIControlEventTouchUpInside];
    _recordBtn = button;
    [self.view addSubview:_recordBtn];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSArray *nameArray = @[@"特朗普", @"四星上将", @"君莫笑",@"一叶知秋", @"景甜", @"包子入侵"];
        
        NSArray *contentArray = @[@"特朗普当选总统后关于酷刑的看法有所改观", @"包括３３名四星上将在内", @"赞",@"他们写道", @"合法、以和谐为基础的审讯手段是获取情报的最佳方式", @"一包烟和两瓶啤酒"];
        int count = arc4random() % contentArray.count;
        int nameCount = arc4random() % nameArray.count;
        PriaseSendStructure *model = [[PriaseSendStructure alloc] init];
        model.username = [nameArray objectAtIndex:nameCount];
        model.content = [contentArray objectAtIndex:count];
        model.imagePathStr = @"0.jpg";
        model.rankCustom = 150;
        [_barrageView sendBarrageForPraise:model];
    }];
    
    
    _screenRecordView = [[ScreenRecordView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _screenRecordView.recordView = self.view;//_recordBgView;
    _screenRecordView.hidden = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:self.screenRecordView];
    
    __weak RecordViewController *weakself = self;
    self.screenRecordView.hiddenRecordView = ^(BOOL isHidden) {
        weakself.screenRecordView.hidden = YES;
        weakself.recordBtn.hidden = NO;
    };
    
    self.screenRecordView.finishRecord = ^(NSString *videoPath) {
        weakself.screenRecordView.hidden = YES;
        weakself.recordBtn.hidden = NO;
        [weakself playerView:videoPath];
       
    };
    
    self.screenRecordView.replayKitFinish = ^(RPPreviewViewController * previewViewController, NSError *error){
        if (error) {
            
        } else {
            if (previewViewController) {
                previewViewController.previewControllerDelegate = weakself;
                [weakself presentViewController:previewViewController animated:YES completion:nil];
            }
        }
    };
}


- (void)playerView:(NSString *)videoPath
{
    self.playerView = [[PlayerView alloc] initWithFrame:self.view.bounds ForVideoPath:videoPath];
    self.playerView.delegate = self;
    [self.view addSubview:self.playerView];
    
    [self.playerView startPlayer];
}

- (void)clasePlayer
{
    [_playerView removeFromSuperview];
    _playerView = nil;
}

- (void)previewController:(RPPreviewViewController *)previewController didFinishWithActivityTypes:(NSSet<NSString *> *)activityTypes
{
//    NSLog(@" activityTypes = %@", activityTypes);
}

- (void)previewControllerDidFinish:(RPPreviewViewController *)previewController
{
    [previewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)recordAction:(id)send
{
    self.screenRecordView.hidden = NO;
    [self.screenRecordView hiddenAnimo:NO];
    _recordBtn.hidden = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
