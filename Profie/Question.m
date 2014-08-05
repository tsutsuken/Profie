//
//  Question.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/07/23.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "Question.h"

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

@end
