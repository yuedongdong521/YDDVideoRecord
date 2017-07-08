//
//  BarrageView.h
//  ViewsTalk
//
//  Created by ispeak on 2017/1/10.
//  Copyright © 2017年 ydd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PriaseSendStructure.h"

@interface BarrageView : UIView

@property(nonatomic, assign) int maxLineCount;

/*********
 弹幕速度是否一致
**********/
@property(nonatomic, assign) BOOL isUniform;

- (void)sendBarrageForPraise:(PriaseSendStructure *)praise;
- (void)timerInval;


@end
