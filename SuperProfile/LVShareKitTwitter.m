//
//  LVShareKitTwitter.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/07/22.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "LVShareKitTwitter.h"

@implementation LVShareKitTwitter

#define kLUUserDefaultsKeyShouldShareOnTwitter @"kLUUserDefaultsKeyShouldShareOnTwitter"
#define kLUUserDefaultsKeyAccountIdTwitter @"kLUUserDefaultsKeyAccountIdTwitter"
static NSString *kAssociatedObjectKeyAccountArray = @"kAssociatedObjectKeyAccountArray";

- (BOOL)isAuthorized
{
    BOOL isAuthorized = NO;
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    BOOL accessGranted = accountType.accessGranted;
    
    NSString *selectedAccount = [[NSUserDefaults standardUserDefaults] stringForKey:kLUUserDefaultsKeyAccountIdTwitter];
    
    if (accessGranted && selectedAccount) {
        isAuthorized = YES;
    } else {
		[self logout];
	}
    
    return isAuthorized;
}

- (BOOL)shouldShare
{
    BOOL shouldShare = [[NSUserDefaults standardUserDefaults] boolForKey:kLUUserDefaultsKeyShouldShareOnTwitter];
    
    return shouldShare;
}

- (void)setShouldShare:(BOOL)shouldShare
{
    [[NSUserDefaults standardUserDefaults] setBool:shouldShare forKey:kLUUserDefaultsKeyShouldShareOnTwitter];
}

#pragma mark - Authorize
- (void)authorizeInViewController:(UIViewController *)viewController
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        [accountStore
         requestAccessToAccountsWithType:accountType
         options:nil
         completion:^(BOOL granted, NSError *error) {
             [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                 if (granted) {
                     if ([[NSUserDefaults standardUserDefaults] stringForKey:kLUUserDefaultsKeyAccountIdTwitter]) {
                         [self didSucceedAuthorizing];
                     } else {
                         NSArray *accountArray = [accountStore accountsWithAccountType:accountType];
                         UIActionSheet *actionSheet = [self actionSheetWithAccountArray:accountArray];
                         [actionSheet showInView:viewController.view];
                     }
                 } else {
                     [self didFailToAuthorize];
                     [self showAlertWithMessage:NSLocalizedString(@"LVShareKitTwitter_Alert_Message_Error_Twitter_AccessDenied", nil)];
                 }
             }];
         }];
    }
}

#pragma mark UIActionSheet
- (UIActionSheet *)actionSheetWithAccountArray:(NSArray *)accountArray
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    objc_setAssociatedObject(actionSheet, CFBridgingRetain(kAssociatedObjectKeyAccountArray), accountArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    for (int i = 0; i < [accountArray count]; i++) {
        ACAccount *account = [accountArray objectAtIndex:i];
        [actionSheet addButtonWithTitle:account.username];
    }
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Common_ActionSheet_Cancel", nil)];
    actionSheet.cancelButtonIndex = [accountArray count];
    
    return actionSheet;
}

-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSArray *accountArray = objc_getAssociatedObject(actionSheet, CFBridgingRetain(kAssociatedObjectKeyAccountArray));
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        [self didFailToAuthorize];
    } else {
		ACAccount *selectedAccount = [accountArray objectAtIndex:buttonIndex];
        [[NSUserDefaults standardUserDefaults] setObject:selectedAccount.identifier forKey:kLUUserDefaultsKeyAccountIdTwitter];
        [self didSucceedAuthorizing];
	}
}

#pragma mark UIAlert
- (void)showAlertWithMessage:(NSString *)message
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil];
    [alert show];
}

#pragma mark Delegate
- (void)didSucceedAuthorizing
{
    if ([self.delegate respondsToSelector:@selector(shareKitDidSucceedAuthorizing)]) {
        [self.delegate shareKitDidSucceedAuthorizing];
    }
}

- (void)didFailToAuthorize
{
    if ([self.delegate respondsToSelector:@selector(shareKitDidFailToAuthorize)]) {
        [self.delegate shareKitDidFailToAuthorize];
    }
}

#pragma mark - Logout
- (void)logout
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLUUserDefaultsKeyAccountIdTwitter];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kLUUserDefaultsKeyShouldShareOnTwitter];
}

#pragma mark - Post
- (void)postMessageIfNeeded:(NSString *)message
{
    if ([self shouldShare] && [self isAuthorized]){
        NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
        NSDictionary *params = [NSDictionary dictionaryWithObject:message forKey:@"status"];
        
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                requestMethod:SLRequestMethodPOST
                                                          URL:url
                                                   parameters:params];
        
        NSString *accountId = [[NSUserDefaults standardUserDefaults] stringForKey:kLUUserDefaultsKeyAccountIdTwitter];
        ACAccount *account = [[[ACAccountStore alloc] init] accountWithIdentifier:accountId];
        [request setAccount:account];
        
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            NSLog(@"responseData=%@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
        }];
    }
}

@end
