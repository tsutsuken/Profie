//
//  ProfileViewController.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/05/08.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@property (nonatomic, assign) BOOL shouldReloadOnAppear;
@property (strong, nonatomic) GADBannerView *bannerView;

@property (weak, nonatomic) IBOutlet PFRoundedImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *followingCountButton;
@property (weak, nonatomic) IBOutlet UIButton *followerCountButton;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet UIButton *followActionButton;
@property (weak, nonatomic) IBOutlet UIView *actionView;

@end

@implementation ProfileViewController

#pragma mark - Initialization

- (void)dealloc
{
    [self removeNotifications];
}

- (void)awakeFromNib
{
    self.title = NSLocalizedString(@"ProfileView_Title", nil);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNotifications];
    
    [self configureTableHeaderView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadTableHeaderView];
    
    if (self.shouldReloadOnAppear) {
        self.shouldReloadOnAppear = NO;
        [self loadObjects];
    }
    
    [self configureAd];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self removeAd];
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

    self.parseClassName = kLVAnswerClassKey;
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
    
    [query whereKey:kLVAnswerAutherKey equalTo:self.user];
    
    [query includeKey:kLVAnswerQuestionKey];
    [query includeKey:kLVAnswerAutherKey];
    [query orderByDescending:kLVCommonCreatedAtKey];
    
    return query;
}

#pragma mark - TableHeaderView
#pragma mark Configure

- (void)configureTableHeaderView
{
    //UserNameLabel
    self.userNameLabel.text =  [self.user username];

    //FollowerCountButton
    [self.followerCountButton setTitle:[self titleForFollowerCountButtonWithCount:0] forState:UIControlStateNormal];
    
    //FollowingCountButton
    [self.followingCountButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"ProfileView_Button_FollowingCount_%d", nil), 0]
                               forState:UIControlStateNormal];
    
    //SettingButton
    if ([self.user isCurrentUser]) {
        [self.settingButton addTarget:self action:@selector(didPushSettingButton) forControlEvents:UIControlEventTouchUpInside];
    }
    else{
        self.settingButton.hidden = YES;
    }
    
    //FollowActionButton
    if ([self.user isCurrentUser]) {
        self.followActionButton.hidden = YES;
    }
    else{
        [self configureFollowActionButton];
    }
    
    [self addBorderToActionView];
}

- (void)configureFollowActionButton
{
    [self.followActionButton setTitle:NSLocalizedString(@"ProfileView_Button_FollowAction_Follow", nil) forState:UIControlStateNormal];
    [self.followActionButton setTitle:NSLocalizedString(@"ProfileView_Button_FollowAction_Unfollow", nil) forState:UIControlStateSelected];
    [self.followActionButton addTarget:self action:@selector(didPushFollowActionButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)addBorderToActionView
{
    CALayer *topBorder = [CALayer layer];
    topBorder.backgroundColor = kColorBorder.CGColor;
    topBorder.frame = CGRectMake(0, 0, self.actionView.frame.size.width, kBorderHeight);
    [self.self.actionView.layer addSublayer:topBorder];
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.backgroundColor = kColorBorder.CGColor;
    bottomBorder.frame = CGRectMake(0, self.actionView.frame.size.height, self.actionView.frame.size.width, kBorderHeight);
    [self.self.actionView.layer addSublayer:bottomBorder];
}

#pragma mark Reload

- (void)reloadTableHeaderView
{
    //ProfileImageView
    self.profileImageView.file = [self.user objectForKey:kLVUserProfilePicMediumKey];
    [self.profileImageView loadInBackground];
    
    //FollowActionButton
    if (![self.user isCurrentUser]) {
        PFQuery *queryIsFollowing = [PFQuery queryWithClassName:kLVActivityClassKey];
        [queryIsFollowing whereKey:kLVActivityTypeKey equalTo:kLVActivityTypeFollow];
        [queryIsFollowing whereKey:kLVActivityToUserKey equalTo:self.user];
        [queryIsFollowing whereKey:kLVActivityFromUserKey equalTo:[PFUser currentUser]];
        [queryIsFollowing setCachePolicy:kPFCachePolicyCacheThenNetwork];
        [queryIsFollowing countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if (!error) {
                if (number == 0) {
                    self.followActionButton.selected = NO;
                } else {
                    self.followActionButton.selected = YES;
                }
            }
        }];
    }
    
    //FollowerCountButton
    PFQuery *queryFollowerCount = [PFQuery queryWithClassName:kLVActivityClassKey];
    [queryFollowerCount whereKey:kLVActivityTypeKey equalTo:kLVActivityTypeFollow];
    [queryFollowerCount whereKey:kLVActivityToUserKey equalTo:self.user];
    [queryFollowerCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [queryFollowerCount countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            [self.followerCountButton setTitle:[self titleForFollowerCountButtonWithCount:count] forState:UIControlStateNormal];
        }
    }];
    
    //FollowingCountButton
    PFQuery *queryFollowingCount = [PFQuery queryWithClassName:kLVActivityClassKey];
    [queryFollowingCount whereKey:kLVActivityTypeKey equalTo:kLVActivityTypeFollow];
    [queryFollowingCount whereKey:kLVActivityFromUserKey equalTo:self.user];
    [queryFollowingCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [queryFollowingCount countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            [self.followingCountButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"ProfileView_Button_FollowingCount_%d", nil), count]
                                       forState:UIControlStateNormal];
        }
    }];
}

