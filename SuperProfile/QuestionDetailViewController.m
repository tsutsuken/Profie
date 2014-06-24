//
//  QuestionDetailViewController.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/05/29.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "QuestionDetailViewController.h"

#define kBorderHeight (1.0 / [UIScreen mainScreen].scale)

@interface QuestionDetailViewController ()

@property (nonatomic, assign) BOOL shouldReloadOnAppear;
@property (strong, nonatomic) GADBannerView *bannerView;

@property (weak, nonatomic) IBOutlet UIView *innerHeaderView;
@property (weak, nonatomic) IBOutlet UIView *questionView;
@property (weak, nonatomic) IBOutlet UIButton *answerButton;
@property (weak, nonatomic) IBOutlet UIView *answerView;
@property (weak, nonatomic) IBOutlet UIView *actionView;

@end

@implementation QuestionDetailViewController

#pragma mark - Initialization

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LUEditAnswerViewControllerUserDidEditAnswerNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LUQuestionDetailViewControllerUserDidDeleteAnswerNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNotifications];

    self.title = NSLocalizedString(@"QuestionDetailView_Title", nil);
    
    [self configureTableHeaderView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.shouldReloadOnAppear) {
        self.shouldReloadOnAppear = NO;
        [self reloadAnswerButton];
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
    self.parseClassName = kLUAnswerClassKey;
    self.pullToRefreshEnabled = NO;
    self.paginationEnabled = YES;
    self.objectsPerPage = 25;
    
    return self;
}

- (PFQuery *)queryForTable
{
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    PFQuery *answerFromFollowingUserQuery = [self answerFromFollowingUserQuery];
    
    if ([self.user isCurrentUser]) {
        query = answerFromFollowingUserQuery;
    }
    else {
        PFQuery *answerFromCurrentUserQuery = [self answerFromCurrentUserQuery];
		query = [PFQuery orQueryWithSubqueries:@[answerFromFollowingUserQuery, answerFromCurrentUserQuery]];
	}
    
    [query includeKey:kLUAnswerAutherKey];
    [query orderByDescending:kLUCommonCreatedAtKey];
    
    return query;
}

- (PFQuery *)answerFromFollowingUserQuery
{
    PFQuery *answerFromFollowingUserQuery = [PFQuery queryWithClassName:self.parseClassName];
    
    //フォロー中のユーザを取得
    PFQuery *followingActivitiesQuery = [PFQuery queryWithClassName:kLUActivityClassKey];
    [followingActivitiesQuery whereKey:kLUActivityTypeKey equalTo:kLUActivityTypeFollow];
    [followingActivitiesQuery whereKey:kLUActivityFromUserKey equalTo:[PFUser currentUser]];
    followingActivitiesQuery.limit = 1000;
    if (self.answer) {
        [followingActivitiesQuery whereKey:kLUActivityToUserKey notEqualTo:self.user];//該当画面のユーザを除外
    }
    
    //フォロー中ユーザのアンサーのquery
    [answerFromFollowingUserQuery whereKey:kLUAnswerQuestionKey equalTo:self.question];
    [answerFromFollowingUserQuery whereKey:kLUAnswerAutherKey matchesKey:kLUActivityToUserKey inQuery:followingActivitiesQuery];
    
    return answerFromFollowingUserQuery;
}

- (PFQuery *)answerFromCurrentUserQuery
{
    PFQuery *answerFromCurrentUserQuery = [PFQuery queryWithClassName:self.parseClassName];
    [answerFromCurrentUserQuery whereKey:kLUAnswerQuestionKey equalTo:self.question];
    [answerFromCurrentUserQuery whereKey:kLUAnswerAutherKey equalTo:[PFUser currentUser]];
    
    return answerFromCurrentUserQuery;
}

#pragma mark - TableHeaderView

- (void)configureTableHeaderView
{
    //QuestionView_Title
    UILabel *questionLabel = (UILabel *)[self.questionView viewWithTag:1];
    questionLabel.text = [self.question objectForKey:kLUQuestionTitleKey];
    
    //QuestionView_AnswerButton
    [self.answerButton setTitle:NSLocalizedString(@"QuestionDetailView_Button_Answer_StateNormal", nil) forState:UIControlStateNormal];
    [self.answerButton setTitle:NSLocalizedString(@"QuestionDetailView_Button_Answer_StateDisabled", nil) forState:UIControlStateDisabled];
    [self reloadAnswerButton];
    
    //AnswerView and ActionView
    if (self.answer) {
        [self configureAnswerView];
    }
    else {
        [self removeAnswerViewAndActionView];
    }
    
    //InnerHeaderView
    [self addBorderToInnerHeaderView];
    
    [self resizeTableHeaderView];
}

#pragma mark AnswerView and ActionView

