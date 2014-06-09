//
//  EditAnswerViewController.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/05/07.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "EditAnswerViewController.h"

@interface EditAnswerViewController ()

@property (weak, nonatomic) IBOutlet LUPlaceholderTextView *textView;

@end

@implementation EditAnswerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"EditAnswerView_Title", nil);
    
    if (![self isNewQuestion]) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                               target:self
                                                                                               action:@selector(didPushCancelButton)];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                             target:self
                                                                             action:@selector(didPushDoneButton)];
    [self enableDoneButtonWithWordCount:0];
    
    self.textView.placeholder = [self.question objectForKey:kLUQuestionTitleKey];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)enableDoneButtonWithWordCount:(long)wordCount
{
    if (wordCount > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (BOOL)isNewQuestion
{
    return [self.question isDirty];
}

#pragma mark - CloseView

- (void)didPushCancelButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didPushDoneButton
{
    [self saveObject];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveObject
{
    PFObject *question = self.question;
    
    if ([self isNewQuestion]) {
        [question saveInBackground];
    }
    
    PFObject *answer = [PFObject objectWithClassName:kLUAnswerClassKey];
    [answer setObject:[PFUser currentUser] forKey:kLUAnswerAutherKey];
    [answer setObject:question forKey:kLUAnswerQuestionKey];
    [answer setObject:self.textView.text forKey:kLUAnswerTitleKey];
    [answer saveInBackground];
    [answer saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [[NSNotificationCenter defaultCenter] postNotificationName:LUEditAnswerViewControllerUserDidAnswerNotification object:nil];
        }
    }];
}

#pragma mark - TextView

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // UITexView の文字数
    long wordCountInTextView = textView.text.length;
    
    // キーボードから入力された文字数
    long wordCountFromKeyboard = text.length;
    
    // カット、ペースト、デリートされた文字数
    long wordCountFromCopyAndPaste = range.length;
    
    // 実際に UITextView に入力されている文字数
    long wordCount = (wordCountInTextView - wordCountFromCopyAndPaste) + wordCountFromKeyboard;
    NSLog(@"wordCount : %ld", wordCount);
    
    [self enableDoneButtonWithWordCount:wordCount];
    
    return YES;
}

////textViewがキーボードで隠れないようにする。下記を参考
//http://hitoshiohtubo.blog.fc2.com/blog-entry-18.html
- (void)keyboardDidShow:(NSNotification *)anotification
{
    NSDictionary *info = [anotification userInfo];
    
    //表示開始時のキーボードのRect
    CGRect beginRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect cBeginRect = [[self.textView superview] convertRect:beginRect toView:nil];
    
    //表示完了時のキーボードのRect
    CGRect endRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect cEndRect = [[self.textView superview] convertRect:endRect toView:nil];
    
    CGRect frame = [self.textView frame];
    if (cBeginRect.size.height == cEndRect.size.height)//新しいキーボードが表示された時（開始時と完了時で、キーボードのサイズが同じ）
    {
        frame.size.height -= cBeginRect.size.height;
    }
    else//キーボードが変更された時（開始時と完了時で、キーボードのサイズが違う）
    {
        frame.size.height -= (cEndRect.size.height - cBeginRect.size.height);
    }
    [self.textView setFrame:frame];
}

@end



