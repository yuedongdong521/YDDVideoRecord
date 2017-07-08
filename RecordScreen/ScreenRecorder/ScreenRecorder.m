//
//  ScreenRecorder.m
//  RecorderScreen
//
//  Created by ydd on 2017/4/24.
//  Copyright © 2017年 ydd. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "ScreenRecorder.h"
#import <sys/utsname.h>

@interface ScreenRecorder ()

@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, strong) NSString *videoPath;

@property (nonatomic, copy) ScreenRecording screenRecording;
@property (nonatomic, copy) ScreenRecordStop screenRecordStop;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger frameCount;
@property (nonatomic, strong) AVAssetWriter *videoWriter;
@property (nonatomic, strong) AVAssetWriterInput *videoWriterInput;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *adaptor;

@property (nonatomic, assign) BOOL isPausing;
@property (nonatomic, assign) BOOL writing;
@property (nonatomic, strong) NSDate *startedAt;
@property (nonatomic, assign) BOOL isRecording;

@end

@implementation ScreenRecorder

#pragma mark - life cycle
- (instancetype)init {
    if (self = [super init]) {
        // set default frame rate to 24.
        self.frameRate = 24;
        self.duration = 0.0;
        self.isPausing = false;
        self.isRecording = NO;
    }
    
    return self;
}

#pragma mark - start / stop
- (void)startRecording {
    NSLog(@"录制开始");
    self.isRecording = YES;
    [self setupVideoWriter];
    self.frameRate = 24;
    _startedAt = [NSDate date];
    self.duration = 0.0;
    self.isPausing = false;
    self.frameCount = 0;
    self.writing = NO;
   
    
    // init timer
    NSDate *nowDate = [NSDate date];
    _timer = [[NSTimer alloc] initWithFireDate:nowDate interval:1.0 / self.frameRate target:self selector:@selector(drawVideoFrame) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)pauseRecording {
    self.isPausing = true;
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)releseWrite
{
    self.adaptor = nil;
    self.videoWriterInput = nil;
    self.videoWriter = nil;
    self.startedAt = nil;
}
- (void)stopRecordingWithHandler:(ScreenRecordStop)handler {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    self.isRecording = NO;
    
    [self.videoWriterInput markAsFinished];

    [self.videoWriter finishWritingWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (handler) {
                handler(self.videoPath);
            }
        });
        [self releseWrite];
    }];
}

#pragma mark - recording method, send duration
- (void)screenRecording:(ScreenRecording)screenRecording {
    self.screenRecording = [screenRecording copy];
}

#pragma mark - private methods
- (void)drawVideoFrame {
    if (!self.writing) {
//        self.duration += 1.0 / self.frameRate;
        self.duration = [[NSDate date] timeIntervalSinceDate:_startedAt];
        [self makeFrame];

        if (self.screenRecording) {
            __weak typeof (self) weakself = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                weakself.screenRecording(weakself.duration);
            });
        }
    }
}

/// make per frame
- (void)makeFrame {
    UIImage *image = [self getImageViewWithViewThree:self.captureView];
    [self performSelectorInBackground:@selector(makeFrameOnThreadForImage:) withObject:image];
}

- (void)makeFrameOnThreadForImage:(UIImage *)image
{
    self.frameCount++;
    if (!self.writing) {
        self.writing = YES;
        @try {
            float millisElapsed = [[NSDate date] timeIntervalSinceDate:_startedAt] * 1000.0;
            CMTime frameTime = CMTimeMake((int)millisElapsed, 1000);
            [self appendVideoFrameAtTime:frameTime forImage:image];
        }
        @catch (NSException *exception) {
            
        }
        self.writing = NO;
    }
  
}


- (UIImage *)getImageViewWithViewThree:(UIView *)view{
    if (!view) {
        return nil;
    }
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [UIScreen mainScreen].scale);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


/// append image to video
- (void)appendVideoFrameAtTime:(CMTime)frameTime forImage:(UIImage *)image {
//    CGImageRef newImage = [self fetchScreenshot].CGImage;
//    CGImageRef newImage = [self getImageViewWithViewThree:self.captureView].CGImage;
    CGImageRef newImage = image.CGImage;
    if (![self.videoWriterInput isReadyForMoreMediaData]) {
        NSLog(@"Not ready for video data");
        
    } else {
        @synchronized (self) {
            if (self.adaptor.assetWriterInput.readyForMoreMediaData) {
                 CVPixelBufferRef buffer = [self pixelBufferFromCGImage:newImage];
//                 CVPixelBufferRetain(buffer); // hope to retain
                if (buffer != NULL) {
                    if(![self.adaptor appendPixelBuffer:buffer withPresentationTime:frameTime]){
                        NSError *error = self.videoWriter.error;
                        if(error) {
//                            NSLog(@"Unresolved error %@,%@.", error, [error userInfo]);
                        }
                    }
                    CVPixelBufferRelease(buffer);
                }
            } else {
//                printf("adaptor not ready %zd\n", self.frameCount);
            }
//            NSLog(@"**************************************************");
        }
        
    }
}

