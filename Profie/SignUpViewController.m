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
    [self precheckForSignUp];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LVEditableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    NSString *title;
    NSString *placeholder;
    BOOL isSecure = NO;
    
    switch (indexPath.row) {
        case 0:
            title = NSLocalizedString(@"SignUpAndLogInView_Cell_Fullname_Title", nil);
            placeholder = NSLocalizedString(@"SignUpAndLogInView_Cell_Fullname_Placeholder", nil);
            break;
            
        case 1:
            title = NSLocalizedString(@"SignUpAndLogInView_Cell_Username_Title", nil);
            placeholder = NSLocalizedString(@"SignUpAndLogInView_Cell_Username_Placeholder", nil);
            break;
            
        case 2:
            title = NSLocalizedString(@"SignUpView_Cell_Email_Title", nil);
            placeholder = NSLocalizedString(@"SignUpView_Cell_Email_Placeholder", nil);
            break;
            
        case 3:
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

#pragma mark - SignUp

- (void)precheckForSignUp
{
    if (![self isAllDataInputted]) {
        [self showAlertWithMessage:NSLocalizedString(@"SignUpAndLogInView_Alert_Message_Error_Empty", nil)];
        return;
    }
    
    if (![self isFullnameCorrect]) {
        [self showAlertWithMessage:NSLocalizedString(@"SignUpAndLogInView_Alert_Message_Error_IncorrectFullname", nil)];
        return;
    }
    
    if (![self isUsernameCorrect]) {
        [self showAlertWithMessage:NSLocalizedString(@"SignUpAndLogInView_Alert_Message_Error_IncorrectUsername", nil)];
        return;
    }
    
    [self signUp];
}

- (void)signUp
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.view endEditing:YES];
    
    User *newUser = [User user];
    NSArray *inputDataArray = [self inputDataArray];
    newUser.fullname = [inputDataArray objectAtIndex:SignUpViewItemIndexFullname];
    newUser.username = [inputDataArray objectAtIndex:SignUpViewItemIndexUsername];
    newUser.email = [inputDataArray objectAtIndex:SignUpViewItemIndexEmail];
    newUser.password = [inputDataArray objectAtIndex:SignUpViewItemIndexPassword];
    
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

- (BOOL)isAllDataInputted
{
    BOOL isAllDataInputted = YES;
    
    NSArray *inputDataArray = [self inputDataArray];
    
    //Check if the value is empty
    for (int i = 0; i < inputDataArray.count; i++) {
        NSString *string = [inputDataArray objectAtIndex:i];
        if (!string || !string.length) {
            isAllDataInputted = NO;
            break;
        }
    }
    
    return isAllDataInputted;
}

- (BOOL)isFullnameCorrect
{
    BOOL isFullnameCorrect = YES;
    
    NSArray *inputDataArray = [self inputDataArray];
    NSString *fullname = [inputDataArray objectAtIndex:SignUpViewItemIndexFullname];
    
    if ( fullname.length > kMaxCountOfFullname) {
        isFullnameCorrect = NO;
    }
    
    return isFullnameCorrect;
}

- (BOOL)isUsernameCorrect
{
    BOOL isUserNameCorrect = YES;
    
    NSArray *inputDataArray = [self inputDataArray];
    NSString *username = [inputDataArray objectAtIndex:SignUpViewItemIndexUsername];
    
    if ([username includesCharactersOtherThanAlphaNumericSymbol]) {
        isUserNameCorrect = NO;
    } else if ( username.length < kMinCountOfUsername || username.length > kMaxCountOfUsername) {
        isUserNameCorrect = NO;
    }
    
    return isUserNameCorrect;
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
        NSString *username = [inputDataArray objectAtIndex:SignUpViewItemIndexUsername];
        errorString = [NSString stringWithFormat:NSLocalizedString(@"SignUpView_Alert_Message_Error_UsernameTaken_%@", nil), username];
    }else if (errorCode == kPFErrorUserEmailTaken) {
        NSString *email = [inputDataArray objectAtIndex:SignUpViewItemIndexEmail];
        errorString = [NSString stringWithFormat:NSLocalizedString(@"SignUpView_Alert_Message_Error_EmailTaken_%@", nil), email];
    }else {
		errorString = [error userInfo][@"error"];
	}
    
    return errorString;
}

#pragma mark - Open Safari
- (void)showActionSheetWithURL:(NSURL *)URL
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    
    actionSheet.title = URL.absoluteString;
    actionSheet.cancelButtonIndex = 1;
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Common_ActionSheet_OpenInSafari", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Common_ActionSheet_Cancel", nil)];
    actionSheet.tapBlock = ^(UIActionSheet *actionSheet, NSInteger buttonIndex){
        switch (buttonIndex) {
            case 0:
                [[UIApplication sharedApplication] openURL:URL];
                break;
            case 1:
                //Cancel
                break;
        }
    };
    
    [actionSheet showInView:self.view];
}

@end
