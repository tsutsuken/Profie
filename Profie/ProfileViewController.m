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
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fullnameLabel;
@property (weak, nonatomic) IBOutlet UIButton *followerCountButton;
@property (weak, nonatomic) IBOutlet UIButton *followingCountButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
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
    
    [self configureNavigationButtons];
    
    [self configureTableHeaderView];
    
    [self configureEmptyView];
}

- (void)configureNavigationButtons
{
    if ([self.navigationController.viewControllers count] == 1) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"person_add_nav"]
                                                                                 style:UIBarButtonItemStyleBordered
                                                                                target:self
                                                                                action:@selector(showFindUserView)];
        
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear"]
                                                                                  style:UIBarButtonItemStyleBordered
                                                                                 target:self
                                                                                 action:@selector(showSettingView)];
    }
}

- (void)configureEmptyView
{
    EmptyView *view = [[EmptyView alloc] init];
    view.mainLabel.text = NSLocalizedString(@"ProfileView_Empty_MainLabel", nil);
    
    self.tableView.nxEV_emptyView = view;
    
    //To remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
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
    self.usernameLabel.text =  [self.user username];
    
    //FollowerCountButton
    [self.followerCountButton setTitle:[self titleForFollowerCountButtonWithCount:0] forState:UIControlStateNormal];
    
    //FollowingCountButton
    [self.followingCountButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"ProfileView_Button_FollowingCount_%d", nil), 0]
                               forState:UIControlStateNormal];
    
    //ShareButton
    if ([self.user isEqualToCurrentUser]) {
        [self.shareButton setTitle:NSLocalizedString(@"ProfileView_ShareButton_Title", nil) forState:UIControlStateNormal];
        [self.shareButton addTarget:self action:@selector(didPushShareButton) forControlEvents:UIControlEventTouchUpInside];
    }
    else{
        self.shareButton.hidden = YES;
    }
    
    //FollowActionButton
    if ([self.user isEqualToCurrentUser]) {
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
    topBorder.frame = CGRectMake(0, 0, self.view.frame.size.width, kBorderHeight);
    [self.actionView.layer addSublayer:topBorder];
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.backgroundColor = kColorBorder.CGColor;
    bottomBorder.frame = CGRectMake(0, self.actionView.frame.size.height, self.view.frame.size.width, kBorderHeight);
    [self.actionView.layer addSublayer:bottomBorder];
}

- (NSString *)titleForFollowerCountButtonWithCount:(int)count
{
    NSString *suffix = (count==1?@"":NSLocalizedString(@"Common_Suffix_Plural", nil));
    NSString *title = [NSString stringWithFormat:NSLocalizedString(@"ProfileView_Button_FollowerCount_%d_%@", nil), count, suffix];
    
    return title;
}

#pragma mark Reload

- (void)reloadTableHeaderView
{
    //ProfileImageView
    [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:self.user.profilePictureMedium.url]
                             placeholderImage:[UIImage imageNamed:@"person_small.png"]];
    
    //FullnameLabel
    NSString *fullname = [self.user fullname];
    if (fullname.length == 0) {
        self.fullnameLabel.text = [self.user username];
    } else {
		self.fullnameLabel.text = fullname;
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
    
    //FollowActionButton
    PFQuery *queryIsFollowing = [PFQuery queryWithClassName:kLVActivityClassKey];
    [queryIsFollowing whereKey:kLVActivityTypeKey equalTo:kLVActivityTypeFollow];
    [queryIsFollowing whereKey:kLVActivityToUserKey equalTo:self.user];
    [queryIsFollowing whereKey:kLVActivityFromUserKey equalTo:[User currentUser]];
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

#pragma mark Action

- (void)didPushFollowActionButton:(UIButton *)sender
{
    BOOL isSelected = sender.selected;
    
    if (isSelected) {
        [LVUtility unfollowUserInBackground:self.user];
    }else {
		[LVUtility followUserInBackground:self.user];
	}
    
    sender.selected = !isSelected;
}

- (void)didPushShareButton
{
    [self showActionSheetForSharingProfile];
}

- (void)showActionSheetForSharingProfile
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
    NSString *link = [NSString stringWithFormat:@"profie.me/%@", [User currentUser].username];
    [[UIPasteboard generalPasteboard] setValue:link forPasteboardType:@"public.text"];
    
    [ANALYTICS trackEvent:kAnEventCopyLinkForProfile isImportant:YES sender:self];
}

