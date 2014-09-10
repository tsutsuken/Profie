//
//  LVUtility.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/05/14.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "LVUtility.h"

@implementation LVUtility

+ (void)followUserEventually:(User *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock
{
    if ([[user objectId] isEqualToString:[[User currentUser] objectId]]) {
        return;
    }
    
    PFObject *followActivity = [PFObject objectWithClassName:kLVActivityClassKey];
    [followActivity setObject:[User currentUser] forKey:kLVActivityFromUserKey];
    [followActivity setObject:user forKey:kLVActivityToUserKey];
    [followActivity setObject:kLVActivityTypeFollow forKey:kLVActivityTypeKey];
    [followActivity saveEventually:completionBlock];
    
    [ANALYTICS trackEvent:kAnEventFollow sender:self];
}

+ (void)unfollowUserEventually:(User *)user
{
    PFQuery *query = [PFQuery queryWithClassName:kLVActivityClassKey];
    [query whereKey:kLVActivityFromUserKey equalTo:[User currentUser]];
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

+ (Answer *)answerOfCurrentUserForQuestion:(Question *)question
{
    Answer *myAnswer;
    
    PFQuery *query = [PFQuery queryWithClassName:kLVAnswerClassKey];
    [query whereKey:kLVAnswerQuestionKey equalTo:question];
    [query whereKey:kLVAnswerAutherKey equalTo:[User currentUser]];
    [query includeKey:kLVAnswerQuestionKey];
    [query includeKey:kLVAnswerAutherKey];
    
    //Return nil if none was found.
    myAnswer = (Answer *)[query getFirstObject];
    
    return myAnswer;
}

@end
