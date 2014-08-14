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
	LVActionSheetTagCurrentUser = 0,
	LVActionSheetTagOtherUser = 1,
} LVActionSheetTag;

typedef enum {
    LVAnswerViewItemTagProfileImageView = 1,
	LVAnswerViewItemTagUserNameLabel = 2,
    LVAnswerViewItemTagTimeLabel = 3,
	LVAnswerViewItemTagAnswerLabel = 4,
} LVAnswerViewItemTag;

@interface QuestionDetailViewController : PFQueryTableViewController <UIActionSheetDelegate, PFRoundedImageViewDelegate, LVTouchableLabelDelegate, GADBannerViewDelegate>

@property (nonatomic, strong) Question *question;
@property (nonatomic, strong) Answer *answer;
@property (nonatomic, strong) PFUser *user;

@end
