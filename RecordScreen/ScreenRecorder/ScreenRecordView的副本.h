//
//  ScreenRecordView.h
//  ViewsTalk
//
//  Created by ispeak on 2017/4/10.
//  Copyright © 2017年 ydd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RPPreviewViewController;
@interface ScreenRecordView : UIView

@property (nonatomic, strong) UIView *recordView;

@property (nonatomic, copy) void (^hiddenRecordView)(BOOL ishidden);

@property (nonatomic, copy) void (^finishRecord)(NSString *voidePath);

@property (nonatomic, copy) void (^replayKitFinish)(RPPreviewViewController * previewViewController, NSError *error);

- (void)hiddenAnimo:(BOOL)isHidden;

@end