//-(void) writeVideoFrameAtTime:(CMTime)time addImage:(CGImageRef )newImage
//{
//    if (![self.videoWriterInput isReadyForMoreMediaData]) {
//        NSLog(@"Not ready for video data");
//    }
//    else {
//        @synchronized (self) {
//            CVPixelBufferRef pixelBuffer = NULL;
//            CGImageRef cgImage = CGImageCreateCopy(newImage);
//            UIImage *gImage = [UIImage imageWithCGImage:cgImage];
//            CFDataRef image = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
//            
//            int status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, self.adaptor.pixelBufferPool, &pixelBuffer);
//            if(status != 0){
//                //could not get a buffer from the pool
//                NSLog(@"Error creating pixel buffer:  status=%d", status);
//            }
//            // set image data into pixel buffer
//            CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
//            uint8_t * destPixels = CVPixelBufferGetBaseAddress(pixelBuffer);
//            CFDataGetBytes(image, CFRangeMake(0, CFDataGetLength(image)), destPixels);  //XXX:  will work if the pixel buffer is contiguous and has the same bytesPerRow as the input data
//            
//            if(status == 0 && pixelBuffer){
//                BOOL success = [self.adaptor appendPixelBuffer:pixelBuffer withPresentationTime:time];
//                if (!success)
//                    NSLog(@"Warning:  Unable to write buffer to video");
//            }
//            
//            //clean up
//            CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
//            CVPixelBufferRelease( pixelBuffer );
//            CFRelease(image);
//            CGImageRelease(cgImage);
//        }
//    }
//}



/// init video writer
- (BOOL)setupVideoWriter {
//    CGSize size = [[UIScreen mainScreen] bounds].size;
    
    NSString *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    self.videoPath = [documents stringByAppendingPathComponent:@"video.mp4"];
    
    [[NSFileManager defaultManager] removeItemAtPath:self.videoPath error:nil];
    
    NSError *error;
    
    // Configure videoWriter
    NSURL *fileUrl = [NSURL fileURLWithPath:self.videoPath];
    self.videoWriter = [[AVAssetWriter alloc] initWithURL:fileUrl fileType:AVFileTypeMPEG4 error:&error];
    NSParameterAssert(self.videoWriter);
    
    // Configure videoWriterInput
//    NSDictionary *videoCompressionProps = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:30 * size.width * size.height], AVVideoAverageBitRateKey, nil];
    NSDictionary *videoCompressionProps = [NSDictionary dictionaryWithObjectsAndKeys:@2000000, AVVideoAverageBitRateKey, nil];
    
    NSDictionary *videoSettings = @{AVVideoCodecKey: AVVideoCodecH264,
                                    AVVideoWidthKey: @(720),
                                    AVVideoHeightKey: @(1280),
                                    AVVideoCompressionPropertiesKey: videoCompressionProps};
    
    self.videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    
    NSParameterAssert(self.videoWriterInput);
    self.videoWriterInput.expectsMediaDataInRealTime = YES;
    NSDictionary *bufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
    
    _adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:self.videoWriterInput sourcePixelBufferAttributes:bufferAttributes];
    
    // add input
    [self.videoWriter addInput:self.videoWriterInput];
    [self.videoWriter startWriting];
    [self.videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    return YES;
}

/// image => PixelBuffer
- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image {
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    
    CVPixelBufferRef pxbuffer = NULL;
    
    CGFloat frameWidth = CGImageGetWidth(image);
    CGFloat frameHeight = CGImageGetHeight(image);
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,frameWidth,frameHeight,kCVPixelFormatType_32ARGB,(__bridge CFDictionaryRef) options, &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, frameWidth, frameHeight, 8,CVPixelBufferGetBytesPerRow(pxbuffer),rgbColorSpace,(CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context, CGRectMake(0, 0,frameWidth,frameHeight),  image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

/// view => screen shot image
- (UIImage *)fetchScreenshot {
    UIImage *image = nil;
    
    if (self.captureLayer) {
        NSLock *aLock = [NSLock new];
        [aLock lock];
        
        CGSize imageSize = self.captureLayer.bounds.size;
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [self.captureLayer renderInContext:context];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [aLock unlock];
    }
    
    return image;
}

- (BOOL)judgeFrameRate
{
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if ([platform isEqualToString:@"iPhone3,1"]) return NO;
    
    if ([platform isEqualToString:@"iPhone3,2"]) return NO;
    
    if ([platform isEqualToString:@"iPhone3,3"]) return NO;
    
    if ([platform isEqualToString:@"iPhone4,1"]) return NO;
    
    if ([platform isEqualToString:@"iPhone5,1"]) return NO;
    
    if ([platform isEqualToString:@"iPhone5,2"]) return NO;
    
    if ([platform isEqualToString:@"iPhone5,3"]) return NO;
    
    if ([platform isEqualToString:@"iPhone5,4"]) return NO;
    
    if ([platform isEqualToString:@"iPhone6,1"]) return NO;
    
    if ([platform isEqualToString:@"iPhone6,2"]) return NO;
    
    if ([platform isEqualToString:@"iPhone7,1"]) return NO;
    
    if ([platform isEqualToString:@"iPhone7,2"]) return NO;
    
    if ([platform isEqualToString:@"iPhone8,1"]) return YES;
    
    if ([platform isEqualToString:@"iPhone8,2"]) return YES;
    
    if ([platform isEqualToString:@"iPhone8,4"]) return YES;
    
    if ([platform isEqualToString:@"iPhone9,1"]) return YES;
    
    if ([platform isEqualToString:@"iPhone9,2"]) return YES;
    return YES;
}

- (NSString *)iphoneType {
    
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
    
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
    
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
    
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
    
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    
    if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    
    if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    
    if ([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G";
    
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G";
    
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G";
    
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G";
    
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G";
    
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    
    return platform;
    
}

- (void)dealloc
{
    NSLog(@"ZYSScreenRecorder : dealloc");
}

@end
