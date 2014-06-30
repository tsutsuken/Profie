//
//  LogInViewController.h
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/06/30.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LVEditableCell.h"

@protocol LogInViewControllerDelegate;

@interface LogInViewController : UITableViewController

@property (nonatomic, assign) id <LogInViewControllerDelegate> delegate;

@end

@protocol LogInViewControllerDelegate
- (void)logInViewController:(LogInViewController *)logInController didLogInUser:(PFUser *)user;
@end