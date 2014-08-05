//
//  EditQuestionViewController.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/05/02.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "EditQuestionViewController.h"

@interface EditQuestionViewController ()

@property (weak, nonatomic) IBOutlet LVPlaceholderTextView *textView;

@end

@implementation EditQuestionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"EditQuestionView_Title", nil);
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(didPushCancelButton)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"EditQuestionView_Button_Next", nil)
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(didPushNextButton)];
    [self enableBarButtonItemWithWordCount:0];
    
    self.textView.placeholder = NSLocalizedString(@"EditQuestionView_Placeholder", nil);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:YES animated:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //[self.textView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)enableBarButtonItemWithWordCount:(long)wordCount
{
    if (wordCount > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

#pragma mark - CloseView

- (void)didPushCancelButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didPushNextButton
{
    [self showEditAnswerView];
}

#pragma mark - Show Other View

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LOG(@"%@", [segue identifier]);
    
    if([[segue identifier] isEqualToString:@"showEditAnswerView"])
    {
        EditAnswerViewController *controller = (EditAnswerViewController *)segue.destinationViewController;

        Question *question = [Question object];
        [question.ACL setPublicWriteAccess:YES];
        question.auther = [PFUser currentUser];
        question.title = self.textView.text;
        controller.question = question;
    }
}

#pragma mark EditAnswerView

- (void)showEditAnswerView
{
    [self performSegueWithIdentifier:@"showEditAnswerView" sender:self];
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
    
    [self enableBarButtonItemWithWordCount:wordCount];
    
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
