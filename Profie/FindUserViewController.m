//
//  FindUserViewController.m
//  Profie
//
//  Created by Ken Tsutsumi on 2014/09/14.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "FindUserViewController.h"

@interface FindUserViewController ()

@property (nonatomic, assign) BOOL shouldReloadOnAppear;
@property (strong, nonatomic) NSString *searchString;
@property (strong, nonatomic) PFQuery *followingActivityQuery;
@property (strong, nonatomic) NSMutableArray *followingUsersObjectIds;

@end

@implementation FindUserViewController

- (void)dealloc
{
    [self removeNotifications];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNotifications];
    
    [self configureFollowingUsersArrayWithBlock:nil];
    
    self.title = NSLocalizedString(@"FindUserView_Title", nil);
    
    //To remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)configureEmptyViewOnlyOnce
{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        EmptyView *view = [[EmptyView alloc] init];
        view.mainLabel.text = NSLocalizedString(@"FindUserView_Empty_MainLabel", nil);
        
        self.tableView.nxEV_emptyView = view;
    });
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
    
    self.parseClassName = kLVUserClassKey;
    self.pullToRefreshEnabled = YES;
    self.paginationEnabled = YES;
    self.objectsPerPage = 25;
    self.loadingViewEnabled = NO;
    
    return self;
}

- (PFQuery *)queryForTable
{
    if (!self.searchString || self.searchString.length == 0) {
        //０件の結果を返すため
        PFQuery *dummyQuery = [PFQuery queryWithClassName:@"DummyClass"];
        return dummyQuery;
    }
    
    PFQuery *query = [User query];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    PFQuery *queryForFullname = [User query];
    [queryForFullname whereKey:kLVUserFullnameKey containsString:self.searchString];
    PFQuery *queryForUsername = [User query];
    [queryForUsername whereKey:kLVUserUsernameKey containsString:self.searchString];
    query = [PFQuery orQueryWithSubqueries:@[queryForFullname, queryForUsername]];
    
    [query orderByDescending:kLVCommonUpdatedAtKey];
    
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

#pragma mark - Table view data source

- (PFTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    User *user = (User *)object;
    
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
    targetUser = (User *)[self objectAtIndexPath:indexPath];
    
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
    User *selectedUser = (User *)[self objectAtIndexPath:indexPath];
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

#pragma mark - UISearchBar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    self.searchString = searchBar.text;
    [self loadObjects];
    
    [self configureEmptyViewOnlyOnce];
    
    [ANALYTICS trackEvent:kAnEventClickSearchButton isImportant:YES sender:self];
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
