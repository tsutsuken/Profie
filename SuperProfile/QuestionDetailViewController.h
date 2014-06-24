//
//  QuestionDetailViewController.h
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/05/29.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import <Parse/Parse.h>
#import "EditAnswerViewController.h"

typedef enum {
	LUActionSheetTagCurrentUser = 0,
	LUActionSheetTagOtherUser = 1,
} LUActionSheetTag;

typedef enum {
    LUAnswerViewItemTagProfileImageView = 1,
	LUAnswerViewItemTagUserNameLabel = 2,
    LUAnswerViewItemTagTimeLabel = 3,
	LUAnswerViewItemTagAnswerLabel = 4,
} LUAnswerViewItemTag;

@interface QuestionDetailViewController : PFQueryTableViewController <UIActionSheetDelegate, PFRoundedImageViewDelegate, LVTouchableLabelDelegate, GADBannerViewDelegate>

@property (nonatomic, strong) PFObject *question;
@property (nonatomic, strong) PFObject *answer;
@property (nonatomic, strong) PFUser *user;

@end
