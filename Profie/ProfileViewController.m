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
@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
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
    
    [query whereKey:kLVAnswerAutherKey equalTo:self.user];
    
    [query includeKey:kLVAnswerQuestionKey];
    [query includeKey:kLVAnswerAutherKey];
    [query orderByDescending:kLVCommonUpdatedAtKey];
    
    return query;
}

#pragma mark - TableHeaderView
#pragma mark Configure

- (void)configureTableHeaderView
{
    //UserNameLabel
    self.userNameLabel.text =  [self.user username];
    
    //SettingButton
    [self.settingButton addTarget:self action:@selector(didPushSettingButton) forControlEvents:UIControlEventTouchUpInside];
    
    //ShareButton
    [self.shareButton setTitle:NSLocalizedString(@"ProfileView_ShareButton_Title", nil) forState:UIControlStateNormal];
    [self.shareButton addTarget:self action:@selector(didPushShareButton) forControlEvents:UIControlEventTouchUpInside];
    
    [self addBorderToActionView];
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
}

#pragma mark SettingButton

- (void)didPushSettingButton
{
    [self showSettingView];
}

#pragma mark ShareButton

- (void)didPushShareButton
{
    [self showActionSheetForShareProfile];
}

- (void)showActionSheetForShareProfile
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    
    actionSheet.cancelButtonIndex = 2;
    [actionSheet addButtonWithTitle:NSLocalizedString(@"ProfileView_ActionSheet_CopyLink", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"ProfileView_ActionSheet_OpenInSafari", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Common_ActionSheet_Cancel", nil)];
    actionSheet.tapBlock = ^(UIActionSheet *actionSheet, NSInteger buttonIndex){
        switch (buttonIndex) {
            case 0:
                [self copyLinkForProfile];
                break;
            case 1:
                [self openProfileInSafari];
                break;
            case 2:
                //Cancel
                break;
        }
    };
    
    [actionSheet showInView:self.view];
}

- (void)copyLinkForProfile
{
    NSString *link = [NSString stringWithFormat:@"profie.me/%@", [PFUser currentUser].username];
    [[UIPasteboard generalPasteboard] setValue:link forPasteboardType:@"public.text"];
    
    [ANALYTICS trackEvent:kAnEventCopyLinkForProfile sender:self];
}

- (void)openProfileInSafari
{
    NSString *URLString = [NSString stringWithFormat:@"http://www.profie.me/%@", [PFUser currentUser].username];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLString]];
    
    [ANALYTICS trackEvent:kAnEventOpenProfileInSafari sender:self];
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
    
    cell.timeLabel.text = [[LVTimeFormatter sharedManager] stringForTimeIntervalFromDate:[NSDate date] toDate:answer.updatedAt];
    
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
    [self showActionSheetForEditAnswer];
}

#pragma mark - Edit Answer

- (void)showActionSheetForEditAnswer
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    
    actionSheet.destructiveButtonIndex = 1;
    actionSheet.cancelButtonIndex = 2;
    [actionSheet addButtonWithTitle:NSLocalizedString(@"ProfileView_ActionSheet_EditAnswer", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"ProfileView_ActionSheet_DeleteAnswer", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Common_ActionSheet_Cancel", nil)];
    actionSheet.tapBlock = ^(UIActionSheet *actionSheet, NSInteger buttonIndex){
        switch (buttonIndex) {
            case 0:
                [self showEditAnswerView];
                break;
            case 1:
                [self deleteAnswer];
                break;
            case 2:
                //Cancel
                [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
                //didSelectRowAtIndexPathでやると、適切なAnswerを取得できない
                break;
        }
    };
    
    [actionSheet showInView:self.view];
}

- (void)deleteAnswer
{
    Answer *selectedAnswer = (Answer *)[self objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
    [selectedAnswer deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kLVNotificationDidDeleteAnswer object:nil];
        }
    }];
    
    [selectedAnswer.question decrementAnswerCount];
    
    [ANALYTICS trackEvent:kAnEventDeleteAnswer sender:self];
}

#pragma mark - Show Other View

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LOG(@"%@", [segue identifier]);
    if ([[segue identifier] isEqualToString:@"showEditAnswerView"]) {
        UINavigationController *nvc = (UINavigationController *)segue.destinationViewController;
        EditAnswerViewController *controller = (EditAnswerViewController *)nvc.topViewController;
        Answer *selectedAnswer = (Answer *)[self objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
        controller.answer = selectedAnswer;
        controller.question = selectedAnswer.question;
    }
}

#pragma mark SettingView

- (void)showSettingView
{
    [self performSegueWithIdentifier:@"showSettingView" sender:self];
}

#pragma mark EditAnswerView

- (void)showEditAnswerView
{
    [self performSegueWithIdentifier:@"showEditAnswerView" sender:self];
}


#pragma mark - NSNotification

- (void)setNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidEditAnswer:) name:kLVNotificationDidEditAnswer object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidDeleteAnswer:) name:kLVNotificationDidDeleteAnswer object:nil];
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLVNotificationDidEditAnswer object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLVNotificationDidDeleteAnswer object:nil];
}

- (void)userDidEditAnswer:(NSNotification *)note
{
    self.shouldReloadOnAppear = YES;
    
    //Check if self.view is visible
    if (self.isViewLoaded && self.view.window) {
        [self loadObjects];
    } else {
		self.shouldReloadOnAppear = YES;
	}
}

- (void)userDidDeleteAnswer:(NSNotification *)note
{
    [self loadObjects];
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
    
//#warning test
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



