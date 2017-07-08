//
//  ScreenRecordView.m
//  ViewsTalk
//
//  Created by ispeak on 2017/4/10.
//  Copyright © 2017年 ywx. All rights reserved.
//

#import "ScreenRecordView.h"
#import "ScreenAudioRecorder.h"

#import <ReplayKit/ReplayKit.h>

#define maxTime 16.0

#define IsReplayKit NO

#define kViewX(view) view.frame.origin.x
#define kViewY(view) view.frame.origin.y
#define kViewW(view) view.frame.size.width
#define kViewH(view) view.frame.size.height

@interface ScreenRecordView ()

@property (nonatomic, strong) UIProgressView *progressView;

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) ScreenAudioRecorder *record;
@property (nonatomic, strong) UIButton *recordBtn;
@property (nonatomic, strong) UIImageView *recordBgImage;
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, strong) UILabel *durLabel;
@property (nonatomic, strong) UIView *durView;
@property (nonatomic, strong) UIView *redView;
@property (nonatomic, strong) UIView *recordPromt;
@property (nonatomic, strong) UILabel *cancelLabel;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;



@end

@implementation ScreenRecordView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.isRecording = NO;
        
        _durView = [[UIView alloc] initWithFrame:CGRectMake(0, -50, ScreenWidth, 50)];
        _durView.backgroundColor = [UIColor clearColor];
        [self addSubview:_durView];
        
        UIView *durBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 50)];
        durBg.backgroundColor = [UIColor colorWithWhite:0.6 alpha:0.3];
        [_durView addSubview:durBg];
        
        CGFloat durLabelW = [self getLabelSizeForStr:@"MM:ss" ForFont:[UIFont systemFontOfSize:14] ForMaxSize:CGSizeMake(ScreenWidth, 50)].width + 10;
        _durLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth / 2.0 - durLabelW / 2.0, 0, durLabelW, 50)];
        _durLabel.backgroundColor = [UIColor clearColor];
        _durLabel.textColor = [UIColor whiteColor];
        _durLabel.text = @"00:00";
        _durLabel.textAlignment = NSTextAlignmentCenter;
        [_durView addSubview:_durLabel];
        
        UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(_durLabel.frame.origin.x - 10, 22.5, 5, 5)];
        redView.backgroundColor = [UIColor redColor];
        redView.layer.cornerRadius = 2.5;
        redView.layer.masksToBounds = YES;
        redView.hidden = NO;
        _redView = redView;
        [_durView addSubview:_redView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesAction:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tap];
        
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 122)];
        _bottomView.backgroundColor = [UIColor clearColor];
        [self addSubview:_bottomView];
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 2, ScreenWidth, 120)];
        bgView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.3];
        [_bottomView addSubview:bgView];
        
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 2)];
        _progressView.progressTintColor = [UIColor redColor];
        _progressView.trackTintColor = [UIColor grayColor];
        _progressView.progress = 0;
        [_bottomView addSubview:_progressView];
        
        UIView *timeView = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth / maxTime * 5, 0, 2, 2)];
        timeView.backgroundColor = [UIColor whiteColor];
        [_progressView addSubview:timeView];
        
        
        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth / 2.0 - 40, 12, 80, 80)];
        _bgImageView.layer.cornerRadius = 40;
        _bgImageView.layer.masksToBounds = YES;
        _bgImageView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.3];
        [_bottomView addSubview:_bgImageView];
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(40, 40) radius:40.0 startAngle:- M_PI_2 endAngle:M_PI_2 * 3 clockwise:YES];
        _shapeLayer = [[CAShapeLayer alloc] init];
        _shapeLayer.frame = _bgImageView.bounds;
        _shapeLayer.path = bezierPath.CGPath;
        _shapeLayer.lineWidth = 2.0;
        _shapeLayer.fillColor = [UIColor clearColor].CGColor;
        _shapeLayer.strokeColor = [UIColor redColor].CGColor;
        _shapeLayer.strokeStart = 0.0;
        _shapeLayer.strokeEnd = 0.0;
        [_bgImageView.layer addSublayer:_shapeLayer];
        
