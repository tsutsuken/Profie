//
//  LUConstants.h
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/05/11.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

typedef enum {
	LUTabBarItemIndexTimeline = 0,
	LUTabBarItemIndexRecommendQuestion = 1,
	LUTabBarItemIndexProfile = 2
} LUTabBarControllerViewControllerIndex;

#pragma mark - TTTTimeIntervalFormatter
extern NSString *const kLUFormatterPastDeicticExpression;
extern NSString *const kLUFormatterSuffixExpressionFormat;

#pragma mark - NSNotification
extern NSString *const LUEditAnswerViewControllerUserDidEditAnswerNotification;
extern NSString *const LUQuestionDetailViewControllerUserDidDeleteAnswerNotification;

#pragma mark - PFObject Common Class
// Field keys
extern NSString *const kLUCommonObjectIdKey;
extern NSString *const kLUCommonCreatedAtKey;

#pragma mark - PFObject User Class
// Field keys
extern NSString *const kLUUserUsernameKey;
extern NSString *const kLUUserProfilePicSmallKey;
extern NSString *const kLUUserProfilePicMediumKey;
extern NSString *const kLUUserProfilePicLargeKey;


#pragma mark - PFObject Activity Class
// Class key
extern NSString *const kLUActivityClassKey;

// Field keys
extern NSString *const kLUActivityTypeKey;
extern NSString *const kLUActivityFromUserKey;
extern NSString *const kLUActivityToUserKey;

// Type values
extern NSString *const kLUActivityTypeFollow;


#pragma mark - PFObject Question Class
// Class key
extern NSString *const kLUQuestionClassKey;

// Field keys
extern NSString *const kLUQuestionTitleKey;
extern NSString *const kLUQuestionAutherKey;
extern NSString *const kLUQuestionAnswerCountKey;


#pragma mark - PFObject Answer Class
// Class key
extern NSString *const kLUAnswerClassKey;

// Field keys
extern NSString *const kLUAnswerTitleKey;
extern NSString *const kLUAnswerAutherKey;
extern NSString *const kLUAnswerQuestionKey;
extern NSString *const kLUAnswerQuestionIdKey;


