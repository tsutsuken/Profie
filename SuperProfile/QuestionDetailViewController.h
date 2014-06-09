//
//  QuestionDetailViewController.h
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/05/29.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import <Parse/Parse.h>
#import "EditAnswerViewController.h"

@interface QuestionDetailViewController : PFQueryTableViewController

@property (nonatomic, strong) PFObject *question;
@property (nonatomic, strong) PFObject *answer;
@property (nonatomic, strong) PFUser *user;

@end