//        UIButton *record = [UIButton buttonWithType:UIButtonTypeSystem];
//        record.frame = CGRectMake(ScreenWidth / 2.0 - 30, 22, 60, 60);
//        record.backgroundColor = [UIColor clearColor];
//        [record addTarget:self action:@selector(startRecordAction:) forControlEvents:UIControlEventTouchDown];
//        [record addTarget:self action:@selector(stopRecordAction:) forControlEvents:UIControlEventTouchUpInside];
//        [record addTarget:self action:@selector(cancelRecord) forControlEvents:UIControlEventTouchUpOutside];
//        self.recordBtn = record;
//        [_bottomView addSubview:self.recordBtn];
        _recordBgImage = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth / 2.0 - 30, 22, 60, 60)];
        _recordBgImage.layer.cornerRadius = 30;
        _recordBgImage.layer.masksToBounds = YES;
        _recordBgImage.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.9];
        _recordBgImage.userInteractionEnabled = YES;
        [_bottomView addSubview:_recordBgImage];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognizer:)];
        tapRecognizer.numberOfTapsRequired = 1;
        tapRecognizer.numberOfTouchesRequired = 1;
        [_recordBgImage addGestureRecognizer:tapRecognizer];
        
        UILongPressGestureRecognizer *longRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longRecognizer:)];
        longRecognizer.numberOfTouchesRequired = 1;
        longRecognizer.minimumPressDuration = 0.5;
        [_recordBgImage addGestureRecognizer:longRecognizer];
        
        
        
        UIImage *promtImage = [UIImage imageNamed:@"friendInfo_moreContent1"];
        _recordPromt = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 30 + promtImage.size.height)];
        UILabel *promtLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        promtLabel.layer.cornerRadius = 5;
        promtLabel.layer.masksToBounds = YES;
        promtLabel.textColor = [UIColor whiteColor];
        promtLabel.text = @"长按录制";
        promtLabel.backgroundColor = [UIColor colorWithRed:253.0/255.0 green:210.0/255.0 blue:73.0 / 255.0 alpha:1.0];
        promtLabel.font = [UIFont systemFontOfSize:14];
        promtLabel.textAlignment = NSTextAlignmentCenter;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(promtLabel.frame.size.width / 2.0 - promtImage.size.width / 2.0, 30, promtImage.size.width, promtImage.size.height)];
        imageView.image = promtImage;
        imageView.transform = CGAffineTransformMakeRotation(M_PI);
        [_recordPromt addSubview:imageView];
        [_recordPromt addSubview:promtLabel];
        _recordPromt.hidden = YES;
        [_bottomView addSubview:_recordPromt];
        _recordPromt.center = CGPointMake( _bottomView.frame.size.width / 2.0, _recordBgImage.frame.origin.y - (_recordPromt.frame.size.height / 2.0));
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        cancelBtn.frame = CGRectMake(20, 5, 60, 60);
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelRecord) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:cancelBtn];
        
        _cancelLabel = [[UILabel alloc] init];
        _cancelLabel.text = @"松指取消";
        _cancelLabel.textColor = [UIColor whiteColor];
        _cancelLabel.backgroundColor = [UIColor redColor];
        _cancelLabel.layer.cornerRadius = 5;
        _cancelLabel.layer.masksToBounds = YES;
        _cancelLabel.textAlignment = NSTextAlignmentCenter;
        _cancelLabel.font = [UIFont systemFontOfSize:14];
        [_bottomView addSubview:_cancelLabel];
        _cancelLabel.hidden = YES;
        
    }
    return self;
}


- (void)tapRecognizer:(UIGestureRecognizer *)tap
{
    if (!_isRecording) {
        [self startRecordAction:nil];
    } else {
        [self stopRecordAction:nil];
    }
    NSLog(@"点击手势 %d", _isRecording);
}

