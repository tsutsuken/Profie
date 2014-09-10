//
//  User.h
//  Profie
//
//  Created by Ken Tsutsumi on 2014/09/10.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import <Parse/Parse.h>

@interface User : PFUser<PFSubclassing>

@property (retain) NSString *fullname;
@property (retain) PFFile *profilePictureSmall;
@property (retain) PFFile *profilePictureMedium;
@property (retain) PFFile *profilePictureLarge;

//Returns a new User object.
+ (User *)user;
+ (User *)currentUser;

- (BOOL)isEqualToCurrentUser;

@end
