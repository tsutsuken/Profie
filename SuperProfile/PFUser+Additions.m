//
//  PFUser+Additions.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/06/09.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "PFUser+Additions.h"

@implementation PFUser (Additions)

- (BOOL)isCurrentUser
{
    BOOL isCurrentUser = NO;
    
    if ([self.objectId isEqualToString:[[PFUser currentUser] objectId]]) {
        isCurrentUser = YES;
    }
    
    LOG_BOOL(isCurrentUser, @"isCurrentUser");
    
    return isCurrentUser;
}

@end
