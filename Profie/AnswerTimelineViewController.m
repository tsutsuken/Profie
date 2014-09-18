//
//  AnswerTimelineViewController.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/06/06.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "AnswerTimelineViewController.h"

@interface AnswerTimelineViewController ()

@property (nonatomic, assign) BOOL shouldReloadOnAppear;
@property (strong, nonatomic) GADBannerView *bannerView;

@end

@implementation AnswerTimelineViewController

#pragma mark - Initialization

- (void)dealloc
{
    [self removeNotifications];
}

- (void)awakeFromNib
{
    self.title = NSLocalizedString(@"AnswerTimelineView_Title", nil);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNotifications];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"person_add_nav"]
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(showFindUserView)];
    
    [self configureEmptyView];
}

- (void)configureEmptyView
{
    EmptyView *view = [[EmptyView alloc] init];
    view.mainLabel.text = NSLocalizedString(@"AnswerTimelineView_Empty_MainLabel", nil);
    view.detailLabel.text = NSLocalizedString(@"AnswerTimelineView_Empty_DetailLabel", nil);
    
    self.tableView.nxEV_emptyView = view;
    
    //To remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.shouldReloadOnAppear) {
        self.shouldReloadOnAppear = NO;
        [self loadObjects];
    }
    
    [self configureAd];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [ANALYTICS trackView:self];
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
    
    //フォロー中のユーザのquery
    PFQuery *followingActivitiesQuery = [PFQuery queryWithClassName:kLVActivityClassKey];
    [followingActivitiesQuery whereKey:kLVActivityTypeKey equalTo:kLVActivityTypeFollow];
    [followingActivitiesQuery whereKey:kLVActivityFromUserKey equalTo:[User currentUser]];
    
    [query whereKey:kLVAnswerAutherKey matchesKey:kLVActivityToUserKey inQuery:followingActivitiesQuery];
    
    [query includeKey:kLVAnswerQuestionKey];
    [query includeKey:kLVAnswerAutherKey];
    [query orderByDescending:kLVCommonUpdatedAtKey];
    
    return query;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    AnswerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    Answer *answer = (Answer *)object;
    Question *question = answer.question;
    User *user = answer.auther;
    
    cell.profileImageView.delegate = self;
    cell.profileImageView.user = user;
    [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:user.profilePictureSmall.url]
                             placeholderImage:[UIImage imageNamed:@"person_small.png"]];
    
    cell.userNameLabel.text = user.username;
    cell.userNameLabel.delegate = self;
    cell.userNameLabel.user = user;
    
    cell.answerLabel.text = answer.title;
    
    cell.questionLabel.text = question.titleWithTag;
    
    cell.timeLabel.text = [[LVTimeFormatter sharedManager] stringForTimeIntervalFromDate:[NSDate date] toDate:answer.updatedAt];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat heightForCell;
    
    if (indexPath.row == self.objects.count) {
        //cellForNextPage
        heightForCell = 0;
    } else {
        AnswerCell *cell = (AnswerCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
        [cell layoutSubviews];
        CGFloat heightForContentView = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        
        heightForCell = heightForContentView + 1;
	}
    
    return heightForCell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showActionSheetForReferingFriendsAnswer];
}

#pragma mark Refer To Answer

- (void)showActionSheetForReferingFriendsAnswer
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    
    actionSheet.cancelButtonIndex = 1;
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Common_ActionSheet_AnswerSameQuestion", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Common_ActionSheet_Cancel", nil)];
    actionSheet.tapBlock = ^(UIActionSheet *actionSheet, NSInteger buttonIndex){
        switch (buttonIndex) {
            case 0:
                [self showEditAnswerView];
                break;
            case 1:
                [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
                //didSelectRowAtIndexPathでdeselectすると、prepareForSegueでAnswerを取得できない
                break;
        }
    };
    
    [actionSheet showInView:self.view];
}

#pragma mark - PFRoundedImageView delegate

- (void)didPushImageView:(PFRoundedImageView *)imageView
{
    [imageView showProfileViewFromViewController:self];
}

#pragma mark - LVTouchableLabel delegate

- (void)didPushLabel:(LVTouchableLabel *)label
{
    [label showProfileViewFromViewController:self];
}

#pragma mark - Show Other View

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LOG(@"%@", [segue identifier]);
    if ([[segue identifier] isEqualToString:@"showEditAnswerView"]) {
        UINavigationController *nvc = (UINavigationController *)segue.destinationViewController;
        EditAnswerViewController *controller = (EditAnswerViewController *)nvc.topViewController;
        Answer *friendsAnswer = (Answer *)[self objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
        controller.question = friendsAnswer.question;
        controller.answer = [LVUtility answerOfCurrentUserForQuestion:friendsAnswer.question];
    }
}

#pragma mark EditAnswerView

- (void)showEditAnswerView
{
    [self performSegueWithIdentifier:@"showEditAnswerView" sender:self];
}

#pragma mark FindUserView

- (void)showFindUserView
{
    [self performSegueWithIdentifier:@"showFindUserView" sender:self];
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
    self.shouldReloadOnAppear = YES;
}

#pragma mark - Ads

- (GADBannerView *)bannerView
{
    if (!_bannerView) {
        CGPoint position = CGPointMake(0, [UIScreen mainScreen].bounds.size.height - kGADAdSizeBanner.size.height - kTabBarHeight);
        _bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner origin:position];
        
        _bannerView.adUnitID = kAdUnitIdAnswerTimelineView;
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
