//
//  BarrageItemView.m
//  ViewsTalk
//
//  Created by ispeak on 2017/1/10.
//  Copyright © 2017年 ydd. All rights reserved.
//

#import "BarrageItemView.h"

@implementation BarrageItemView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame WithNameWidth:(CGFloat)nameWidth WithContentWidth:(CGFloat)contentWidth
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        CGFloat itemW = frame.size.width;
        CGFloat itemH = frame.size.height;
        
        UIView *concentBgView = [[UIView alloc] initWithFrame:CGRectMake(itemH / 2.0, itemH / 2.0, contentWidth + itemH / 2.0 + 10, itemH / 2.0)];
        concentBgView.layer.cornerRadius = itemH / 4.0;
        concentBgView.layer.masksToBounds = YES;
        concentBgView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:1.0];
        [self addSubview:concentBgView];
        
        _headImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, itemH, itemH)];
        _headImage.layer.cornerRadius = itemH / 2.0;
        _headImage.layer.masksToBounds = YES;
        [self addSubview:_headImage];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(itemH, 0, nameWidth, itemH / 2.0)];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:_nameLabel];
        
        _concentLabel = [[UILabel alloc] initWithFrame:CGRectMake(itemH / 2.0, 0, contentWidth, itemH / 2.0)];
        _concentLabel.textAlignment = NSTextAlignmentCenter;
        _concentLabel.font = [UIFont systemFontOfSize:14];
        _concentLabel.textColor = [UIColor whiteColor];
        [concentBgView addSubview:_concentLabel];
    }
    return self;
}

- (instancetype)initTowWithFrame:(CGRect)frame WithContentWidth:(CGFloat)contentWidth
{
    if (self = [super initWithFrame:frame]) {
        CGFloat itemH = frame.size.height;
        _headImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, itemH, itemH)];
        _headImage.layer.cornerRadius = itemH / 2.0;
        _headImage.layer.masksToBounds = YES;
        [self addSubview:_headImage];
        
        _concentLabel = [[UILabel alloc] initWithFrame:CGRectMake(itemH, 0, contentWidth, itemH)];
        _concentLabel.textAlignment = NSTextAlignmentCenter;
        _concentLabel.font = [UIFont systemFontOfSize:14];
        _concentLabel.textColor = [UIColor whiteColor];
        [self addSubview:_concentLabel];
    }
    return self;
}



@end
