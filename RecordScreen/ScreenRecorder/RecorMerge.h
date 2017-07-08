//
//  RecorMerge.h
//  TestScreenRecorde
//
//  Created by ydd on 2017/4/24.
//  Copyright © 2017年 ydd. All rights reserved.
//

/**
 *  Record utils(Merge video and audio)
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^ExportVideoCompletion)(NSString *exportVideoPath);

@interface RecorMerge : NSObject


+ (void)mergeVideo:(NSString *)videoPath andAudio:(NSString *)audioPath withCompletion:(ExportVideoCompletion)completion;

/***
 @videoUrl 目标视频地址
 @audioUrl 目标音频地址
 @IsAudioMix 原视频音乐是否与要加入的音频混音
 @BackVideoPath 返回处理完成的视频地址
 @stickersImageView 向视频中添加贴纸
 ***/
+ (void)mixAudioAndVidoWithVideoUrl:(NSURL*)videoUrl WithAudioUrl:(NSURL*)audioUrl WithIsAudioMix:(BOOL)isAudionMix WithBackVideoPath:(void(^)(NSURL *))BackVideoPath WithStickersImgView:(UIImageView *)stickersImgView;

@end
