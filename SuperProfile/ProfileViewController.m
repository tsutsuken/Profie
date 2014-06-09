//
//  ProfileViewController.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/05/08.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UIButton *followActionButton;
@property (weak, nonatomic) IBOutlet UIButton *followingCountButton;
@property (weak, nonatomic) IBOutlet UIButton *followerCountButton;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet PFRoundedImageView *profileImageView;

@end

@implementation ProfileViewController

#pragma mark - Initialization

- (void)awakeFromNib
{
    self.title = NSLocalizedString(@"ProfileView_Title", nil);
}

- (void)viewDidLoad
{
    LOG_METHOD;
    
    [super viewDidLoad];
    
    if ([self.user isCurrentUser]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                               target:self
                                                                                               action:@selector(didPushEditProfileButton)];
    }
    
    [self configureTableHeaderView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadTableHeaderView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didPushEditProfileButton
{
    [self showEditProfileView];
}

#pragma mark PFQueryTableView

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super initWithCoder:decoder];
    if (!self) {
        return nil;
    }
    self.parseClassName = kLUAnswerClassKey;
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
    
    [query whereKey:kLUAnswerAutherKey equalTo:self.user];
    
    [query includeKey:kLUAnswerQuestionKey];
    [query includeKey:kLUAnswerAutherKey];
    [query orderByDescending:kLUCommonCreatedAtKey];
    
    return query;
}

#pragma mark - TableHeaderView

- (void)configureTableHeaderView
{
    //ProfileImageView
    self.profileImageView.image = [UIImage imageNamed:@"person"];
    
    //UserNameLabel
    self.userNameLabel.text =  [self.user username];
    
    //FollowActionButton
    if ([self.user isCurrentUser]) {
        self.followActionButton.hidden = YES;
    }
    else{
        [self.followActionButton setTitle:NSLocalizedString(@"ProfileView_Button_FollowAction_Loading", nil) forState:UIControlStateNormal];
    }
    
    //FollowingCountButton
    [self.followingCountButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"ProfileView_Button_FollowingCount_%d", nil), 0]
                               forState:UIControlStateNormal];
    
    //FollowerCountButton
    [self.followerCountButton setTitle:[self titleForFollowerCountButtonWithCount:0] forState:UIControlStateNormal];
}

- (void)reloadTableHeaderView
{
    //ProfileImageView
    self.profileImageView.file = [self.user objectForKey:kLUUserProfilePicSmallKey];
    [self.profileImageView loadInBackground];
    
    //FollowActionButton
    if (![self.user isCurrentUser]) {
        PFQuery *queryIsFollowing = [PFQuery queryWithClassName:kLUActivityClassKey];
        [queryIsFollowing whereKey:kLUActivityTypeKey equalTo:kLUActivityTypeFollow];
        [queryIsFollowing whereKey:kLUActivityToUserKey equalTo:self.user];
        [queryIsFollowing whereKey:kLUActivityFromUserKey equalTo:[PFUser currentUser]];
        [queryIsFollowing setCachePolicy:kPFCachePolicyCacheThenNetwork];
        [queryIsFollowing countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if (!error) {
                if (number == 0) {
                    [self configureFollowButton];
                } else {
                    [self configureUnfollowButton];
                }
            }
        }];
    }
    
    //FollowingCountButton
    PFQuery *queryFollowingCount = [PFQuery queryWithClassName:kLUActivityClassKey];
    [queryFollowingCount whereKey:kLUActivityTypeKey equalTo:kLUActivityTypeFollow];
    [queryFollowingCount whereKey:kLUActivityFromUserKey equalTo:self.user];
    [queryFollowingCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [queryFollowingCount countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            [self.followingCountButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"ProfileView_Button_FollowingCount_%d", nil), count]
                                       forState:UIControlStateNormal];
        }
    }];
    
    //FollowerCountButton
    PFQuery *queryFollowerCount = [PFQuery queryWithClassName:kLUActivityClassKey];
    [queryFollowerCount whereKey:kLUActivityTypeKey equalTo:kLUActivityTypeFollow];
    [queryFollowerCount whereKey:kLUActivityToUserKey equalTo:self.user];
    [queryFollowerCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [queryFollowerCount countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            [self.followerCountButton setTitle:[self titleForFollowerCountButtonWithCount:count] forState:UIControlStateNormal];
        }
    }];
}

