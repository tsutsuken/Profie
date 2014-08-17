//
//  RecommendQuestionViewController.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/05/01.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "RecommendQuestionViewController.h"

@interface RecommendQuestionViewController ()

@property (nonatomic, assign) BOOL shouldReloadOnAppear;
@property (strong, nonatomic) GADBannerView *bannerView;

@end

@implementation RecommendQuestionViewController

#pragma mark - Initialization

- (void)dealloc
{
    [self removeNotifications];
}

- (void)awakeFromNib
{
    self.title = NSLocalizedString(@"RecommendQuestionView_Title", nil);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNotifications];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(showEditQuestionView)];
}

- (void)viewWillAppear:(BOOL)animated
{
    LOG_METHOD;
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
    self.parseClassName = kLVQuestionClassKey;
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
    
    [query whereKey:kLVCommonObjectIdKey doesNotMatchKey:kLVAnswerQuestionIdKey inQuery:[self answerFromCurrentUserQuery]];
    [query orderByDescending:kLVQuestionAnswerCountKey];
    [query addDescendingOrder:kLVCommonCreatedAtKey];
    
    return query;
}

- (PFQuery *)answerFromCurrentUserQuery
{
    PFQuery *answerFromCurrentUserQuery = [PFQuery queryWithClassName:kLVAnswerClassKey];
    [answerFromCurrentUserQuery whereKey:kLVAnswerAutherKey equalTo:[PFUser currentUser]];
    
    return answerFromCurrentUserQuery;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    Question *question = (Question *)object;
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:1];
    titleLabel.text = question.titleWithTag;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat heightForCell;
    
    PFTableViewCell *cell = (PFTableViewCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    [cell layoutSubviews];
    CGFloat heightForContentView = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    heightForCell = heightForContentView + 1;
    
    return heightForCell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showEditAnswerView];
}

#pragma mark - Show Other View

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LOG(@"%@", [segue identifier]);
    if ([[segue identifier] isEqualToString:@"showEditAnswerView"]) {
        UINavigationController *nvc = (UINavigationController *)segue.destinationViewController;
        EditAnswerViewController *controller = (EditAnswerViewController *)nvc.topViewController;
        Question *selectedQuestion = (Question *)[self objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
        controller.question = selectedQuestion;
    }
}

#pragma mark EditQuestionView

- (void)showEditQuestionView
{
    [self performSegueWithIdentifier:@"showEditQuestionView" sender:self];
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
    //Check if self.view is visible
    if (self.isViewLoaded && self.view.window) {
        [self loadObjects];
    } else {
		self.shouldReloadOnAppear = YES;
	}
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
        
        _bannerView.adUnitID = kAdUnitIdRecommendQuestionView;
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
    //[self.bannerView loadRequest:request];
    
#warning test
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



