//
//  LVConstants.h
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/05/11.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

typedef enum {
    LVTabBarItemIndexAnswerTimeline = 0,
	LVTabBarItemIndexRecommendQuestion = 1,
	LVTabBarItemIndexProfile = 2
} LVTabBarControllerViewControllerIndex;

#pragma mark - NSNotification
extern NSString *const kLVNotificationDidEditAnswer;
extern NSString *const kLVNotificationDidDeleteAnswer;

#pragma mark - PFObject Common Class
// Field keys
extern NSString *const kLVCommonObjectIdKey;
extern NSString *const kLVCommonCreatedAtKey;
extern NSString *const kLVCommonUpdatedAtKey;

#pragma mark - PFObject User Class
// Field keys
extern NSString *const kLVUserFullnameKey;
extern NSString *const kLVUserUsernameKey;
extern NSString *const kLVUserProfilePicSmallKey;
extern NSString *const kLVUserProfilePicMediumKey;
extern NSString *const kLVUserProfilePicLargeKey;

#pragma mark - PFObject Activity Class
// Class key
extern NSString *const kLVActivityClassKey;
// Field keys
extern NSString *const kLVActivityTypeKey;
extern NSString *const kLVActivityFromUserKey;
extern NSString *const kLVActivityToUserKey;
// Type values
extern NSString *const kLVActivityTypeFollow;

#pragma mark - PFObject Question Class
// Class key
extern NSString *const kLVQuestionClassKey;
// Field keys
extern NSString *const kLVQuestionAnswerCountKey;

#pragma mark - PFObject Answer Class
// Class key
extern NSString *const kLVAnswerClassKey;
// Field keys
extern NSString *const kLVAnswerAutherKey;
extern NSString *const kLVAnswerQuestionKey;
extern NSString *const kLVAnswerQuestionIdKey;


