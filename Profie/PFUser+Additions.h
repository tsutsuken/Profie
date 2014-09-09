//
//  PFUser+Additions.h
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/06/09.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import <Parse/Parse.h>

@interface PFUser (Additions)

//isAuthenticatedだと、queryで取得したPFUserでは、NOになってしまう
- (BOOL)isEqualToCurrentUser;

@end
