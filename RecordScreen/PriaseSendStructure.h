//
//  PriaseSendStructure.h
//  Yddworkspace
//
//  Created by ispeak on 2017/2/25.
//  Copyright © 2017年 QH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PriaseSendStructure : NSObject

@property (nonatomic ,assign)  NSInteger uid;

@property (nonatomic ,assign)  int iconIndex;
@property (nonatomic ,retain)  NSString*username;
@property (nonatomic ,retain)  NSString*content;

@property (nonatomic ,assign) int rank;

@property (nonatomic, assign) int rankCustom;
@property (nonatomic, strong) NSString*imagePathStr;



@end