- (NSString *)titleForFollowerCountButtonWithCount:(int)count
{
    NSString *suffix = (count==1?@"":NSLocalizedString(@"Common_Suffix_Plural", nil));
    NSString *title = [NSString stringWithFormat:NSLocalizedString(@"ProfileView_Button_FollowerCount_%d_%@", nil), count, suffix];
    
    return title;
}

#pragma mark Action

- (void)didPushSettingButton
{
    [self showSettingView];
}

- (void)didPushFollowActionButton:(UIButton *)sender
{
    BOOL isSelected = sender.selected;
    
    if (isSelected) {
        [LVUtility unfollowUserEventually:self.user];
    }else {
		[LVUtility followUserEventually:self.user block:^(BOOL succeeded, NSError *error) {
        }];
	}
    
    sender.selected = !isSelected;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    AnswerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    Answer *answer = (Answer *)object;
    Question *question = answer.question;
    PFUser *user = answer.auther;
    
    cell.profileImageView.user = user;
    cell.profileImageView.file = [user objectForKey:kLVUserProfilePicSmallKey];
    [cell.profileImageView loadInBackground];
    
    cell.userNameLabel.text = user.username;
    
    cell.answerLabel.text = answer.title;
    
    cell.questionLabel.text = question.titleWithTag;
    
    cell.timeLabel.text = [[LVTimeFormatter sharedManager] stringForTimeIntervalFromDate:[NSDate date] toDate:answer.createdAt];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat heightForCell;
    
    AnswerCell *cell = (AnswerCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    [cell layoutSubviews];
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
        Answer *selectedAnswer = (Answer *)[self objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
        vc.answer = selectedAnswer;
        vc.question = selectedAnswer.question;
        vc.user = self.user;
    }
}

#pragma mark EditProfileView

- (void)showSettingView
{
    [self performSegueWithIdentifier:@"showSettingView" sender:self];
}

#pragma mark QuestionDetailView

- (void)showQuestionDetailView
{
    [self performSegueWithIdentifier:@"showQuestionDetailView" sender:self];
}

#pragma mark - NSNotification

- (void)setNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidEditAnswer:) name:LVEditAnswerViewControllerUserDidEditAnswerNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidDeleteAnswer:) name:LVQuestionDetailViewControllerUserDidDeleteAnswerNotification object:nil];
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LVEditAnswerViewControllerUserDidEditAnswerNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LVQuestionDetailViewControllerUserDidDeleteAnswerNotification object:nil];
}

- (void)userDidEditAnswer:(NSNotification *)note
{
    self.shouldReloadOnAppear = YES;
}

- (void)userDidDeleteAnswer:(NSNotification *)note
{
    self.shouldReloadOnAppear = YES;
}

#pragma mark - Ads

- (GADBannerView *)bannerView
{
    if (!_bannerView) {
        CGPoint position = CGPointMake(0, [UIScreen mainScreen].bounds.size.height - kGADAdSizeBanner.size.height - kTabBarHeight);
        _bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner origin:position];
        
        _bannerView.adUnitID = kAdUnitIdProfileView;
        _bannerView.delegate = self;
        _bannerView.rootViewController = self;
    }
    
    return _bannerView;
}

- (void)configureAd
{
    GADRequest *request = [GADRequest request];
#if DEBUG
    request.testDevices = @[kTestDeviceIdKeniPhone5s];
#endif
    [self.bannerView loadRequest:request];
}

- (void)removeAd
{
    [self.bannerView removeFromSuperview];
    self.bannerView = nil;
}

- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window addSubview: self.bannerView];
    
    [self adjustTableViewInsets];
}

- (void)adjustTableViewInsets
{
    UIEdgeInsets insetForAds = UIEdgeInsetsMake(kStatusBarHeight + kNavigationBarHeight, 0, kGADAdSizeBanner.size.height + kTabBarHeight, 0);
    [self.tableView setContentInset:insetForAds];
    [self.tableView setScrollIndicatorInsets:insetForAds];
}

@end



