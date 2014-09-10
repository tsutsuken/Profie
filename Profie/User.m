//
//  User.m
//  Profie
//
//  Created by Ken Tsutsumi on 2014/09/10.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "User.h"

@implementation User

@dynamic fullname;
@dynamic profilePictureSmall;
@dynamic profilePictureMedium;
@dynamic profilePictureLarge;

+ (User *)user
{
    return (User *)[PFUser user];
}

+ (User *)currentUser
{
    return (User *)[PFUser currentUser];
}

- (BOOL)isEqualToCurrentUser
{
    BOOL isEqualToCurrentUser = NO;
    
    if ([self.objectId isEqualToString:[[User currentUser] objectId]]) {
        isEqualToCurrentUser = YES;
    }
    
    return isEqualToCurrentUser;
}

@end
