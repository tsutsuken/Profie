//
//  AllUserListViewController.m
//  Profie
//
//  Created by Ken Tsutsumi on 2014/09/08.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "AllUserListViewController.h"

@interface AllUserListViewController ()

@property (assign, nonatomic) int lastObjectCount;

@end

@implementation AllUserListViewController

//#warning AllUserListViewを削除する

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"すべてのユーザー";
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
    
    self.parseClassName = kLVUserClassKey;
    self.pullToRefreshEnabled = YES;
    self.paginationEnabled = YES;
    self.objectsPerPage = 25;
    
    return self;
}

- (PFQuery *)queryForTable
{
    PFQuery *query =  [User query];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query orderByDescending:kLVCommonCreatedAtKey];
    
    return query;
}

#pragma mark - Table view data source

- (PFTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
 
    User *user = (User *)object;
    
    PFRoundedImageView *profileImageView = (PFRoundedImageView *)[cell.contentView viewWithTag:1];
    profileImageView.userInteractionEnabled = NO;
    [profileImageView sd_setImageWithURL:[NSURL URLWithString:user.profilePictureSmall.url]
                        placeholderImage:[UIImage imageNamed:@"person_small.png"]];
    
    UILabel *userNameLabel = (UILabel *)[cell.contentView viewWithTag:2];
    userNameLabel.text = user.username;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard* mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ProfileViewController *vc = (ProfileViewController *) [mainStoryBoard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    User *selectedUser = (User *)[self objectAtIndexPath:indexPath];
    vc.user = selectedUser;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat heightForCell;
    
    if (indexPath.row == self.objects.count) {
        //cellForNextPage
        heightForCell = 0;
    } else {
        UITableViewCell *cell = (UITableViewCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
        heightForCell = cell.frame.size.height;
	}
    
    return heightForCell;
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentSize.height - scrollView.contentOffset.y < (self.view.bounds.size.height)) {
        if (![self isLoading]) {
            int newObjectCount = (int)[self.objects count];
        
            if (newObjectCount > self.lastObjectCount) {//前回のLoadNextPageで、objectが増えたか？
                self.lastObjectCount = newObjectCount;
                [self loadNextPage];
            }
        }
    }
}


@end