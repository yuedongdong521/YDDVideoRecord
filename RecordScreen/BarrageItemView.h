//
//  BarrageItemView.h
//  ViewsTalk
//
//  Created by ispeak on 2017/1/10.
//  Copyright © 2017年 ydd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BarrageItemView : UIView

@property (nonatomic, strong)UIImageView *headImage;
@property (nonatomic, strong)UILabel *nameLabel;
@property (nonatomic, strong)UILabel *concentLabel;
/*************
 当前弹幕航道
 *************/
@property (nonatomic, assign)int currentLineCount;
@property (nonatomic, assign)unsigned long long startTime;
@property (nonatomic, assign)unsigned int durationTime;

- (instancetype)initWithFrame:(CGRect)frame WithNameWidth:(CGFloat)nameWidth WithContentWidth:(CGFloat)contentWidth;
- (instancetype)initTowWithFrame:(CGRect)frame WithContentWidth:(CGFloat)contentWidth;
@end
