//
//  QuestionDetailViewController.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/05/29.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "QuestionDetailViewController.h"

@interface QuestionDetailViewController ()

@property (weak, nonatomic) IBOutlet UIView *innerHeaderView;
@property (weak, nonatomic) IBOutlet UIView *questionView;
@property (weak, nonatomic) IBOutlet UIView *answerView;
@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (weak, nonatomic) IBOutlet UIButton *answerButton;

@end

@implementation QuestionDetailViewController

#pragma mark - Initialization

- (void)dealloc
{
    LOG_METHOD;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LUEditAnswerViewControllerUserDidAnswerNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNotifications];

    self.title = NSLocalizedString(@"QuestionDetailView_Title", nil);
    
    [self configureTableHeaderView];
    [self reloadTableHeaderView];
}

- (void)setNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidAnswer:) name:LUEditAnswerViewControllerUserDidAnswerNotification object:nil];
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
    //QuestionView
    UILabel *questionLabel = (UILabel *)[self.questionView viewWithTag:1];
    questionLabel.text = [self.question objectForKey:kLUQuestionTitleKey];
    
    //AnswerView
    if (self.answer) {
        [self configureAnswerView];
    }
    else {
        [self removeAnswerView];
    }
    
    //ActionView
    [self.answerButton setTitle:NSLocalizedString(@"QuestionDetailView_Button_Answer_StateNormal", nil) forState:UIControlStateNormal];
    [self.answerButton setTitle:NSLocalizedString(@"QuestionDetailView_Button_Answer_StateDisabled", nil) forState:UIControlStateDisabled];
    
    [self resizeTableHeaderView];
}

- (void)configureAnswerView
{
    UILabel *userNameLabel = (UILabel *)[self.answerView viewWithTag:2];
    userNameLabel.text = self.user.username;
    
    UILabel *answerLabel = (UILabel *)[self.answerView viewWithTag:3];
    answerLabel.text = [self.answer objectForKey:kLUAnswerTitleKey];
}

- (void)removeAnswerView
{
    [self.answerView removeFromSuperview];
    
    NSDictionary *views = @{ @"questionView" : self.questionView,
                             @"actionView" : self.actionView};
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[questionView][actionView]"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:views];
    
    [self.innerHeaderView addConstraints:constraints];
}

- (void)reloadTableHeaderView
{
    if (self.answer) {
        //ProfileImageView
        PFRoundedImageView *profileImageView = (PFRoundedImageView *)[self.answerView viewWithTag:1];
        profileImageView.file = [self.user objectForKey:kLUUserProfilePicSmallKey];
        [profileImageView loadInBackground];
    }
    
    [self reloadAnswerButton];
}

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
    
    cell.profileImageView.user = user;
    cell.profileImageView.file = [user objectForKey:kLUUserProfilePicSmallKey];
    [cell.profileImageView loadInBackground];
    
    cell.userNameLabel.text = user.username;
    
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *answer = [self objectAtIndexPath:indexPath];
    PFUser *auther = [answer objectForKey:kLUAnswerAutherKey];
    
    if ([auther isCurrentUser]) {
        cell.backgroundColor = [UIColor colorWithHue:0.61 saturation:0.09 brightness:0.99 alpha:1.0];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"QuestionDetailView_SectionHeader", nil);
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - Show Other View

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LOG(@"%@", [segue identifier]);
    
    if([[segue identifier] isEqualToString:@"showEditAnswerNavigationView"])
    {
        UINavigationController *nvc = (UINavigationController *)segue.destinationViewController;
        EditAnswerViewController *controller = (EditAnswerViewController *)nvc.topViewController;
        controller.question = self.question;
    }
}

#pragma mark EditAnswerView

- (IBAction)didPushAnswerButton
{
    [self showEditAnswerView];
}

- (void)showEditAnswerView
{
    [self performSegueWithIdentifier:@"showEditAnswerNavigationView" sender:self];
}

#pragma mark - ()

- (void)userDidAnswer:(NSNotification *)note
{
    LOG_METHOD;
    [self loadObjects];
    [self reloadAnswerButton];
}

@end