- (void)configureAnswerView
{
    PFRoundedImageView *profileImageView = (PFRoundedImageView *)[self.answerView viewWithTag:LUAnswerViewItemTagProfileImageView];
    profileImageView.delegate = self;
    profileImageView.user = self.user;
    profileImageView.file = [self.user objectForKey:kLUUserProfilePicSmallKey];
    [profileImageView loadInBackground];
    
    LVTouchableLabel *userNameLabel = (LVTouchableLabel *)[self.answerView viewWithTag:LUAnswerViewItemTagUserNameLabel];
    userNameLabel.delegate = self;
    userNameLabel.user = self.user;
    userNameLabel.text = self.user.username;
    
    UILabel *timeLabel = (UILabel *)[self.answerView viewWithTag:LUAnswerViewItemTagTimeLabel];
    timeLabel.text = [[LUTimeFormatter sharedManager] stringForTimeIntervalFromDate:[NSDate date] toDate:self.answer.createdAt];
    
    UILabel *answerLabel = (UILabel *)[self.answerView viewWithTag:LUAnswerViewItemTagAnswerLabel];
    answerLabel.text = [self.answer objectForKey:kLUAnswerTitleKey];
    
    [self addBorderToAnswerView];
}

- (void)removeAnswerViewAndActionView
{
    [self.answerView removeFromSuperview];
    [self.actionView removeFromSuperview];
    
    NSDictionary *views = @{ @"questionView" : self.questionView};
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[questionView]|"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:views];
    
    [self.innerHeaderView addConstraints:constraints];
}

#pragma mark AnswerButton

- (void)reloadAnswerButton
{
    //回答済みか判定
    PFQuery *query = [PFQuery queryWithClassName:kLUAnswerClassKey];
    [query whereKey:kLUAnswerAutherKey equalTo:[PFUser currentUser]];
    [query whereKey:kLUAnswerQuestionKey equalTo:self.question];
    [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            if (count == 0) {
                self.answerButton.enabled = YES;
            } else {
                self.answerButton.enabled = NO;
            }
        }
    }];
}

#pragma mark Border

- (void)addBorderToAnswerView
{
    CALayer *topBorder = [self border];
    topBorder.frame = CGRectMake(0.0f, 0.0f, self.answerView.frame.size.width, kBorderHeight);
    [self.answerView.layer addSublayer:topBorder];
    
    CALayer *bottomBorder = [self border];
    CGFloat spaceWidth = 15.0f;
    CGFloat yPosition = [self.answerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    bottomBorder.frame = CGRectMake(spaceWidth, yPosition, self.answerView.frame.size.width - (spaceWidth * 2), kBorderHeight);
    [self.answerView.layer addSublayer:bottomBorder];
}

- (void)addBorderToInnerHeaderView
{
    CALayer *topBorder = [self border];
    topBorder.frame = CGRectMake(0.0f, 0.0f, self.innerHeaderView.frame.size.width, kBorderHeight);
    [self.innerHeaderView.layer addSublayer:topBorder];
    
    CALayer *bottomBorder = [self border];
    CGFloat yPosition = [self.innerHeaderView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    bottomBorder.frame = CGRectMake(0.0f, yPosition, self.innerHeaderView.frame.size.width, kBorderHeight);
    [self.innerHeaderView.layer addSublayer:bottomBorder];
}

- (CALayer *)border
{
    CALayer *border = [CALayer layer];
    
    border.backgroundColor = kColorBorder.CGColor;
    
    return border;
}

#pragma mark Other

- (void)resizeTableHeaderView
{
    CGFloat newHeight = [self.innerHeaderView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    UIView *headerView = self.tableView.tableHeaderView;
    CGRect newFrame = headerView.frame;
    newFrame.size.height = newHeight;
    headerView.frame = newFrame;
    
    [self.tableView setTableHeaderView:headerView];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([self.objects count] == 0) {
        return nil;
    }else {
        return NSLocalizedString(@"QuestionDetailView_SectionHeader", nil);
	}
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard* mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    QuestionDetailViewController *vc = (QuestionDetailViewController *)[mainStoryBoard instantiateViewControllerWithIdentifier:@"QuestionDetailView"];
    
    PFObject *selectedAnswer = [self objectAtIndexPath:indexPath];
    vc.question = self.question;
    vc.answer = selectedAnswer;
    vc.user = [selectedAnswer objectForKey:kLUAnswerAutherKey];
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - MenuButton

- (IBAction)didPushAnswerButton
{
    [self showEditAnswerViewForAdding];
}

- (IBAction)didPushMenuButton
{
    [self showActionSheet];
}

#pragma mark - UIActionSheet

- (void)showActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    
    if ([self.user isCurrentUser]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"QuestionDetailView_ActionSheet_CopyAnswer", nil)];
        [actionSheet addButtonWithTitle:NSLocalizedString(@"QuestionDetailView_ActionSheet_EditAnswer", nil)];
        [actionSheet addButtonWithTitle:NSLocalizedString(@"QuestionDetailView_ActionSheet_DeleteAnswer", nil)];
        [actionSheet addButtonWithTitle:NSLocalizedString(@"QuestionDetailView_ActionSheet_Cancel", nil)];
        
        actionSheet.cancelButtonIndex = 3;
        actionSheet.destructiveButtonIndex = 2;
        actionSheet.tag = LUActionSheetTagCurrentUser;
        
    }else {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"QuestionDetailView_ActionSheet_CopyAnswer", nil)];
        [actionSheet addButtonWithTitle:NSLocalizedString(@"QuestionDetailView_ActionSheet_Cancel", nil)];
        
        actionSheet.cancelButtonIndex = 1;
        actionSheet.tag = LUActionSheetTagOtherUser;
    }
    
    [actionSheet showInView:self.view.window];
}