- (void)openProfileInSafari
{
    NSString *URLString = [NSString stringWithFormat:@"http://www.profie.me/%@", [User currentUser].username];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLString]];
    
    [ANALYTICS trackEvent:kAnEventOpenProfileInSafari isImportant:YES sender:self];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    AnswerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    Answer *answer = (Answer *)object;
    Question *question = answer.question;
    User *user = answer.auther;
    
    cell.profileImageView.userInteractionEnabled = NO;
    [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:user.profilePictureSmall.url]
                             placeholderImage:[UIImage imageNamed:@"person_small.png"]];
    
    cell.userNameLabel.text = user.username;
    
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
    if ([self.user isEqualToCurrentUser]) {
        [self showActionSheetForEditingMyAnswer];
    }
    else{
        [self showActionSheetForReferingFriendsAnswer];
    }
}

#pragma mark Edit My Answer

- (void)showActionSheetForEditingMyAnswer
{
    Class class = NSClassFromString(@"UIAlertController");
    if(class) {
        // iOS8
        
        self.bannerView.hidden = YES;
        
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ProfileView_ActionSheet_EditAnswer", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action){
                                                          [self showEditAnswerViewFromMyAnswer];
                                                          self.bannerView.hidden = NO;
                                                      }]];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ProfileView_ActionSheet_DeleteAnswer", nil)
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction *action){
                                                          [self deleteMyAnswer];
                                                          self.bannerView.hidden = NO;
                                                      }]];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Common_ActionSheet_Cancel", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action){
                                                          //Cancel
                                                          self.bannerView.hidden = NO;
                                                          [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
                                                          //didSelectRowAtIndexPathでdeselectすると、prepareForSegueでAnswerを取得できない
                                                      }]];
        
        [self presentViewController:actionSheet animated:YES completion:nil];
    } else {
        // iOS7
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
        
        actionSheet.destructiveButtonIndex = 1;
        actionSheet.cancelButtonIndex = 2;
        [actionSheet addButtonWithTitle:NSLocalizedString(@"ProfileView_ActionSheet_EditAnswer", nil)];
        [actionSheet addButtonWithTitle:NSLocalizedString(@"ProfileView_ActionSheet_DeleteAnswer", nil)];
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Common_ActionSheet_Cancel", nil)];
        actionSheet.tapBlock = ^(UIActionSheet *actionSheet, NSInteger buttonIndex){
            switch (buttonIndex) {
                case 0:
                    [self showEditAnswerViewFromMyAnswer];
                    break;
                case 1:
                    [self deleteMyAnswer];
                    break;
                case 2:
                    //Cancel
                    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
                    //didSelectRowAtIndexPathでdeselectすると、prepareForSegueでAnswerを取得できない
                    break;
            }
        };
        
        [actionSheet showInView:self.view];
    }
}

- (void)deleteMyAnswer
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.minShowTime = 0.5;
    hud.labelText = NSLocalizedString(@"ProfileView_HUD_DeletingAnswer", nil);
    [self.navigationController.view addSubview:hud];
    
    [hud showAnimated:YES whileExecutingBlock:^{
        Answer *selectedAnswer = (Answer *)[self objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
        
        BOOL succeeded = [selectedAnswer delete];
        if (succeeded) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kLVNotificationDidDeleteAnswer object:nil];
            
            [selectedAnswer.question decrementAnswerCount];
            
            [ANALYTICS trackEvent:kAnEventDeleteAnswer isImportant:NO sender:self];
        }
    } completionBlock:^{
        [hud removeFromSuperview];
    }];
    /*
    Answer *selectedAnswer = (Answer *)[self objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
    [selectedAnswer deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kLVNotificationDidDeleteAnswer object:nil];
            
            [selectedAnswer.question decrementAnswerCount];
            
            [ANALYTICS trackEvent:kAnEventDeleteAnswer sender:self];
        }
    }];
     */
}

