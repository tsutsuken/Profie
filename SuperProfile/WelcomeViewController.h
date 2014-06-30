//
//  WelcomeViewController.h
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/06/24.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "SignUpViewController.h"
#import "LogInViewController.h"

@interface WelcomeViewController : UIViewController <PFLogInViewControllerDelegate, SignUpViewControllerDelegate, LogInViewControllerDelegate>

@end
