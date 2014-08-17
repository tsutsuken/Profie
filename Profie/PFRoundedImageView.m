//
//  PFRoundedImageView.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/05/29.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "PFRoundedImageView.h"

@implementation PFRoundedImageView

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super initWithCoder:decoder];
    if (!self) {
        return nil;
    }
    
    self.layer.cornerRadius = self.frame.size.width / 2;
    self.layer.masksToBounds = YES;
    
    [self setTapGestureRecognizer];
    
    return self;
}

- (void)setTapGestureRecognizer
{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPushSelf)];
    tapRecognizer.delegate = self;
    self.userInteractionEnabled = YES;
    
    [self addGestureRecognizer:tapRecognizer];
}

- (void)didPushSelf
{
    [self.delegate didPushImageView:self];
}

- (void)showProfileViewFromViewController:(UIViewController *)delegateViewController
{
    UIStoryboard* mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ProfileViewController *profileVc = (ProfileViewController *) [mainStoryBoard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    profileVc.user = self.user;
    
    [delegateViewController.navigationController pushViewController:profileVc animated:YES];
}

@end
