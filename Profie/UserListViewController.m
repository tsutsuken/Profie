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

#pragma mark - Initialization

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

#pragma mark PFQueryTableView

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
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query includeKey:kLVActivityToUserKey];//フォロー相手を取得
    [query includeKey:kLVActivityFromUserKey];//フォロワーを取得
    [query whereKey:kLVActivityTypeKey equalTo:kLVActivityTypeFollow];
    if (self.dataType == UserListViewDataTypeFollowing) {
        [query whereKey:kLVActivityFromUserKey equalTo:self.user];
    }
    else {
        [query whereKey:kLVActivityToUserKey equalTo:self.user];
    }
    [query orderByDescending:kLVCommonCreatedAtKey];
    
    return query;
}

- (User *)userObjectAtIndexPath:(NSIndexPath *)indexPath
{
    User *user;
    
    PFObject *activity = [self objectAtIndexPath:indexPath];
    
    if (self.dataType == UserListViewDataTypeFollowing) {
        user = [activity objectForKey:kLVActivityToUserKey];
    }
    else {
        user = [activity objectForKey:kLVActivityFromUserKey];
    }
    
    return user;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    User *user = [self userObjectAtIndexPath:indexPath];
    
    PFRoundedImageView *profileImageView = (PFRoundedImageView *)[cell.contentView viewWithTag:1];
    profileImageView.image = [UIImage imageNamed:@"person_small.png"];
    profileImageView.user = user;
    profileImageView.file = user.profilePictureSmall;
    if ([profileImageView.file isDataAvailable]) {
        [profileImageView loadInBackground];
    }
    
    UILabel *userNameLabel = (UILabel *)[cell.contentView viewWithTag:2];
    userNameLabel.text = user.username;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard* mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ProfileViewController *vc = (ProfileViewController *) [mainStoryBoard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    User *selectedUser = [self userObjectAtIndexPath:indexPath];
    vc.user = selectedUser;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat heightForCell;
    
    if (indexPath.row == self.objects.count) {
        //cellForNextPage
        heightForCell = 0;
    } else {
        UITableViewCell *cell = (UITableViewCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
        heightForCell = cell.frame.size.height;
	}
    
    return heightForCell;
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentSize.height - scrollView.contentOffset.y < (self.view.bounds.size.height)) {
        if (![self isLoading]) {
            [self loadNextPage];
        }
    }
}

@end



