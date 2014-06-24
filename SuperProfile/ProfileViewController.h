//
//  ProfileViewController.h
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/05/08.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "EditProfileViewController.h"

@interface ProfileViewController : PFQueryTableViewController <GADBannerViewDelegate>

@property (nonatomic, strong) PFUser *user;

@end
