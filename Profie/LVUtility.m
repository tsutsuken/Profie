//
//  LVUtility.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/05/14.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "LVUtility.h"

@implementation LVUtility

+ (void)followUserEventually:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock
{
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    PFObject *followActivity = [PFObject objectWithClassName:kLVActivityClassKey];
    [followActivity setObject:[PFUser currentUser] forKey:kLVActivityFromUserKey];
    [followActivity setObject:user forKey:kLVActivityToUserKey];
    [followActivity setObject:kLVActivityTypeFollow forKey:kLVActivityTypeKey];
    [followActivity saveEventually:completionBlock];
    
    [ANALYTICS trackEvent:kAnEventFollow sender:self];
}

+ (void)unfollowUserEventually:(PFUser *)user
{
    PFQuery *query = [PFQuery queryWithClassName:kLVActivityClassKey];
    [query whereKey:kLVActivityFromUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kLVActivityToUserKey equalTo:user];
    [query whereKey:kLVActivityTypeKey equalTo:kLVActivityTypeFollow];
    [query findObjectsInBackgroundWithBlock:^(NSArray *followActivities, NSError *error) {
        // While normally there should only be one follow activity returned, we can't guarantee that.
        
        if (!error) {
            for (PFObject *followActivity in followActivities) {
                [followActivity deleteEventually];
            }
        }
    }];
    
    [ANALYTICS trackEvent:kAnEventUnFollow sender:self];
}

@end
