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

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                           target:self
                                                                                           action:@selector(showEditQuestionView)];
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
    self.parseClassName = kLUQuestionClassKey;
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
    
    [query whereKey:kLUCommonObjectIdKey doesNotMatchKey:kLUAnswerQuestionIdKey inQuery:[self answerFromCurrentUserQuery]];
    [query orderByDescending:kLUQuestionAnswerCountKey];
    [query addDescendingOrder:kLUCommonCreatedAtKey];
    
    return query;
}

- (PFQuery *)answerFromCurrentUserQuery
{
    PFQuery *answerFromCurrentUserQuery = [PFQuery queryWithClassName:kLUAnswerClassKey];
    [answerFromCurrentUserQuery whereKey:kLUAnswerAutherKey equalTo:[PFUser currentUser]];
    
    return answerFromCurrentUserQuery;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:1];
    titleLabel.text = [object objectForKey:kLUQuestionTitleKey];
    
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
    [self showQuestionDetailView];
}

#pragma mark - Show Other View

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LOG(@"%@", [segue identifier]);
    
    if([[segue identifier] isEqualToString:@"showQuestionDetailView"]){
        QuestionDetailViewController *vc = (QuestionDetailViewController *)segue.destinationViewController;
        PFObject *selectedQuestion = [self objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
        vc.question = selectedQuestion;
    }
}

#pragma mark EditQuestionView

- (void)showEditQuestionView
{
    [self performSegueWithIdentifier:@"showEditQuestionView" sender:self];
}

#pragma mark QuestionDetailView

- (void)showQuestionDetailView
{
    [self performSegueWithIdentifier:@"showQuestionDetailView" sender:self];
}

#pragma mark - NSNotification

- (void)setNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidEditAnswer:) name:LUEditAnswerViewControllerUserDidEditAnswerNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidDeleteAnswer:) name:LUQuestionDetailViewControllerUserDidDeleteAnswerNotification object:nil];
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LUEditAnswerViewControllerUserDidEditAnswerNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LUQuestionDetailViewControllerUserDidDeleteAnswerNotification object:nil];
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



