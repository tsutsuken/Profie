//
//  AppDelegate.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/04/26.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self configureAppearance];
    [self configureParse];

    return YES;
}

- (void)configureParse
{
    [Parse setApplicationId:@"Xm1YKW4pz3tkVYZYipveTbo9N5LPY2zwsbQhvtk9" clientKey:@"N4gQ1oQb8V4SVWxHD5ezlZTmu16tTRQkJFeJXPbf"];
    
    PFACL *defaultACL = [PFACL ACL];//Read・Write共に、全員にNo
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];//CurrentUserにRead・Write権を付与
    
    [Question registerSubclass];
    [Answer registerSubclass];
}

- (void)configureAppearance
{
    [UINavigationBar appearance].barTintColor = kColorNavigationBar;
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - AppDelegate

- (void)presentTabBarController
{
    UIStoryboard* mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITabBarController *tabBarController = (UITabBarController *)[mainStoryBoard instantiateViewControllerWithIdentifier:@"MainTabBarController"];
    
    UINavigationController *nvcForProfileView = (UINavigationController *)[tabBarController.viewControllers objectAtIndex:LVTabBarItemIndexProfile];
    ProfileViewController *profileView = (ProfileViewController *)nvcForProfileView.topViewController;
    profileView.user = [PFUser currentUser];
    
    
    UINavigationController *nvc = (UINavigationController *)self.window.rootViewController;
    FirstViewController *firstViewController = (FirstViewController *)nvc.topViewController;
    
    [nvc setViewControllers:@[firstViewController, tabBarController] animated:NO];
}

- (void)logOut
{
    [PFUser logOut];
    
    UINavigationController *nvc = (UINavigationController *)self.window.rootViewController;
    [nvc popToRootViewControllerAnimated:NO];
}


@end
