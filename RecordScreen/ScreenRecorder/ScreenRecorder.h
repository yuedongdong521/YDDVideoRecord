//
//  ScreenRecorder.h
//  ScreenRecorder
//
//  Created by ydd on 2017/4/24.
//  Copyright © 2017年 ydd. All rights reserved.
//

/**
 *  Screen Recorder
 */

#import <Foundation/Foundation.h>

typedef void(^ScreenRecording)(NSTimeInterval duration);
typedef void(^ScreenRecordStop)(NSString *videoPath);

@interface ScreenRecorder : NSObject

// reqeuired, captue view
@property (nonatomic, strong) CALayer *captureLayer;
@property (nonatomic, strong) UIView *captureView;

// optional, frame per second
@property (nonatomic, assign) NSInteger frameRate;

// total duration
@property (nonatomic, readonly) NSTimeInterval duration;

// video path
@property (nonatomic, readonly) NSString *videoPath;


// start
- (void)startRecording;

// pause
- (void)pauseRecording;

// stopRecording
- (void)stopRecordingWithHandler:(ScreenRecordStop)handler;

// recording, can get duration
- (void)screenRecording:(ScreenRecording)screenRecording;

@end
