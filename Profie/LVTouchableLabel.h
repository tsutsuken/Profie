//
//  LVTouchableLabel.h
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/06/15.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LVTouchableLabelDelegate;

@interface LVTouchableLabel : UILabel <UIGestureRecognizerDelegate>

@property (nonatomic, assign) id <LVTouchableLabelDelegate> delegate;
@property (nonatomic, strong) User *user;

- (void)showProfileViewFromViewController:(UIViewController *)delegateViewController;

@end

@protocol LVTouchableLabelDelegate

- (void)didPushLabel:(LVTouchableLabel *)label;

@end