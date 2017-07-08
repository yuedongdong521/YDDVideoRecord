//
//  BarrageView.m
//  ViewsTalk
//
//  Created by ispeak on 2017/1/10.
//  Copyright © 2017年 ydd. All rights reserved.
//

#import "BarrageView.h"
#import "BarrageItemView.h"

#define kDuration 5
#define kSpeed 75.0
#define kWidth(view) view.frame.size.width
#define kHeight(view) view.frame.size.height
#define kX(view) view.frame.origin.x
#define kY(View) view.frame.origin.y

#define lineHeight  20
#define lineSpac 40

@interface BarrageView()

@property (nonatomic, strong)NSMutableArray *saveArray;
@property (nonatomic, assign)BOOL isPlaying;
@property (nonatomic, strong)BarrageItemView *lastItemView;
@property (nonatomic, strong)NSMutableDictionary *itemDic;
@property (nonatomic, strong)NSTimer *barrageTimer;
@property (nonatomic, strong)NSLock *barrageLock;

@end

@implementation BarrageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _saveArray = [NSMutableArray arrayWithCapacity:0];
        _itemDic = [NSMutableDictionary dictionaryWithCapacity:0];
        _isPlaying = NO;
        self.backgroundColor = [UIColor clearColor];
        _barrageLock = [[NSLock alloc] init];
    }
    return self;
}




- (void)sendBarrageForPraise:(PriaseSendStructure *)praise
{
    [self createBarrageForUserId:praise.uid ForIconindex:praise.iconIndex ForUserName:praise.username ForContentStr:praise.content ForUserRank:praise.rankCustom ForRank:praise.rank];
//    [self createBarrageForPraise:praise];
}


#pragma mark 自适应调整宽度和高度
- (CGSize)contentString:(NSString *)textString cmFontSize:(UIFont *)cmFontSize cmSize:(CGSize)cmSize {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:cmFontSize, NSParagraphStyleAttributeName:paragraphStyle};
    CGRect rect = [textString boundingRectWithSize:cmSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    CGSize labelSize = CGSizeMake(rect.size.width, rect.size.height);
    if (labelSize.height <= 0 || labelSize.width <= 0) {
        labelSize.height = 20;
        labelSize.width = 100;
    }
    return labelSize;
}

- (void)createBarrageForPraise:(PriaseSendStructure *)praise
{

    CGFloat contentW = [self contentString:praise.content cmFontSize:[UIFont systemFontOfSize:14] cmSize:CGSizeMake(1000, 20)].width + 10;
    CGFloat itemW = contentW + 20;
    

    NSString *rankImageStr = @"rank_150";

     BarrageItemView *itemView = [[BarrageItemView alloc] initTowWithFrame:CGRectMake(ScreenWidth, kHeight(self) - (_maxLineCount == 1?20 : 30), itemW, 20) WithContentWidth:contentW];
    if (_isUniform) {
        itemView.durationTime = (ScreenWidth + kWidth(itemView)) / kSpeed;
    } else {
        itemView.durationTime = kDuration;
    }
    
    itemView.headImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"0" ofType:@"jpg"]];
    itemView.nameLabel.attributedText = [self getnameStr:praise.username ForImageStr:rankImageStr];
    itemView.concentLabel.text = praise.content;
    [self addSubview:itemView];
    [self.saveArray addObject:itemView];
    
    [self barrageStart:itemView];
}


- (void)createBarrageForUserId:(int)userId ForIconindex:(int)iconindex ForUserName:(NSString *)nameStr ForContentStr:(NSString *)contentStr ForUserRank:(int)userRank ForRank:(int)rank
{
    CGFloat nameW = [self contentString:nameStr cmFontSize:[UIFont systemFontOfSize:14] cmSize:CGSizeMake(1000, 20)].width + 40;
    CGFloat contentW = [self contentString:contentStr cmFontSize:[UIFont systemFontOfSize:14] cmSize:CGSizeMake(1000, 20)].width + 10;
    CGFloat itemW = nameW > contentW? nameW : contentW;
    
//    NSString *rankImageStr = [[AppDelegate appDelegate].appViewService getrankCustomImageStrfromrankCustomForLivng:userRank];
//    if (rank == 90) {
//        rankImageStr = @"AthorityImage";
//    }
     NSString *rankImageStr = @"rank_150";
    BarrageItemView *itemView = [[BarrageItemView alloc] initWithFrame:CGRectMake(ScreenWidth, kHeight(self) - (_maxLineCount == 1?lineHeight : lineSpac), itemW + lineSpac, lineSpac) WithNameWidth:nameW WithContentWidth:contentW];
    if (_isUniform) {
        itemView.durationTime = (ScreenWidth + kWidth(itemView)) / kSpeed;
    } else {
        itemView.durationTime = kDuration;
    }
    
//    [[AppDelegate appDelegate].appViewService setImageViewimagefromUrl:iconindex withFriendId:userId withimageView:itemView.headImage];
    itemView.headImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"0" ofType:@"jpg"]];
    itemView.nameLabel.attributedText = [self getnameStr:nameStr ForImageStr:rankImageStr];
    itemView.concentLabel.text = contentStr;
    [self addSubview:itemView];
    [self.saveArray addObject:itemView];

    [self barrageStart:itemView];
}

