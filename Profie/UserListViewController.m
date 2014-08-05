//
//  UserListViewController.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/05/12.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "UserListViewController.h"

@interface UserListViewController ()

@end

@implementation UserListViewController

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super initWithCoder:decoder];
    if (!self) {
        return nil;
    }
    self.parseClassName = kLVActivityClassKey;
    self.pullToRefreshEnabled = YES;
    self.paginationEnabled = YES;
    self.objectsPerPage = 25;
    
    return self;
}

- (PFQuery *)queryForTable
{
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query includeKey:kLVActivityToUserKey];//フォロー相手を取得
    [query includeKey:kLVActivityFromUserKey];//フォロワーを取得
    [query whereKey:kLVActivityTypeKey equalTo:kLVActivityTypeFollow];
    
    if (self.dataType == UserListViewDataTypeFollowing) {
        [query whereKey:kLVActivityFromUserKey equalTo:self.user];
    }
    else {
        [query whereKey:kLVActivityToUserKey equalTo:self.user];
    }

    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    
    [query orderByDescending:kLVCommonCreatedAtKey];
    
    return query;
}

- (PFUser *)userObjectAtIndexPath:(NSIndexPath *)indexPath
{
    PFUser *user;
    
    PFObject *activity = [self objectAtIndexPath:indexPath];
    
    if (self.dataType == UserListViewDataTypeFollowing) {
        user = [activity objectForKey:kLVActivityToUserKey];
    }
    else {
        user = [activity objectForKey:kLVActivityFromUserKey];
    }

    return user;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureTitle];
}

- (void)configureTitle
{
    if (self.dataType == UserListViewDataTypeFollowing) {
        self.title = NSLocalizedString(@"UserListView_Title_Following", nil);
    }
    else {
        self.title = NSLocalizedString(@"UserListView_Title_Follower", nil);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    PFUser *user = [self userObjectAtIndexPath:indexPath];
    
    PFRoundedImageView *profileImageView = (PFRoundedImageView *)[cell.contentView viewWithTag:1];
    profileImageView.user = user;
    profileImageView.file = [user objectForKey:kLVUserProfilePicSmallKey];
    [profileImageView loadInBackground];
    
    UILabel *userNameLabel = (UILabel *)[cell.contentView viewWithTag:2];
    userNameLabel.text = [user objectForKey:kLVUserUsernameKey];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard* mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ProfileViewController *vc = (ProfileViewController *) [mainStoryBoard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    PFUser *selectedUser = [self userObjectAtIndexPath:indexPath];
    vc.user = selectedUser;
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end


