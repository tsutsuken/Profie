//
//  ShareSettingViewController.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/07/21.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "ShareSettingViewController.h"

@interface ShareSettingViewController ()
@property (strong, nonatomic) LVShareKitTwitter *shareKitTwitter;
@property (weak, nonatomic) IBOutlet UISwitch *switchView;
@end

@implementation ShareSettingViewController

#pragma mark - Initialization
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"ShareSettingView_Title", nil);
    
    self.shareKitTwitter = [[LVShareKitTwitter alloc] init];
    self.shareKitTwitter.delegate = self;
    
    [self configureTwitterCell];
}

- (void)configureTwitterCell
{
    [self.switchView addTarget:self action:@selector(didChangeValueForSwitch:) forControlEvents:UIControlEventValueChanged];
    
    if ([self.shareKitTwitter isAuthorized]) {
        self.switchView.on = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [ANALYTICS trackView:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Twitter
- (void)didChangeValueForSwitch:(UISwitch *)switchView
{
    if (switchView.on) {
        [self.shareKitTwitter authorizeInViewController:self];
    } else {
        [self.shareKitTwitter logout];
	}
}

#pragma mark ShareKitTwitter delegate
- (void)shareKitDidFailToAuthorize
{
    self.switchView.on = NO;
}

@end
