//
//  UserCell.h
//  Profie
//
//  Created by Ken Tsutsumi on 2014/09/14.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import <Parse/Parse.h>

@interface UserCell : PFTableViewCell

@property (weak, nonatomic) IBOutlet PFRoundedImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *fullnameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *followActionButton;

@end
