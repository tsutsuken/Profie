//
//  LUConstants.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/05/11.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "LUConstants.h"

#pragma mark - TTTTimeIntervalFormatter
NSString *const kLUFormatterPastDeicticExpression        = @"";
NSString *const kLUFormatterSuffixExpressionFormat       = @"%@%@";

#pragma mark - NSNotification
NSString *const LUEditAnswerViewControllerUserDidEditAnswerNotification   = @"com.lvup.SuperProfile.editAnswerViewController.userDidEditAnswerNotification";
NSString *const LUQuestionDetailViewControllerUserDidDeleteAnswerNotification   = @"com.lvup.SuperProfile.questionDetailViewController.userDidDeleteAnswerNotification";

#pragma mark - PFObject Common Class
// Field keys
NSString *const kLUCommonObjectIdKey        = @"objectId";
NSString *const kLUCommonCreatedAtKey       = @"createdAt";

#pragma mark - User Class
// Field keys
NSString *const kLUUserUsernameKey        = @"username";
NSString *const kLUUserProfilePicSmallKey  = @"profilePictureSmall";
NSString *const kLUUserProfilePicMediumKey = @"profilePictureMedium";
NSString *const kLUUserProfilePicLargeKey = @"profilePictureLarge";


#pragma mark - Activity Class
// Class key
NSString *const kLUActivityClassKey = @"Activity";

// Field keys
NSString *const kLUActivityTypeKey        = @"type";
NSString *const kLUActivityFromUserKey    = @"fromUser";
NSString *const kLUActivityToUserKey      = @"toUser";

// Type values
NSString *const kLUActivityTypeFollow     = @"follow";


#pragma mark - Question Class
// Class key
NSString *const kLUQuestionClassKey = @"Question";

// Field keys
NSString *const kLUQuestionTitleKey        = @"title";
NSString *const kLUQuestionAutherKey       = @"auther";
NSString *const kLUQuestionAnswerCountKey  = @"answerCount";


#pragma mark - Answer Class
// Class key
NSString *const kLUAnswerClassKey = @"Answer";

// Field keys
NSString *const kLUAnswerTitleKey        = @"title";
NSString *const kLUAnswerAutherKey       = @"auther";
NSString *const kLUAnswerQuestionKey     = @"question";
NSString *const kLUAnswerQuestionIdKey   = @"questionId";
