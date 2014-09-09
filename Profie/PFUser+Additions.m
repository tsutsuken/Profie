//
//  PFUser+Additions.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/06/09.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "PFUser+Additions.h"

@implementation PFUser (Additions)

- (BOOL)isEqualToCurrentUser
{
    BOOL isEqualToCurrentUser = NO;
    
    if ([self.objectId isEqualToString:[[PFUser currentUser] objectId]]) {
        isEqualToCurrentUser = YES;
    }
    
    return isEqualToCurrentUser;
}

@end
