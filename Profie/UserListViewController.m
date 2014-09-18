//
//  UserListViewController.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/05/12.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "UserListViewController.h"

@interface UserListViewController ()

@property (nonatomic, assign) BOOL shouldReloadOnAppear;
@property (strong, nonatomic) NSMutableArray *followingUsersObjectIds;

@end

@implementation UserListViewController

#pragma mark - Initialization

- (void)dealloc
{
    [self removeNotifications];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNotifications];
    
    [self configureFollowingUsersArrayWithBlock:nil];
    
    [self configureTitle];
    
    [self configureEmptyView];
}

- (void)configureEmptyView
{
    EmptyView *view = [[EmptyView alloc] init];
    view.mainLabel.text = NSLocalizedString(@"UserListView_Empty_MainLabel", nil);
    
    self.tableView.nxEV_emptyView = view;
    
    //To remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (BOOL)tableViewShouldBypassNXEmptyView:(UITableView *)tableView
{
    return NO;
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.shouldReloadOnAppear) {
        self.shouldReloadOnAppear = NO;
        [self configureFollowingUsersArrayWithBlock:^(BOOL succeeded) {
            if (succeeded) {
                [self loadObjects];
            }
        }];
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

- (void)configureFollowingUsersArrayWithBlock:(void (^)(BOOL succeeded))completionBlock
{
    self.followingUsersObjectIds = [NSMutableArray array];
    
    PFQuery *query = [PFQuery queryWithClassName:kLVActivityClassKey];
    [query includeKey:kLVActivityToUserKey];//フォロー相手を取得
    [query whereKey:kLVActivityTypeKey equalTo:kLVActivityTypeFollow];
    [query whereKey:kLVActivityFromUserKey equalTo:[User currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *followingActivities, NSError *error) {
        if (!error) {
            for (PFObject *activity in followingActivities) {
                User *user = [activity objectForKey:kLVActivityToUserKey];
                NSString *objectId = user.objectId;
                [self.followingUsersObjectIds addObject:objectId];
            }
            
            if (completionBlock) {
                completionBlock(YES);
            }
        }
        
    }];
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
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    User *user = [self userObjectAtIndexPath:indexPath];
    
    cell.profileImageView.userInteractionEnabled = NO;
    [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:user.profilePictureSmall.url]
                             placeholderImage:[UIImage imageNamed:@"person_small.png"]];
    
    //名前
    if (user.fullname.length == 0) {
        cell.fullnameLabel.text = user.username;
    } else {
		cell.fullnameLabel.text = user.fullname;
	}
    
    //ユーザ名
    cell.usernameLabel.text = user.username;
    
    //フォローボタン
    if ([user isEqualToCurrentUser]) {
        cell.followActionButton.hidden = YES;
    } else {
		cell.followActionButton.hidden = NO;
        [cell.followActionButton addTarget:self action:@selector(didPushFollowActionButton:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([self.followingUsersObjectIds containsObject:user.objectId]) {
            cell.followActionButton.selected = YES;
        } else {
            cell.followActionButton.selected = NO;
        }
	}
    
    return cell;
}

- (void)didPushFollowActionButton:(UIButton *)sender
{
    BOOL isSelected = sender.selected;
    
    User *targetUser;
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    targetUser = [self userObjectAtIndexPath:indexPath];
    
    if (isSelected) {
        [LVUtility unfollowUserInBackground:targetUser];
    }else {
		[LVUtility followUserInBackground:targetUser];
	}
    
    sender.selected = !isSelected;
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

#pragma mark - NSNotification

- (void)setNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(currentUserDidChangeFollowingUsers:)
                                                 name:kLVNotificationDidChangeFollowingUsers
                                               object:nil];
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLVNotificationDidChangeFollowingUsers object:nil];
}

- (void)currentUserDidChangeFollowingUsers:(NSNotification *)note
{
    //Check if self.view is visible
    if (self.isViewLoaded && self.view.window) {
        [self configureFollowingUsersArrayWithBlock:nil];
    } else {
		self.shouldReloadOnAppear = YES;
	}
}

@end



