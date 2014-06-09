//
//  LUUtility.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/05/14.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "LUUtility.h"

@implementation LUUtility

+ (void)followUserEventually:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock
{
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    PFObject *followActivity = [PFObject objectWithClassName:kLUActivityClassKey];
    [followActivity setObject:[PFUser currentUser] forKey:kLUActivityFromUserKey];
    [followActivity setObject:user forKey:kLUActivityToUserKey];
    [followActivity setObject:kLUActivityTypeFollow forKey:kLUActivityTypeKey];
    [followActivity saveEventually:completionBlock];
}

+ (void)unfollowUserEventually:(PFUser *)user
{
    PFQuery *query = [PFQuery queryWithClassName:kLUActivityClassKey];
    [query whereKey:kLUActivityFromUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kLUActivityToUserKey equalTo:user];
    [query whereKey:kLUActivityTypeKey equalTo:kLUActivityTypeFollow];
    [query findObjectsInBackgroundWithBlock:^(NSArray *followActivities, NSError *error) {
        // While normally there should only be one follow activity returned, we can't guarantee that.
        
        if (!error) {
            for (PFObject *followActivity in followActivities) {
                [followActivity deleteEventually];
            }
        }
    }];
}

@end
