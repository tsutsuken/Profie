//
//  SettingViewController.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/07/18.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

#pragma mark - Initialization
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(didPushDoneButton)];
    
    self.title = NSLocalizedString(@"SettingView_Title", nil);
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

#pragma mark - CloseView

- (void)didPushDoneButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.textLabel.text = NSLocalizedString(@"SettingView_Cell_ProfileSetting", nil);
        return cell;
    } else if (indexPath.section == 1) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.textLabel.text = NSLocalizedString(@"SettingView_Cell_ShareSetting", nil);
        return cell;
	} else if (indexPath.section == 2) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.textLabel.text = NSLocalizedString(@"SettingView_Cell_Feedback", nil);
        return cell;
	} else {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogOutCell" forIndexPath:indexPath];
        cell.textLabel.text = NSLocalizedString(@"SettingView_Cell_LogOut", nil);
        return cell;
	}
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self showProfileSettingView];
    } else if (indexPath.section == 1) {
        [self showShareSettingView];
    } else if (indexPath.section == 2) {
        [self showFeedbackView];
    } else {
		[self logOut];
	}
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - LogOut

- (void)logOut
{
    [self dismissViewControllerAnimated:NO completion:^{
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] logOut];
    }];
}

#pragma mark - Show Other View
#pragma mark ShareSettingView

- (void)showProfileSettingView
{
    [self performSegueWithIdentifier:@"showProfileSettingView" sender:self];
}

#pragma mark ShareSettingView

- (void)showShareSettingView
{
    [self performSegueWithIdentifier:@"showShareSettingView" sender:self];
}

#pragma mark FeedbackView

- (void)showFeedbackView
{
    NSArray *topics = [self topics];
    
    CTFeedbackViewController *vc = [CTFeedbackViewController controllerWithTopics:topics localizedTopics:topics];
    vc.toRecipients = @[kMailAdressForFeedback];
    vc.hidesAppBuildCell = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSArray *)topics
{
    return @[
             NSLocalizedString(@"SettingView_Feedback_Topic_Request", nil),
             NSLocalizedString(@"SettingView_Feedback_Topic_BugReport", nil),
             NSLocalizedString(@"SettingView_Feedback_Topic_Other", nil),
             ];
}

@end
