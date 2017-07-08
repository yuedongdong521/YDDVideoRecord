//
//  AudioRecorder.h
//  RecordeScreen
//
//  Created by ydd on 2017/4/24.
//  Copyright © 2017年 ydd. All rights reserved.
//

/**
 *  Audio recorder
 */

#import <Foundation/Foundation.h>

@interface AudioRecorder : NSObject

@property (nonatomic, copy, readonly) NSString *audioPath;

- (void)startRecord;
- (void)pauseRecord;
- (void)stopRecord;
- (void)deleteRecord;

@end
