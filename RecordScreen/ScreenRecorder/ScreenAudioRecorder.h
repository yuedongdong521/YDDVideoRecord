//
//  ScreenAudioRecorder.h
//  ScreenAudioRecorder
//
//  Created by ydd on 2017/4/24.
//  Copyright © 2017年 ydd. All rights reserved.
//

/**
 *  Screen Audio Recroder
 */

#import <UIKit/UIKit.h>
#import "ScreenRecorder.h"

@interface ScreenAudioRecorder : NSObject

@property (nonatomic, strong) CALayer *recordingLayer;
@property (nonatomic, strong) UIView *recordView;

/// init with a recording view.
- (instancetype)initWithRecordLayer:(CALayer *)layer;
- (instancetype)initWithRecordView:(UIView *)view;

/// start recording
- (void)startRecording;

/// pause recording
- (void)pauseRecording;

/// stop recording
- (void)stopRecordingWithHandler:(ScreenRecordStop)handler;

/// recording, can get duration
- (void)screenRecording:(ScreenRecording)screenRecording;

- (void)cancelRecord;

@end
