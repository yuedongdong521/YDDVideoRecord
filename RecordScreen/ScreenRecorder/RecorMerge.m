//
//  RecorMerge.m
//  TestScreenRecorde
//
//  Created by ydd on 2017/4/24.
//  Copyright © 2017年 ydd. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "RecorMerge.h"

@implementation RecorMerge

+ (void)mergeVideo:(NSString *)videoPath andAudio:(NSString *)audioPath withCompletion:(ExportVideoCompletion)completion {
    
    // video and audio resource
    NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
    NSURL *audioURL = [NSURL fileURLWithPath:audioPath];
    
    // ouput file path
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *outputPath = [docPath stringByAppendingPathComponent:@"ScreenRecord.mp4"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:outputPath]) {
        if (![fm removeItemAtPath:outputPath error:nil]) {
//            NSLog(@"remove old output file failed.");
        }
    }
    NSURL *outputURL = [NSURL fileURLWithPath:outputPath];
    
    
    // start time
    CMTime startTime = kCMTimeZero;
    
    // create composition
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    //混合视屏
    /// video collect
    // get video asset
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    
    // get video time range
    CMTime startCMTime = CMTimeMake(1, 2);
    CMTime videoDuration = videoAsset.duration;
    videoDuration = CMTimeSubtract(videoDuration, CMTimeMake(videoDuration.timescale / 2.0, videoDuration.timescale));
    CMTimeRange videoTimeRange = CMTimeRangeMake(startCMTime, videoDuration);
    
    // create video channel
    AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    // video collect channel
    AVAssetTrack *videoAssetTrack = [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    
    // add video collect channel data to a mutable channel
    [videoTrack insertTimeRange:videoTimeRange ofTrack:videoAssetTrack atTime:startTime error:nil];
    
    //混合音频
    /// audio collect
    AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:audioURL options:nil];
    
    CMTime audioDuration = audioAsset.duration;
    audioDuration = CMTimeSubtract(audioDuration, CMTimeMake(audioDuration.timescale / 2.0, audioDuration.timescale));
    // use video time for audio time
    CMTimeRange audioTimeRange = CMTimeRangeMake(startCMTime, audioDuration);
    
    // create audio channel
    AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    // audio collect channel
    AVAssetTrack *audioAssetTrack = [audioAsset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    
    // add audio collect channel data to a mutable channel
    [audioTrack insertTimeRange:audioTimeRange ofTrack:audioAssetTrack atTime:startTime error:nil];
    
    // create output
    AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    
    // ouput type
    assetExport.outputFileType = AVFileTypeMPEG4;
    
    // output address
    assetExport.outputURL = outputURL;
    
    // optimization
    assetExport.shouldOptimizeForNetworkUse = YES;
    
    // export
    [assetExport exportAsynchronouslyWithCompletionHandler:^{
        // delete original video and audio file

        if ([fm fileExistsAtPath:videoPath]) {
            if (![fm removeItemAtPath:videoPath error:nil]) {
//                NSLog(@"remove video.mp4 failed.");
            }
        }
        
        if ([fm fileExistsAtPath:audioPath]) {
            if (![fm removeItemAtPath:audioPath error:nil]) {
//                NSLog(@"remove audio.wav failed.");
            }
        }
        
        if (completion) {
            completion(outputPath);
        }
    }];
}


