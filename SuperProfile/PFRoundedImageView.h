//
//  PFRoundedImageView.h
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/05/29.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import <Parse/Parse.h>

@protocol PFRoundedImageViewDelegate;

@interface PFRoundedImageView : PFImageView <UIGestureRecognizerDelegate>

@property (nonatomic, assign) id <PFRoundedImageViewDelegate> delegate;
@property (nonatomic, strong) PFUser *user;

- (void)showProfileViewFromViewController:(UIViewController *)delegateViewController;

@end

@protocol PFRoundedImageViewDelegate

- (void)didPushImageView:(PFRoundedImageView *)imageView;

@end
