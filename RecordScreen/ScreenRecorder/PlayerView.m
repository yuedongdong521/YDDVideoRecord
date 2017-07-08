//
//  PlayerView.m
//  RecordScreen
//
//  Created by ispeak on 2017/4/24.
//  Copyright © 2017年 ydd. All rights reserved.
//

#import "PlayerView.h"

@implementation PlayerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame ForVideoPath:(NSString *)videoPath
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _playerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:videoPath]];
        _player = [[AVPlayer alloc] initWithPlayerItem:_playerItem];
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        playerLayer.frame = self.bounds;
        playerLayer.backgroundColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:playerLayer];
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _player.volume = 1.0;

        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(20, 20, 60, 30);
        [button setTitle:@"关闭" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor clearColor];
        [self addSubview:button];
        
    }
    return self;
}

- (void)close
{
    if ([_delegate respondsToSelector:@selector(clasePlayer)]) {
        [_delegate clasePlayer];
    }
    
}

- (void)startPlayer
{
    [_player play];
}


@end