//音视频合成 (是否混音合成)
-(void)mixAudioAndVidoWithVideoUrl:(NSURL*)videoUrl WithAudioUrl:(NSURL*)audioUrl WithIsAudioMix:(BOOL)isAudionMix WithBackVideoPath:(void(^)(NSURL *))BackVideoPath WithStickersImgView:(UIImageView *)stickersImgView
{
    
    //    audio529
    
    // 路径
    NSString *documents = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
    
    // 声音来源
    
    //    NSURL *audioInputUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"audio529" ofType:@"mp3"]];
    
    NSURL *audioInputUrl = audioUrl;
    
    // 视频来源
    
    NSURL *videoInputUrl = videoUrl;
    
    // 最终合成输出路径
    
    //    NSString *outPutFilePath = [documents stringByAppendingPathComponent:@"videoandoudio.mov"];
    
    // 添加合成路径
    
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSString *fileName = [[documents stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@"merge.mp4"];
    
    
    
    //    NSURL *outputFileUrl = [NSURL fileURLWithPath:outPutFilePath];
    NSURL *outputFileUrl = [NSURL fileURLWithPath:fileName];
    
    // 时间起点
    
    CMTime nextClistartTime = kCMTimeZero;
    
    // 创建可变的音视频组合
    
    AVMutableComposition *comosition = [AVMutableComposition composition];
    
    // 视频采集
    NSDictionary* options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoInputUrl options:options];
    
    // 视频时间范围
    
    CMTimeRange videoTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    
    // 视频通道 枚举 kCMPersistentTrackID_Invalid = 0
    
    AVMutableCompositionTrack *videoTrack = [comosition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    // 视频采集通道
    
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    
    //  把采集轨道数据加入到可变轨道之中
    
    [videoTrack insertTimeRange:videoTimeRange ofTrack:videoAssetTrack atTime:nextClistartTime error:nil];
    
    // 声音采集
    
    AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:audioInputUrl options:options];
    
    // 因为视频短这里就直接用视频长度了,如果自动化需要自己写判断
    
    CMTimeRange audioTimeRange = videoTimeRange;
    
    // 音频通道
    
    AVMutableCompositionTrack *audioTrack = [comosition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    // 音频采集通道
    
    AVAssetTrack *audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    
    // 加入合成轨道之中
    
    [audioTrack insertTimeRange:audioTimeRange ofTrack:audioAssetTrack atTime:nextClistartTime error:nil];
    
    
    
    /*
     //调整视频音量
     AVMutableAudioMix *mutableAudioMix = [AVMutableAudioMix audioMix];
     // Create the audio mix input parameters object.
     AVMutableAudioMixInputParameters *mixParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
     // Set the volume ramp to slowly fade the audio out over the duration of the composition.
     //    [mixParameters setVolumeRampFromStartVolume:1.f toEndVolume:0.f timeRange:CMTimeRangeMake(kCMTimeZero, mutableComposition.duration)];
     [mixParameters setVolume:.05f atTime:kCMTimeZero];
     // Attach the input parameters to the audio mix.
     mutableAudioMix.inputParameters = @[mixParameters];
     */
    
    
    // 原音频轨道
    //    AVMutableCompositionTrack *audioTrack2 = [comosition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    //     AVAssetTrack *audioAssetTrack2 = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    //    [audioTrack2 insertTimeRange:audioTimeRange ofTrack:audioAssetTrack2 atTime:nextClistartTime error:nil];
    
    
    if (isAudionMix) {
        AVMutableAudioMix *mutableAudioMix = [AVMutableAudioMix audioMix];
        // Create the audio mix input parameters object.
        AVMutableAudioMixInputParameters *mixParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
        // Set the volume ramp to slowly fade the audio out over the duration of the composition.
        //    [mixParameters setVolumeRampFromStartVolume:1.f toEndVolume:0.f timeRange:CMTimeRangeMake(kCMTimeZero, mutableComposition.duration)];
        [mixParameters setVolume:.5f atTime:kCMTimeZero];
        // Attach the input parameters to the audio mix.
        mutableAudioMix.inputParameters = @[mixParameters];
        
        AVMutableCompositionTrack *audioTrack2 = [comosition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        AVAssetTrack *audioAssetTrack2 = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        [audioTrack2 insertTimeRange:audioTimeRange ofTrack:audioAssetTrack2 atTime:nextClistartTime error:nil];
        
        
        //视频贴图
        CGSize videoSize = [videoTrack naturalSize];
        CALayer* aLayer = [CALayer layer];
        UIImage* waterImg = stickersImgView.image;
        aLayer.contents = (id)waterImg.CGImage;
        
        float bili = 720/ScreenWidth;
        
        
        aLayer.frame = CGRectMake(stickersImgView.frame.origin.x * bili,1280 - stickersImgView.frame.origin.y *bili - 150*bili, 150*bili, 150*bili);
        aLayer.opacity = 1;
        
        CALayer *parentLayer = [CALayer layer];
        CALayer *videoLayer = [CALayer layer];
        parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
        videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
        [parentLayer addSublayer:videoLayer];
        [parentLayer addSublayer:aLayer];
        AVMutableVideoComposition* videoComp = [AVMutableVideoComposition videoComposition];
        videoComp.renderSize = videoSize;
        
        
        videoComp.frameDuration = CMTimeMake(1, 30);
        videoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
        AVMutableVideoCompositionInstruction* instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [comosition duration]);
        AVAssetTrack* mixVideoTrack = [[comosition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:mixVideoTrack];
        instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
        videoComp.instructions = [NSArray arrayWithObject: instruction];
        
        AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:comosition presetName:AVAssetExportPreset1280x720];
        
        assetExport.audioMix = mutableAudioMix;
        
        assetExport.videoComposition = videoComp;
        // 输出类型
        
        assetExport.outputFileType = AVFileTypeMPEG4;
        
        // 输出地址
        
        assetExport.outputURL = outputFileUrl;
        
        // 优化
        
        assetExport.shouldOptimizeForNetworkUse = YES;
        
        // 合成完毕
        
        [assetExport exportAsynchronouslyWithCompletionHandler:^{
            
            // 回到主线程
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                BackVideoPath(outputFileUrl);
            });
        }];
    }else
    {
        
        //视频贴图
        CGSize videoSize = [videoTrack naturalSize];
        CALayer* aLayer = [CALayer layer];
        UIImage* waterImg = stickersImgView.image;
        aLayer.contents = (id)waterImg.CGImage;
        float bili = 720 / ScreenWidth;
        aLayer.frame = CGRectMake(stickersImgView.frame.origin.x * bili,1280 - stickersImgView.frame.origin.y *bili - 150*bili, 150*bili, 150*bili);
        aLayer.opacity = 1;
        
        CALayer *parentLayer = [CALayer layer];
        CALayer *videoLayer = [CALayer layer];
        parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
        videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
        [parentLayer addSublayer:videoLayer];
        [parentLayer addSublayer:aLayer];
        AVMutableVideoComposition* videoComp = [AVMutableVideoComposition videoComposition];
        videoComp.renderSize = videoSize;
        
        
        videoComp.frameDuration = CMTimeMake(1, 30);
        videoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
        AVMutableVideoCompositionInstruction* instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [comosition duration]);
        AVAssetTrack* mixVideoTrack = [[comosition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:mixVideoTrack];
        instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
        videoComp.instructions = [NSArray arrayWithObject: instruction];
        
        // 创建一个输出
        
        AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:comosition presetName:AVAssetExportPreset1280x720];
        
        assetExport.videoComposition = videoComp;
        //    assetExport.audioMix = mutableAudioMix;
        // 输出类型
        
        assetExport.outputFileType = AVFileTypeMPEG4;
        
        // 输出地址
        
        assetExport.outputURL = outputFileUrl;
        
        // 优化
        
        assetExport.shouldOptimizeForNetworkUse = YES;
        
        // 合成完毕
        
        [assetExport exportAsynchronouslyWithCompletionHandler:^{
            
            // 回到主线程
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                BackVideoPath(outputFileUrl);
                
            });
        }];
        
    }
    
    
    
}




@end
