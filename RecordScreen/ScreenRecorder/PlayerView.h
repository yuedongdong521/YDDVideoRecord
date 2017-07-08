//
//  PlayerView.h
//  RecordScreen
//
//  Created by ispeak on 2017/4/24.
//  Copyright © 2017年 ydd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol PlayerViewDelegate <NSObject>

- (void)clasePlayer;

@end

@interface PlayerView : UIView

@property(nonatomic, strong) AVPlayer *player;
@property(nonatomic, strong) AVPlayerItem *playerItem;

@property (nonatomic, weak) id<PlayerViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame ForVideoPath:(NSString *)videoPath;
- (void)startPlayer;
@end
