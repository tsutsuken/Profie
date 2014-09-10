//
//  UserListViewController.h
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/05/12.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import <Parse/Parse.h>

typedef NS_ENUM(NSInteger, UserListViewDataType) {
    UserListViewDataTypeFollowing,
    UserListViewDataTypeFollower
};

@interface UserListViewController : PFQueryTableViewController

@property (nonatomic, strong) User *user;
@property (nonatomic, assign) UserListViewDataType dataType;

@end
