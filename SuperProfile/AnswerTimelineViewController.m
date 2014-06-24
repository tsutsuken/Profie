//
//  AnswerTimelineViewController.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/06/06.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "AnswerTimelineViewController.h"

@interface AnswerTimelineViewController ()

@property (strong, nonatomic) GADBannerView *bannerView;

@end

@implementation AnswerTimelineViewController

#pragma mark - Initialization

- (void)awakeFromNib
{
    self.title = NSLocalizedString(@"AnswerTimelineView_Title", nil);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
    
    //フォロー中のユーザのquery
    PFQuery *followingActivitiesQuery = [PFQuery queryWithClassName:kLUActivityClassKey];
    [followingActivitiesQuery whereKey:kLUActivityTypeKey equalTo:kLUActivityTypeFollow];
    [followingActivitiesQuery whereKey:kLUActivityFromUserKey equalTo:[PFUser currentUser]];
    
    [query whereKey:kLUAnswerAutherKey matchesKey:kLUActivityToUserKey inQuery:followingActivitiesQuery];
    
    [query includeKey:kLUAnswerQuestionKey];
    [query includeKey:kLUAnswerAutherKey];
    [query orderByDescending:kLUCommonCreatedAtKey];
    
    return query;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    AnswerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    PFUser *user = [object objectForKey:kLUAnswerAutherKey];
    
    cell.profileImageView.delegate = self;
    cell.profileImageView.user = user;
    cell.profileImageView.file = [user objectForKey:kLUUserProfilePicSmallKey];
    [cell.profileImageView loadInBackground];
    
    cell.userNameLabel.text = user.username;
    cell.userNameLabel.delegate = self;
    cell.userNameLabel.user = user;
    
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
    
    if ([[segue identifier] isEqualToString:@"showQuestionDetailView"]){
        QuestionDetailViewController *vc = (QuestionDetailViewController *)segue.destinationViewController;
        PFObject *selectedAnswer = [self objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
        vc.question = [selectedAnswer objectForKey:kLUAnswerQuestionKey];
        vc.answer = selectedAnswer;
        vc.user = [selectedAnswer objectForKey:kLUAnswerAutherKey];
    }
}

#pragma mark QuestionDetailView

- (void)showQuestionDetailView
{
    [self performSegueWithIdentifier:@"showQuestionDetailView" sender:self];
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
