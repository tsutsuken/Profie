//
//  LVUtility.h
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/05/14.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LVUtility : NSObject

+ (void)followUserEventually:(User *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)unfollowUserEventually:(User *)user;

//Return nil if none was found.
+ (Answer *)answerOfCurrentUserForQuestion:(Question *)question;

@end
