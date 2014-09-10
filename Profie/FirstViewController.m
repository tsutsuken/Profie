//
//  FirstViewController.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/06/24.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([User currentUser]) {
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
        
        // Refresh current user with server side data -- checks if user is still valid and so on
        [[User currentUser] refreshInBackgroundWithTarget:self selector:@selector(refreshCurrentUserCallbackWithResult:error:)];
    }
    else {
        [self showWelcomeView];
    }
}

- (void)refreshCurrentUserCallbackWithResult:(PFObject *)refreshedObject error:(NSError *)error
{
    // A kPFErrorObjectNotFound error on currentUser refresh signals a deleted user
    if (error && error.code == kPFErrorObjectNotFound) {
        NSLog(@"User does not exist.");
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] logOut];
        return;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Show Other View

- (void)showWelcomeView
{
    [self performSegueWithIdentifier:@"showWelcomeView" sender:self];
}

@end
