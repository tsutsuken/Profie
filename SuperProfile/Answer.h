//
//  Answer.h
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/07/23.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import <Parse/Parse.h>

@interface Answer : PFObject<PFSubclassing>

@property (retain) NSString *title;
@property (retain) PFUser *auther;
@property (retain) Question *question;
@property (retain) NSString *questionId;


+ (NSString *)parseClassName;

@end
