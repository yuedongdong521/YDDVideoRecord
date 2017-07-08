//
//  ZYSScreenAudioRecorder.m
//  ZYSScreenAudioRecorder
//
//  Created by zys on 2017/2/28.
//  Copyright © 2017年 XiYiChangXiang. All rights reserved.
//

#import "ScreenAudioRecorder.h"
#import "AudioRecorder.h"
#import "RecorMerge.h"
//#import "ScreenRecordAudio.h"

@interface ScreenAudioRecorder ()

@property (nonatomic, strong) ScreenRecorder *screenRecorder;
@property (nonatomic, strong) AudioRecorder *audioRecorder;
//@property (nonatomic, strong) ScreenRecordAudio *screenAudioRecorder;

// can get video duration
@property (nonatomic, copy) ScreenRecording screenRecording;

@end

@implementation ScreenAudioRecorder

#pragma mark - life cycle
- (instancetype)initWithRecordLayer:(CALayer *)layer {
    if (self = [super init]) {
        self.recordingLayer = layer;
    }
    
    return self;
}

- (instancetype)initWithRecordView:(UIView *)view {
    if (self = [super init]) {
        self.recordView = view;
    }
    
    return self;
}

#pragma mark - record operations
/// start recording
- (void)startRecording {
    __weak typeof (self) weakself = self;
    [self.screenRecorder startRecording];
    [self.screenRecorder screenRecording:^(NSTimeInterval duration) {
        if (weakself.screenRecording) {
            weakself.screenRecording(duration);
        }
    }];
//    [self.audioRecorder performSelector:@selector(startRecord) withObject:nil afterDelay:1.0];
//    [self.screenAudioRecorder performSelector:@selector(startScreenAudioRecord) withObject:nil afterDelay:1];
    [self.audioRecorder startRecord];
}

/// pause recording
- (void)pauseRecording {
    [self.screenRecorder pauseRecording];
    [self.audioRecorder pauseRecord];
}

/// stop recording
- (void)stopRecordingWithHandler:(ScreenRecordStop)handler {
    [self.audioRecorder stopRecord];
    [self.screenRecorder stopRecordingWithHandler:^(NSString *videoPath) {
        // merge video and audio
        [RecorMerge mergeVideo:self.screenRecorder.videoPath andAudio:self.audioRecorder.audioPath withCompletion:^(NSString *exportVideoPath) {
            NSLog(@"视频合成成功！");
            
            if (exportVideoPath) {
                if (handler) {
                    handler(exportVideoPath);
                }
            }
        }];
    }];
}

- (void)cancelRecord
{
    [self.audioRecorder stopRecord];
    [self.screenRecorder stopRecordingWithHandler:^(NSString *videoPath) {
        NSFileManager *filemanger = [NSFileManager defaultManager];
        if ([filemanger isExecutableFileAtPath:videoPath]) {
            [filemanger removeItemAtPath:videoPath error:nil];
        }

        if ([filemanger isExecutableFileAtPath:self.screenRecorder.videoPath]) {
            [filemanger removeItemAtPath:self.screenRecorder.videoPath error:nil];
        }
        
    }];
}

- (void)screenRecording:(ScreenRecording)screenRecording {
    self.screenRecording = [screenRecording copy];
}

#pragma mark - Getters
- (ScreenRecorder *)screenRecorder {
    if (!_screenRecorder) {
        _screenRecorder = [[ScreenRecorder alloc] init];
//        _screenRecorder.captureLayer = self.recordingLayer;
        _screenRecorder.captureView = self.recordView;
    }
    
    return _screenRecorder;
}


- (AudioRecorder *)audioRecorder {
    if (!_audioRecorder) {
        _audioRecorder = [[AudioRecorder alloc] init];
    }
    
    return _audioRecorder;
}


- (void)dealloc
{
    NSLog(@"ZYSScreenAudioRecorder : dealloc");
}

@end