- (NSMutableAttributedString *)getnameStr:(NSString *)nameStr ForImageStr:(NSString *)imageStr
{
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:nameStr];
    if (nameStr.length > 0) {
        NSShadow *shadw = [[NSShadow alloc] init];
        shadw.shadowColor =  [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
        shadw.shadowOffset = CGSizeMake(0, 1);
        shadw.shadowBlurRadius = 0.5;
//        [UIColor colorWithRed:253 / 255.0 green:216 / 255.0 blue:83 / 255.0 alpha:1.0]
        NSDictionary *dic = @{NSForegroundColorAttributeName:[UIColor colorWithRed:251.0/255.0 green:197.0/255.0 blue:120.0/255.0 alpha:1],
                              NSShadowAttributeName:shadw,
                              NSStrokeWidthAttributeName:@(-0.4),
                              NSStrokeColorAttributeName:[UIColor whiteColor]};
        [att addAttributes:dic range:NSMakeRange(0, nameStr.length)];
    }
    if(imageStr.length > 0) {
        NSTextAttachment *ment = [[NSTextAttachment alloc] init];
        ment.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageStr ofType:@"png"]];
        ment.bounds = CGRectMake(5, - 3, 32, 16);
        NSAttributedString *imageAtt = [NSAttributedString attributedStringWithAttachment:ment];
        [att appendAttributedString:imageAtt];
    }
    return att;
}

- (void)barrageStart:(BarrageItemView *)itemView
{
    int lineValueCount = (int)self.itemDic.allKeys.count;
    if (lineValueCount == 0) {
        itemView.currentLineCount = 0;
        [self playBarrayeView:itemView];
        return;
    }
    
    for (int i = 0; i < lineValueCount; i++){
        BarrageItemView *oldItemView = self.itemDic[@(i)];
     
        if (!oldItemView) {
            break;
        }
        if ([self judgeIsRunintoWithFirstBarrageItemView:itemView OldItemView:oldItemView]) {
            itemView.currentLineCount = i;
            [self playBarrayeView:itemView];
            break;
        } else if (i == lineValueCount - 1) {
            if (lineValueCount < self.maxLineCount) {
                itemView.currentLineCount = i+1;
                [self playBarrayeView:itemView];
                break;
            } else {
                if (_barrageTimer == nil) {
                    _barrageTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
                    [_barrageTimer fire];
                }
            }
        }
    }
    self.lastItemView = itemView;
 
}

- (void)timerAction
{
    if (self.saveArray.count > 0) {
        BarrageItemView *itemView = [self.saveArray firstObject];
        [self barrageStart:itemView];
    } else {
        [self timerInval];
    }
}

- (void)timerInval
{
    if (_barrageTimer != nil) {
        if (_barrageTimer.isValid) {
            [_barrageTimer invalidate];
        }
        _barrageTimer = nil;
    }
}

// 检测碰撞 -- 默认从右到左
- (BOOL)judgeIsRunintoWithFirstBarrageItemView:(BarrageItemView *)itemView OldItemView:(BarrageItemView *)oldItemView
{
    unsigned long long currentTime = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000 ;
     CGFloat oldStartTime = (currentTime - oldItemView.startTime) / 1000;
    if (_isUniform) {
        
        if  ((oldStartTime * kSpeed - kWidth(oldItemView)) > 50) {
            return YES;
        } else {
            return NO;
        }
        
//        // 固定速度
//        if (oldStartTime > itemView.durationTime) {
//            return YES;
//        }
//        CGFloat timeS = kWidth(oldItemView)/kSpeed;
//        if (timeS >= oldStartTime) {
//            return NO;
//        }
//        CGFloat timeE = kX(itemView)/kSpeed;
//        if (timeE <= oldStartTime) {
//            return NO;
//        }
//        return YES;
        
    } else {
        //固定时间
        CGFloat currentSpeed = [self getSpeedFromBarrageItemView:itemView];
        CGFloat oldSpeed = [self getSpeedFromBarrageItemView:oldItemView];
        
        if (oldStartTime > kDuration) {
            return YES;
        }
        CGFloat oldRight = oldStartTime * oldSpeed;
        if (oldRight < kWidth(oldItemView)) {
            return NO;
        }
        
        CGFloat lastTime = kDuration - oldStartTime;
        
        CGFloat currentLeft = lastTime * currentSpeed;
        if (currentLeft > ScreenWidth) {
            return NO;
        }
        
        return YES;
    }
}

// 计算速度
- (CGFloat)getSpeedFromBarrageItemView:(BarrageItemView *)itemView
{
    return (ScreenWidth + kWidth(itemView)) / kDuration;
}

- (void)playBarrayeView:(BarrageItemView *)itemView
{
    [self.saveArray removeObject:itemView];
    itemView.frame = CGRectMake(ScreenWidth, kHeight(self) - (itemView.currentLineCount + 1) * (_maxLineCount == 1?lineHeight : lineSpac + lineHeight),  kWidth(itemView), kHeight(itemView));
    itemView.startTime = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
    self.itemDic[@(itemView.currentLineCount)] = itemView;
    [UIView setAnimationsEnabled:YES];
    [UIView animateWithDuration:itemView.durationTime delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        itemView.frame = CGRectMake(kWidth(itemView) * (-1.0), kHeight(self) - (itemView.currentLineCount + 1) * (_maxLineCount == 1?lineHeight : lineSpac + lineHeight), kWidth(itemView), kHeight(itemView));
        
    } completion:^(BOOL finished) {
        [itemView removeFromSuperview];
    }];
}

- (void)dealloc
{
//    [self timerInval];
    NSLog(@"barrageView______dealloc");
}

@end
