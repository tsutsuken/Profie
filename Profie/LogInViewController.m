//
//  LogInViewController.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/06/30.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "LogInViewController.h"

@interface LogInViewController ()

@end

@implementation LogInViewController

#pragma mark - Initialization
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"LogInView_Title", nil);
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(didPushDoneButton)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [ANALYTICS trackView:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CloseView

- (void)didPushDoneButton
{
    [self logIn];
}

#pragma mark - LogIn

- (void)logIn
{
    NSArray *inputDataArray = [self inputDataArray];
    
    if ([self shouldProceedLogInWithInputDataArray:inputDataArray]) {
        [self proceedLogInWithInputDataArray:inputDataArray];
    }else {
        [self showAlertWithMessage:NSLocalizedString(@"SignUpAndLogInView_Alert_Message_Error_Empty", nil)];
    }
}

- (void)proceedLogInWithInputDataArray:(NSArray *)inputDataArray
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.view endEditing:YES];
    
    NSString *username = [inputDataArray objectAtIndex:0];
    NSString *password = [inputDataArray objectAtIndex:1];
    
    [PFUser logInWithUsernameInBackground:username password:password
                                    block:^(PFUser *user, NSError *error) {
                                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                                        
                                        if (user) {
                                            [self.delegate logInViewController:self didLogInUser:user];
                                        } else {
                                            [self showAlertWithMessage:[self messageWithError:error]];
                                        }
                                    }];
}

- (NSArray *)inputDataArray
{
    NSMutableArray *inputDataArray = [[NSMutableArray alloc] init];
    NSInteger numberOfRows = [self tableView:self.tableView numberOfRowsInSection:0];
    
    for (int i = 0; i < numberOfRows; i++){
        LVEditableCell *cell = (LVEditableCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        UITextField *textField = [cell textField];
        
        NSString *string = [textField text];
        [inputDataArray addObject:string];
    }
    
    return [inputDataArray copy];
}

- (BOOL)shouldProceedLogInWithInputDataArray:(NSArray *)inputDataArray
{
    BOOL shouldBeginSignUp = YES;
    
    //Check if the value is empty
    for (int i = 0; i < inputDataArray.count; i++) {
        NSString *string = [inputDataArray objectAtIndex:i];
        if (!string || !string.length) {
            shouldBeginSignUp = NO;
            break;
        }
    }
    
    return shouldBeginSignUp;
}

#pragma mark Alert

- (void)showAlertWithMessage:(NSString *)message
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SignUpAndLogInView_Alert_Title_Error", nil)
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil];
    [alert show];
}

- (NSString *)messageWithError:(NSError *)error
{
    NSString *errorString;
    
    LOG(@"error_%@",[error description]);
    
    NSInteger errorCode = [error code];
    if (errorCode == kPFErrorObjectNotFound) {
        errorString = [NSString stringWithFormat:NSLocalizedString(@"LogInView_Alert_Message_Error_Incorrect", nil)];
    }else {
		errorString = [error userInfo][@"error"];
	}
    
    return errorString;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LVEditableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    NSString *title;
    NSString *placeholder;
    BOOL isSecure = NO;
    
    switch (indexPath.row) {
        case 0:
            title = NSLocalizedString(@"SignUpAndLogInView_Cell_Username_Title", nil);
            placeholder = NSLocalizedString(@"SignUpAndLogInView_Cell_Username_Placeholder", nil);
            break;
            
        case 1:
            title = NSLocalizedString(@"SignUpAndLogInView_Cell_Password_Title", nil);
            placeholder = NSLocalizedString(@"SignUpAndLogInView_Cell_Password_Placeholder", nil);
            isSecure = YES;
            break;
            
        default:
            break;
    }
    
    cell.titleLabel.text = title;
    cell.textField.placeholder = placeholder;
    cell.textField.secureTextEntry = isSecure;
    
    return cell;
}

@end
