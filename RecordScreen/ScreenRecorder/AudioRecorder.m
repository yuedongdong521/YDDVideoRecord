//
//  AudioRecorder.m
//  RecordeScreen
//
//  Created by ydd on 2017/4/24.
//  Copyright © 2017年 ydd. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "AudioRecorder.h"

@interface AudioRecorder ()

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, copy) NSString *audioPath;

@end

@implementation AudioRecorder

#pragma mark - Recorder Operation
- (void)startRecord {
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.audioPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.audioPath error:nil];
    }
    if ([self.recorder prepareToRecord]) {
        [self.recorder record];
    }
}

- (void)pauseRecord {
    [self.recorder pause];
}

- (void)stopRecord {
    [self.recorder stop];
}

- (void)deleteRecord {
    [self.recorder deleteRecording];
}

#pragma mark - private method
- (void)configureAudioSession {
    // Set session category
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDuckOthers error:nil];
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    // Set the session active
//    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

- (NSURL *)wavFileURL {
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.audioPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.audioPath error:nil];
    }
    return [NSURL fileURLWithPath:self.audioPath];
}

/// recorder setting
+ (NSDictionary*)fetchAudioRecorderSettingDict {
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [NSNumber numberWithFloat: 16000.0],AVSampleRateKey, //采样率
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,//采样位数 默认 16
                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,//通道的数目
                                   nil];
    return recordSetting;
}

#pragma mark - Getters
- (AVAudioRecorder *)recorder {
    if (!_recorder) {
        [self configureAudioSession];
        _recorder = [[AVAudioRecorder alloc] initWithURL:[self wavFileURL] settings:[self.class fetchAudioRecorderSettingDict] error:nil];
        _recorder.meteringEnabled = YES;// Monitor sound wave
    }
    
    return _recorder;
}

- (NSString *)audioPath {
    if (!_audioPath) {
        NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        _audioPath = [docPath stringByAppendingPathComponent:@"sound.wav"];
    }
    
    return _audioPath;
}

@end