- (void)longRecognizer:(UIGestureRecognizer *)longR
{
    CGPoint point = [longR locationInView:self.recordBgImage];
//    CGPoint recordBgImagePoint = [self.recordBgImage convertPoint:point fromView:self];
    CGPoint centerPoint = CGPointMake(point.x - self.recordBgImage.frame.size.width / 2.0, point.y - self.recordBgImage.frame.size.height / 2.0);
    
    BOOL isCancel = (abs((int)centerPoint.x) > self.recordBgImage.frame.size.width) || (abs((int)centerPoint.y) > self.recordBgImage.frame.size.height);
    
    _cancelLabel.frame = CGRectMake(_recordBgImage.frame.origin.x + point.x + 30, _recordBgImage.frame.origin.y + point.y - 60, 80, 30);
    if (isCancel) {
        _cancelLabel.hidden = NO;
    } else {
        _cancelLabel.hidden = YES;
    }

    
    if (longR.state == UIGestureRecognizerStateBegan) {
        if (!_isRecording) {
            if (!isCancel) {
                [self startRecordAction:nil];
            }
        }
    } else if (longR.state == UIGestureRecognizerStateEnded){
        if (_isRecording) {
            if (!isCancel) {
                [self stopRecordAction:nil];
            } else {
                [self cancelRecord];
            }
        }
        _cancelLabel.hidden = YES;
    }
}

- (void)cancelRecord
{
    [UIView animateWithDuration:0.3 animations:^{
        _bgImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    }];
    [self cancelIshidden:YES];
}

- (ScreenAudioRecorder *)record
{
    if (!_record) {
        _record = [[ScreenAudioRecorder alloc] initWithRecordView:_recordView];
    }
    return _record;
}


- (void)setDurLabelText:(NSTimeInterval)duration
{
    int time = duration;
    _redView.alpha = duration - (int)duration;
    NSString *str = [NSString stringWithFormat:@"%02d:%02d", time / 60, time % 60];
    if (![str isEqualToString:_durLabel.text]) {
        _durLabel.text = str;
    }
    _shapeLayer.strokeEnd = duration / maxTime;
}

- (void)startRecordAction:(UIButton *)btn
{
    [UIView animateWithDuration:0.3 animations:^{
        _durView.frame = CGRectMake(0, 0, ScreenWidth, _durView.frame.size.height);
        _bgImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.5, 1.5);
    }];
    
    if (_recordPromt.hidden == NO) {
        _recordPromt.hidden = YES;
    }
    
    if (IsReplayKit) {
        [self replayKitStart];
        return ;
    }
    
    _isRecording = YES;
    _recordBgImage.backgroundColor = [UIColor redColor];
    
    
    [self.record startRecording];
    __weak ScreenRecordView *weakself = self;
    [self.record screenRecording:^(NSTimeInterval duration) {
//        NSLog(@"duration : %lf", duration);
        weakself.duration = duration;
        if (duration > maxTime) {
            if (weakself.isRecording) {
                [weakself stopRecordAction:self.recordBtn];
            }
        } else {
            if (weakself.isRecording) {
                [weakself setDurLabelText:duration];
                CGFloat progeressValue = duration / maxTime;
                [weakself.progressView setProgress:progeressValue animated:YES];
            }
        }
    }];
}

- (void)stopRecordAction:(UIButton *)btn
{
    _recordBgImage.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.9];
    [UIView animateWithDuration:0.3 animations:^{
        _bgImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    }];
    if (IsReplayKit) {
        [self replayKitStop];
        return;
    }

    if (self.duration < 5) {
        [self cancelIshidden:NO];
        return;
    }
    if (self.isRecording) {
        self.isRecording = NO;
        [self.record stopRecordingWithHandler:^(NSString *videoPath) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoPath)) {
                    
                    NSData *data = [NSData dataWithContentsOfFile:videoPath];
                    NSLog(@"录制结束：视频大小 %f M", data.length / 1024.0 / 1024.0);
                    UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                    self.finishRecord(videoPath);
                }
                
            });
        }];

    }
}