#pragma mark Refer To Friend's Answer

- (void)showActionSheetForReferingFriendsAnswer
{
    Class class = NSClassFromString(@"UIAlertController");
    if(class) {
        // iOS8
        
        self.bannerView.hidden = YES;
        
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Common_ActionSheet_AnswerSameQuestion", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action){
                                                          [self showEditAnswerViewFromFriendsAnswer];
                                                          self.bannerView.hidden = NO;
                                                          [ANALYTICS trackEvent:kAnEventAnswerSameQuestion isImportant:YES sender:self];
                                                      }]];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Common_ActionSheet_Cancel", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action){
                                                          //Cancel
                                                          self.bannerView.hidden = NO;
                                                          [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
                                                          //didSelectRowAtIndexPathでdeselectすると、prepareForSegueでAnswerを取得できない
                                                      }]];
        
        [self presentViewController:actionSheet animated:YES completion:nil];
    } else {
        // iOS7
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
        
        actionSheet.cancelButtonIndex = 1;
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Common_ActionSheet_AnswerSameQuestion", nil)];
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Common_ActionSheet_Cancel", nil)];
        actionSheet.tapBlock = ^(UIActionSheet *actionSheet, NSInteger buttonIndex){
            switch (buttonIndex) {
                case 0:
                    [self showEditAnswerViewFromFriendsAnswer];
                    break;
                case 1:
                    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
                    //didSelectRowAtIndexPathでdeselectすると、prepareForSegueでAnswerを取得できない
                    break;
            }
        };
        
        [actionSheet showInView:self.view];
    }
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
    else if ([[segue identifier] isEqualToString:@"showEditAnswerViewFromMyAnswer"]) {
        UINavigationController *nvc = (UINavigationController *)segue.destinationViewController;
        EditAnswerViewController *controller = (EditAnswerViewController *)nvc.topViewController;
        Answer *myAnswer = (Answer *)[self objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
        controller.question = myAnswer.question;
        controller.answer = myAnswer;
    }
    else if ([[segue identifier] isEqualToString:@"showEditAnswerViewFromFriendsAnswer"]) {
        UINavigationController *nvc = (UINavigationController *)segue.destinationViewController;
        EditAnswerViewController *controller = (EditAnswerViewController *)nvc.topViewController;
        Answer *friendsAnswer = (Answer *)[self objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
        controller.question = friendsAnswer.question;
        controller.shouldSearchPastAnswer = YES;
    }
}

#pragma mark SettingView

- (void)showSettingView
{
    [self performSegueWithIdentifier:@"showSettingView" sender:self];
}

#pragma mark EditAnswerView

- (void)showEditAnswerViewFromMyAnswer
{
    [self performSegueWithIdentifier:@"showEditAnswerViewFromMyAnswer" sender:self];
}

- (void)showEditAnswerViewFromFriendsAnswer
{
    [self performSegueWithIdentifier:@"showEditAnswerViewFromFriendsAnswer" sender:self];
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
    if ([self.user isEqualToCurrentUser]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentUserDidEditAnswer:) name:kLVNotificationDidEditAnswer object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentUserDidDeleteAnswer:) name:kLVNotificationDidDeleteAnswer object:nil];
    }
}

- (void)removeNotifications
{
    if ([self.user isEqualToCurrentUser]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kLVNotificationDidEditAnswer object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kLVNotificationDidDeleteAnswer object:nil];
    }
}

- (void)currentUserDidEditAnswer:(NSNotification *)note
{
    //Check if self.view is visible
    if (self.isViewLoaded && self.view.window) {
        [self loadObjects];
    } else {
		self.shouldReloadOnAppear = YES;
	}
}

- (void)currentUserDidDeleteAnswer:(NSNotification *)note
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
    request.testDevices = @[kTestDeviceIdKeniPhone5s, kTestDeviceIdKeniPhone5];
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



