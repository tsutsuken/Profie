//
//  Answer.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/07/23.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "Answer.h"
#import <Parse/PFObject+Subclass.h>

@implementation Answer

@dynamic title;
@dynamic auther;
@dynamic question;
@dynamic questionId;

+ (NSString *)parseClassName
{
    return @"Answer";
}

@end