- (void)video: (NSString *)videoPath didFinishSavingWithError:(NSError *) error contextInfo: (void *)contextInfo{
    if (error) {
        NSLog(@"---%@",[error localizedDescription]);
    } else {
        
        NSLog(@"录制完成");
    }
}

- (void)tapGesAction:(UIGestureRecognizer *)tap
{
    CGPoint point = [tap locationInView:self];
    if (point.y < ScreenHeight - 62 && !_isRecording) {
        [self cancelIshidden:YES];
    }
}

- (void)cancelIshidden:(BOOL)isHidden
{
    if (self.isRecording) {
        [self.record cancelRecord];
    }
    _durView.frame = CGRectMake(0, -kViewH(_durView), ScreenWidth, kViewH(_durView));
    _progressView.progress = 0;
    _shapeLayer.strokeEnd = 0.0;
    NSLog(@"取消录制");
    _recordBgImage.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.9];
    _durLabel.text = @"00:00";
    if (_recordPromt.hidden == NO) {
        _recordPromt.hidden = YES;
    }
    self.isRecording = NO;
    if (isHidden) {
        [self hiddenAnimo:YES];
    }
}

- (void)hiddenAnimo:(BOOL)isHidden
{
    _progressView.progress = 0;
    _shapeLayer.strokeEnd = 0.0;
    _durLabel.text = @"00:00";
    if (isHidden) {
        [UIView animateWithDuration:0.3 animations:^{
            _bottomView.frame = CGRectMake(0, ScreenHeight, ScreenWidth, kViewH(_bottomView));
        } completion:^(BOOL finished) {
            self.hiddenRecordView(YES);
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            _bottomView.frame = CGRectMake(0, ScreenHeight - kViewH(_bottomView), ScreenWidth, kViewH(_bottomView));
        } completion:^(BOOL finished) {
            [self promtViewAnimaion];
        }];
    }
}

- (void)promtViewAnimaion
{
    _recordPromt.hidden = NO;
    CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animation];
    keyAnimation.keyPath = @"transform.rotation";
    keyAnimation.values =  @[@(-10 / 180.0 * M_PI),@(10 /180.0 * M_PI),@(-10/ 180.0 * M_PI),@(0)];//度数转弧度
    keyAnimation.removedOnCompletion = NO;
    keyAnimation.fillMode = kCAFillModeForwards;
    keyAnimation.duration = 0.3;
    keyAnimation.repeatCount = 1;
    [_recordPromt.layer addAnimation:keyAnimation forKey:nil];
}


- (CGSize)getLabelSizeForStr:(NSString *)str ForFont:(UIFont *)font ForMaxSize:(CGSize)size
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle};
    CGRect rect = [str boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    CGSize labelSize = CGSizeMake(rect.size.width, rect.size.height);
    if (labelSize.height <= 0 || labelSize.width <= 0) {
        labelSize.height = 20;
        labelSize.width = 100;
    }
    return labelSize;
}

#pragma mark ReplayKit
- (void)replayKitStart
{
    //判断系统是否支持
    if ([RPScreenRecorder sharedRecorder].available) {
        //启动录制
        [[RPScreenRecorder sharedRecorder] startRecordingWithMicrophoneEnabled:YES handler:^(NSError * _Nullable error) {
            
        }];
    }
}
- (void)replayKitStop
{
    if ([RPScreenRecorder sharedRecorder].available) {
        //结束录制
        [[RPScreenRecorder sharedRecorder] stopRecordingWithHandler:^(RPPreviewViewController * _Nullable previewViewController, NSError * _Nullable error) {
            self.replayKitFinish(previewViewController, error);
        }];
    }
}


- (void)dealloc {
    NSLog(@"screenRecordView: dealloc");
}

@end
