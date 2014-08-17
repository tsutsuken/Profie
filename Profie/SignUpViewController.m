//
//  SignUpViewController.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/06/28.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()
@property (weak, nonatomic) IBOutlet UITextView *footerTextView;
@end

@implementation SignUpViewController

#pragma mark - Initialization
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"SignUpView_Title", nil);
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(didPushDoneButton)];
    
    [self configureFooterView];
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

#pragma mark FooterView
- (void)configureFooterView
{
    self.footerTextView.delegate = self;
    self.footerTextView.linkTextAttributes = @{NSForegroundColorAttributeName : [UIColor darkGrayColor]};
    self.footerTextView.attributedText = [self attributedStringForFooter];
}

- (NSMutableAttributedString *)attributedStringForFooter
{
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] init];
    
    CGFloat fontSize = [UIFont smallSystemFontSize];
    
    NSDictionary *attributesForNormalText = @{ NSForegroundColorAttributeName:[UIColor darkGrayColor],
                                               NSFontAttributeName:[UIFont systemFontOfSize:fontSize]};
    NSDictionary *attributesForLinkTextTerms = @{NSLinkAttributeName:kURLTermsOfUse,
                                                 NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize]};
    NSDictionary *attributesForLinkTextPrivacyPolicy = @{NSLinkAttributeName:kURLPrivacyPolicy,
                                                         NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize]};
    
    NSAttributedString *string1 = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"SignUpView_Footer_1", nil)
                                                                  attributes:attributesForNormalText];
    NSAttributedString *string2 = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"SignUpView_Footer_2", nil)
                                                                  attributes:attributesForLinkTextTerms];
    NSAttributedString *string3 = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"SignUpView_Footer_3", nil)
                                                                  attributes:attributesForNormalText];
    NSAttributedString *string4 = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"SignUpView_Footer_4", nil)
                                                                  attributes:attributesForLinkTextPrivacyPolicy];
    NSAttributedString *string5 = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"SignUpView_Footer_5", nil)
                                                                  attributes:attributesForNormalText];
    
    [attributedString appendAttributedString:string1];
    [attributedString appendAttributedString:string2];
    [attributedString appendAttributedString:string3];
    [attributedString appendAttributedString:string4];
    [attributedString appendAttributedString:string5];
    
    return attributedString;
}

-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    [self showActionSheetWithURL:URL];
    
    return NO;
}

#pragma mark - CloseView

- (void)didPushDoneButton
{
    [self signUp];
}

#pragma mark - SignUp

- (void)signUp
{
    NSArray *inputDataArray = [self inputDataArray];
    
    if ([self shouldProceedSignUpWithInputDataArray:inputDataArray]) {
        [self proceedSignUpWithInputDataArray:inputDataArray];
    }else {
        [self showAlertWithMessage:NSLocalizedString(@"SignUpAndLogInView_Alert_Message_Error_Empty", nil)];
    }
}

- (void)proceedSignUpWithInputDataArray:(NSArray *)inputDataArray
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.view endEditing:YES];
    
    PFUser *newUser = [PFUser user];
    newUser.username = [inputDataArray objectAtIndex:0];
    newUser.password = [inputDataArray objectAtIndex:1];
    newUser.email = [inputDataArray objectAtIndex:2];
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            // Hooray! Let them use the app now.
            [self.delegate signUpViewController:self didSignUpUser:newUser];
        } else {
            [self showAlertWithMessage:[self messageWithError:error inputDataArray:inputDataArray]];
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

- (BOOL)shouldProceedSignUpWithInputDataArray:(NSArray *)inputDataArray
{
    BOOL shouldProceedSignUp = YES;
    
    //Check if the value is empty
    for (int i = 0; i < inputDataArray.count; i++) {
        NSString *string = [inputDataArray objectAtIndex:i];
        if (!string || !string.length) {
            shouldProceedSignUp = NO;
            break;
        }
    }
    
    return shouldProceedSignUp;
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

- (NSString *)messageWithError:(NSError *)error inputDataArray:(NSArray *)inputDataArray
{
    NSString *errorString;
    
    LOG(@"error_%@",[error description]);
    
    NSInteger errorCode = [error code];
    if (errorCode == kPFErrorUsernameTaken) {
        NSString *username = [inputDataArray objectAtIndex:0];
        errorString = [NSString stringWithFormat:NSLocalizedString(@"SignUpView_Alert_Message_Error_UsernameTaken_%@", nil), username];
    }else if (errorCode == kPFErrorUserEmailTaken) {
        NSString *email = [inputDataArray objectAtIndex:2];
        errorString = [NSString stringWithFormat:NSLocalizedString(@"SignUpView_Alert_Message_Error_EmailTaken_%@", nil), email];
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
    return 3;
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
            
        case 2:
            title = NSLocalizedString(@"SignUpView_Cell_Email_Title", nil);
            placeholder = NSLocalizedString(@"SignUpView_Cell_Email_Placeholder", nil);
            break;
            
        default:
            break;
    }
    
    cell.titleLabel.text = title;
    cell.textField.placeholder = placeholder;
    cell.textField.secureTextEntry = isSecure;
    
    return cell;
}

#pragma mark - Open Safari
#pragma mark UIActionSheet
- (void)showActionSheetWithURL:(NSURL *)URL
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    
    actionSheet.title = URL.absoluteString;
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Common_ActionSheet_OpenInSafari", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Common_ActionSheet_Cancel", nil)];
    actionSheet.cancelButtonIndex = 1;
    
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSString *URLString = actionSheet.title;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLString]];
    }
}

@end
