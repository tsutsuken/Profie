//
//  Question.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/07/23.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "Question.h"
#import <Parse/PFObject+Subclass.h>

@implementation Question

@dynamic title;
@dynamic auther;
@dynamic answerCount;

+ (NSString *)parseClassName
{
    return @"Question";
}

- (NSString *)titleWithTag
{
    return [NSString stringWithFormat:@"#%@", self.title];
}

- (void)incrementAnswerCount
{
    self.answerCount++;
    [self saveInBackground];
}

- (void)decrementAnswerCount
{
    self.answerCount--;
    [self saveInBackground];
}

@end
