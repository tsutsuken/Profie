//
//  AppDelegate.h
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/04/26.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FirstViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (NSURL *)applicationDocumentsDirectory;
- (void)presentTabBarController;
- (void)logOut;

@end
