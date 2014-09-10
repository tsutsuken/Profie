//
//  SignUpViewController.h
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/06/28.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LVEditableCell.h"

@protocol SignUpViewControllerDelegate;

typedef enum {
    SignUpViewItemIndexFullname = 0,
	SignUpViewItemIndexUsername = 1,
	SignUpViewItemIndexEmail = 2,
    SignUpViewItemIndexPassword = 3
} SignUpViewItemIndex;

@interface SignUpViewController : UITableViewController <UITextViewDelegate ,UIActionSheetDelegate>

@property (nonatomic, assign) id <SignUpViewControllerDelegate> delegate;

@end

@protocol SignUpViewControllerDelegate
- (void)signUpViewController:(SignUpViewController *)signUpController didSignUpUser:(User *)user;
@end