-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == LUActionSheetTagCurrentUser) {
        switch (buttonIndex) {
            case 0:
                [self copyAnswer];
                break;
            case 1:
                [self editAnswer];
                break;
            case 2:
                [self deleteAnswer];
                break;
            case 3:
                //Cancel
                break;
        }
    }else {
		switch (buttonIndex) {
            case 0:
                [self copyAnswer];
                break;
            case 1:
                //Cancel
                break;
        }
	}
}

- (void)copyAnswer
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    UILabel *answerLabel = (UILabel *)[self.answerView viewWithTag:LUAnswerViewItemTagAnswerLabel];
    [pasteboard setValue:answerLabel.text forPasteboardType:@"public.text"];
}

- (void)editAnswer
{
    [self showEditAnswerViewForEditing];
}

- (void)deleteAnswer
{
    [self decrementAnswerCountOfQuestion];
    
    [self.answer deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [[NSNotificationCenter defaultCenter] postNotificationName:LUQuestionDetailViewControllerUserDidDeleteAnswerNotification object:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)decrementAnswerCountOfQuestion
{
    NSNumber *answerCount = (NSNumber *)[self.question objectForKey:kLUQuestionAnswerCountKey];
    NSNumber *newAnswerCount = @([answerCount intValue] - 1);
    [self.question setObject:newAnswerCount forKey:kLUQuestionAnswerCountKey];
    
    [self.question saveInBackground];
    LOG(@"newAnswerCount_%@",newAnswerCount);
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
    
    if ([[segue identifier] isEqualToString:@"showEditAnswerViewForAdding"]) {
        UINavigationController *nvc = (UINavigationController *)segue.destinationViewController;
        EditAnswerViewController *controller = (EditAnswerViewController *)nvc.topViewController;
        controller.question = self.question;
    }
    else if ([[segue identifier] isEqualToString:@"showEditAnswerViewForEditing"]) {
        UINavigationController *nvc = (UINavigationController *)segue.destinationViewController;
        EditAnswerViewController *controller = (EditAnswerViewController *)nvc.topViewController;
        controller.question = self.question;
        controller.answer = self.answer;//currentUserのAnswerである
    }
}

#pragma mark EditAnswerView

- (void)showEditAnswerViewForAdding
{
    [self performSegueWithIdentifier:@"showEditAnswerViewForAdding" sender:self];
}

- (void)showEditAnswerViewForEditing
{
    [self performSegueWithIdentifier:@"showEditAnswerViewForEditing" sender:self];
}

#pragma mark - NSNotification

- (void)setNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidEditAnswer:) name:LUEditAnswerViewControllerUserDidEditAnswerNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidDeleteAnswer:) name:LUQuestionDetailViewControllerUserDidDeleteAnswerNotification object:nil];
}

- (void)userDidEditAnswer:(NSNotification *)note
{
    //Reload AnswerLabel
    UILabel *answerLabel = (UILabel *)[self.answerView viewWithTag:LUAnswerViewItemTagAnswerLabel];
    answerLabel.text = [self.answer objectForKey:kLUAnswerTitleKey];
    
    [self reloadAnswerButton];
    [self loadObjects];
}

- (void)userDidDeleteAnswer:(NSNotification *)note
{
    self.shouldReloadOnAppear = YES;
}

#pragma mark - Ads

- (GADBannerView *)bannerView
{
    if (!_bannerView) {
        _bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeMediumRectangle origin:CGPointMake(10, 10)];
        _bannerView.adUnitID = kAdUnitIdQuestionDetailView;
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
    self.tableView.tableFooterView = nil;
}

- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, kGADAdSizeMediumRectangle.size.height + 10)];
	[footerView addSubview:self.bannerView];
    
    self.tableView.tableFooterView = footerView;
}

@end