- (NSString *)titleForFollowerCountButtonWithCount:(int)count
{
    NSString *suffix = (count==1?@"":NSLocalizedString(@"Common_Suffix_Plural", nil));
    NSString *title = [NSString stringWithFormat:NSLocalizedString(@"ProfileView_Button_FollowerCount_%d_%@", nil), count, suffix];
    
    return title;
}

- (void)configureFollowButton
{
    [self.followActionButton setTitle:NSLocalizedString(@"ProfileView_Button_FollowAction_Follow", nil) forState:UIControlStateNormal];
    [self.followActionButton addTarget:self action:@selector(didPushFollowButton) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureUnfollowButton
{
    [self.followActionButton setTitle:NSLocalizedString(@"ProfileView_Button_FollowAction_Unfollow", nil) forState:UIControlStateNormal];
    [self.followActionButton addTarget:self action:@selector(didPushUnfollowButton) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didPushFollowButton
{
    [self configureUnfollowButton];

    [LUUtility followUserEventually:self.user block:^(BOOL succeeded, NSError *error) {
        if (error) {
            [self configureFollowButton];
        }
    }];
}

- (void)didPushUnfollowButton
{
    [self configureFollowButton];
    
    [LUUtility unfollowUserEventually:self.user];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    AnswerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    PFUser *user = [object objectForKey:kLUAnswerAutherKey];
    
    cell.profileImageView.user = user;
    cell.profileImageView.file = [user objectForKey:kLUUserProfilePicSmallKey];
    [cell.profileImageView loadInBackground];
    
    cell.userNameLabel.text = user.username;
    
    PFObject *question = [object objectForKey:kLUAnswerQuestionKey];
    cell.questionLabel.text = [question objectForKey:kLUQuestionTitleKey];
    
    cell.answerLabel.text = [object objectForKey:kLUAnswerTitleKey];
    
    cell.timeLabel.text = [[LUTimeFormatter sharedManager] stringForTimeIntervalFromDate:[NSDate date] toDate:object.createdAt];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat heightForCell;
    
    AnswerCell *cell = (AnswerCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    
    CGFloat heightForContentView = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    heightForCell = heightForContentView + 1;
    
    return heightForCell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showQuestionDetailView];
}

#pragma mark - Show Other View

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LOG(@"%@", [segue identifier]);
    
    if ([[segue identifier] isEqualToString:@"showFollowingListView"])
    {
        UserListViewController *vc = (UserListViewController *)segue.destinationViewController;
        vc.user = self.user;
        vc.dataType = UserListViewDataTypeFollowing;
    }
    else if ([[segue identifier] isEqualToString:@"showFollowerListView"])
    {
        UserListViewController *vc = (UserListViewController *)segue.destinationViewController;
        vc.user = self.user;
        vc.dataType = UserListViewDataTypeFollower;
    }
    else if ([[segue identifier] isEqualToString:@"showQuestionDetailView"]){
        QuestionDetailViewController *vc = (QuestionDetailViewController *)segue.destinationViewController;
        PFObject *selectedAnswer = [self objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
        vc.question = [selectedAnswer objectForKey:kLUAnswerQuestionKey];
        vc.answer = selectedAnswer;
        vc.user = self.user;
    }
}

#pragma mark EditProfileView

- (void)showEditProfileView
{
    [self performSegueWithIdentifier:@"showEditProfileView" sender:self];
}

#pragma mark QuestionDetailView

- (void)showQuestionDetailView
{
    [self performSegueWithIdentifier:@"showQuestionDetailView" sender:self];
}

@end



