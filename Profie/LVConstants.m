//
//  LVConstants.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/05/11.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "LVConstants.h"

#pragma mark - NSNotification
NSString *const LVEditAnswerViewControllerUserDidEditAnswerNotification   = @"com.lvup.SuperProfile.editAnswerViewController.userDidEditAnswerNotification";
NSString *const LVQuestionDetailViewControllerUserDidDeleteAnswerNotification   = @"com.lvup.SuperProfile.questionDetailViewController.userDidDeleteAnswerNotification";

#pragma mark - PFObject Common Class
// Field keys
NSString *const kLVCommonObjectIdKey        = @"objectId";
NSString *const kLVCommonCreatedAtKey       = @"createdAt";
NSString *const kLVCommonUpdatedAtKey       = @"updatedAt";

#pragma mark - User Class
// Field keys
NSString *const kLVUserUsernameKey        = @"username";
NSString *const kLVUserProfilePicSmallKey  = @"profilePictureSmall";
NSString *const kLVUserProfilePicMediumKey = @"profilePictureMedium";
NSString *const kLVUserProfilePicLargeKey = @"profilePictureLarge";


#pragma mark - Activity Class
// Class key
NSString *const kLVActivityClassKey = @"Activity";

// Field keys
NSString *const kLVActivityTypeKey        = @"type";
NSString *const kLVActivityFromUserKey    = @"fromUser";
NSString *const kLVActivityToUserKey      = @"toUser";

// Type values
NSString *const kLVActivityTypeFollow     = @"follow";


#pragma mark - Question Class
// Class key
NSString *const kLVQuestionClassKey = @"Question";

// Field keys
NSString *const kLVQuestionAnswerCountKey  = @"answerCount";


#pragma mark - Answer Class
// Class key
NSString *const kLVAnswerClassKey = @"Answer";

// Field keys
NSString *const kLVAnswerAutherKey       = @"auther";
NSString *const kLVAnswerQuestionKey     = @"question";
NSString *const kLVAnswerQuestionIdKey   = @"questionId";
