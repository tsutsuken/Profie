//
//  Question.h
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/07/23.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import <Parse/Parse.h>

@interface Question : PFObject<PFSubclassing>

@property (retain) NSString *title;
@property (retain) PFUser *auther;
@property int answerCount;

+ (NSString *)parseClassName;
- (NSString *)titleWithTag;

@end
