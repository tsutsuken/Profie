//
//  EditAnswerViewController.h
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/05/07.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditAnswerViewController : UIViewController <UIActionSheetDelegate, LVShareKitTwitterDelegate>

@property (strong, nonatomic) Question *question;
@property (strong, nonatomic) PFObject *answer;

@end
