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
    [self configureAnalyticsSystem];
    [self configureiRate];
    
    return YES;
}

- (void)configureAppearance
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
#if DEBUG
    [UINavigationBar appearance].barTintColor = kColorNavigationBarForTest;
#else
    [UINavigationBar appearance].barTintColor = kColorNavigationBar;
#endif
    
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    [[UITabBar appearance] setTintColor:kColorNavigationBar];
}

- (void)configureParse
{
#if DEBUG
    NSLog(@"Parse_TestDB");
    [Parse setApplicationId:@"AGI9zKvHt3kFh0L6hPP8s00GtFVLdGNrhRzWXFDK" clientKey:@"Wb5G0dMXWc7VEG65PhYxZZbePzxyNc577XSm90UH"];
#else
    NSLog(@"Parse_MasterDB");
    [Parse setApplicationId:@"Xm1YKW4pz3tkVYZYipveTbo9N5LPY2zwsbQhvtk9" clientKey:@"N4gQ1oQb8V4SVWxHD5ezlZTmu16tTRQkJFeJXPbf"];
#endif
    
    PFACL *defaultACL = [PFACL ACL];//Read・Write共に、全員にNo
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];//CurrentUserにRead・Write権を付与
    
    [Question registerSubclass];
    [Answer registerSubclass];
}

- (void)configureAnalyticsSystem
{
#if !DEBUG
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
    [[GAI sharedInstance] trackerWithTrackingId:kGoogleAnalyticsId];
    
    [Crashlytics startWithAPIKey:@"05bba97476be46a19cd9fe6700e03312cdd38e05"];
#endif
}

- (void)configureiRate
{
    //① ＋「②のどちらか」が満たされたら発動
    
    //①
    [iRate sharedInstance].daysUntilPrompt = 2;//アプリの利用開始からの日数。
    
    //②
    [iRate sharedInstance].usesUntilPrompt = 4;//アプリの起動回数
    //[iRate sharedInstance].eventsUntilPrompt = 10;//特定のイベント
    
    //[iRate sharedInstance].appStoreID = 668425656;
    //[[iRate sharedInstance] promptIfNetworkAvailable];
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
    [[[LVShareKitTwitter alloc] init] logout];
    
    UINavigationController *nvc = (UINavigationController *)self.window.rootViewController;
    [nvc popToRootViewControllerAnimated:NO];
}


@end
