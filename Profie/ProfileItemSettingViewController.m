//
//  ProfileItemSettingViewController.m
//  Profie
//
//  Created by Ken Tsutsumi on 2014/09/11.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "ProfileItemSettingViewController.h"

@interface ProfileItemSettingViewController ()

@end

@implementation ProfileItemSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"ProfileItemSettingView_Title", nil);
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                           target:self
                                                                                           action:@selector(didPushDoneButton)];
    [self enableSaveButton:NO];
}

- (void)enableSaveButton:(BOOL)enabled
{
    self.navigationItem.rightBarButtonItem.enabled = enabled;
}

- (void)didPushDoneButton
{
    [self saveInputData];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self showKeyboard];
}

- (void)showKeyboard
{
    LVEditableCell *cell = (LVEditableCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell.textField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *currentUser = [User currentUser];
    
    LVEditableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textField.delegate = self;
    cell.textField.placeholder = NSLocalizedString(@"ProfileSettingView_Cell_Fullname_Placeholder", nil);
    cell.textField.text = currentUser.fullname;
    return cell;
}

#pragma mark - Save

- (void)saveInputData
{
    NSString *fullname = [self inputData];
    
    User *currentUser = [User currentUser];
    currentUser.fullname = fullname;
    [currentUser saveInBackground];
}

- (NSString *)inputData
{
    NSString *inputData;
    
    LVEditableCell *cell = (LVEditableCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITextField *textField = [cell textField];
    inputData = [textField text];
    
    return inputData;
}

#pragma mark UITextField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //すでに入力されているテキストを取得
    NSMutableString *text = [textField.text mutableCopy];
    
    //今回入力されたテキストをマージ
    [text replaceCharactersInRange:range withString:string];
    
    if ( text.length < kMinCountOfFullname || text.length > kMaxCountOfFullname) {
        [self enableSaveButton:NO];
    } else {
		[self enableSaveButton:YES];
	}

    return YES;
}

@end
