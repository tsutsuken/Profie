//
//  AnswerTimelineViewController.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/06/06.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "AnswerTimelineViewController.h"

@interface AnswerTimelineViewController ()

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
#warning test
    //ログアウト＆再起動後、ここで落ちる
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

#pragma mark - PFRoundedImageView delegate

- (void)didPushImageView:(PFRoundedImageView *)imageView
{
    UIStoryboard* mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ProfileViewController *vc = (ProfileViewController *) [mainStoryBoard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    PFUser *selectedUser = imageView.user;
    vc.user = selectedUser;
    
    [self.navigationController pushViewController:vc animated:YES];
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

@end
