//
//  EditAnswerViewController.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/05/07.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "EditAnswerViewController.h"

@interface EditAnswerViewController ()

@property (strong, nonatomic) LVShareKitTwitter *shareKitTwitter;
@property (weak, nonatomic) IBOutlet LUPlaceholderTextView *textView;
@property (strong, nonatomic) UIButton *twitterButton;

@end

@implementation EditAnswerViewController

static NSString *kAssociatedObjectKeyAccountArray = @"kAssociatedObjectKeyAccountArray";

#pragma mark - Initialization

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"EditAnswerView_Title", nil);
    
    self.shareKitTwitter = [[LVShareKitTwitter alloc] init];
    self.shareKitTwitter.delegate = self;
    
    [self configureNavigationBar];
    
    [self configureTextView];
    
    [self enableDoneButtonWithWordCount:self.textView.text.length];
}

- (void)configureNavigationBar
{
    if (![self isNewQuestion]) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                              target:self
                                                                                              action:@selector(didPushCancelButton)];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(didPushDoneButton)];
}

- (void)configureTextView
{
    self.textView.placeholder = [self.question objectForKey:kLUQuestionTitleKey];
    
    if (![self isNewAnswer]) {
        self.textView.text = [self.answer objectForKey:kLUAnswerTitleKey];
    }
    
    [self configureTwitterButton];
}

- (void)configureTwitterButton
{
	UIView* accessoryView =[[UIView alloc] initWithFrame:CGRectMake(0,0,320,44)];
	self.twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
	self.twitterButton.frame = CGRectMake(276, 0, 30, 30);
    [self.twitterButton setImage:[UIImage imageNamed:@"twitter_gray"] forState:UIControlStateNormal];
    [self.twitterButton setImage:[UIImage imageNamed:@"twitter_blue"] forState:UIControlStateSelected];
	[self.twitterButton addTarget:self action:@selector(didPushTwitterButton) forControlEvents:UIControlEventTouchUpInside];
	[accessoryView addSubview:self.twitterButton];
	self.textView.inputAccessoryView = accessoryView;

    if ([self.shareKitTwitter shouldShare] && [self.shareKitTwitter isAuthorized]) {
        self.twitterButton.selected = YES;
    }
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Share on Twitter
- (void)didPushTwitterButton
{
    BOOL shouldSelect = !self.twitterButton.selected;
    
    if (shouldSelect == YES) {
        [self.shareKitTwitter authorizeInViewController:self];
    } else {
		[self switchTwitterButtonWithSelected:NO];
	}
}

- (void)switchTwitterButtonWithSelected:(BOOL)selected
{
    [self.shareKitTwitter setShouldShare:selected];
    self.twitterButton.selected = selected;
}

#pragma mark ShareKitTwitter delegate

- (void)shareKitDidSucceedAuthorizing
{
    [self switchTwitterButtonWithSelected:YES];
}

#pragma mark - CloseView

- (void)didPushCancelButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didPushDoneButton
{
    [self saveObjects];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self.shareKitTwitter postMessageIfNeeded:[self messageToShare]];
}

- (NSString *)messageToShare
{
    NSString *messageToShare;
    
    NSString *answer = self.textView.text;
    NSString *question = [self.question valueForKey:kLUQuestionTitleKey];
    NSString *profieTag = @"#Profie";
    
    messageToShare = [NSString stringWithFormat:@"%@ %@ %@", answer, question, profieTag];
    
    return messageToShare;
}

- (void)saveObjects
{
    //Save Question　→Save Answer
    if ([self isNewQuestion]) {
        [self.question saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                //AnswerをSaveする前に、QuestionをSaveする必要がある。objectIdとか使うし
                [self saveAnswer];
            }
        }];
    }
    else {
		[self saveAnswer];
	}
    
    [self incrementAnswerCountOfQuestion];
}

- (void)saveAnswer
{
    PFObject *answer;
    if ([self isNewAnswer]) {
        answer = [PFObject objectWithClassName:kLUAnswerClassKey];
        [answer setObject:[PFUser currentUser] forKey:kLUAnswerAutherKey];
        [answer setObject:self.question forKey:kLUAnswerQuestionKey];
        [answer setObject:self.question.objectId forKey:kLUAnswerQuestionIdKey];
    }
    else {
        answer = self.answer;
	}
    
    [answer setObject:self.textView.text forKey:kLUAnswerTitleKey];
    [answer saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [[NSNotificationCenter defaultCenter] postNotificationName:LUEditAnswerViewControllerUserDidEditAnswerNotification object:nil];
        }
    }];
}

- (void)incrementAnswerCountOfQuestion
{
    if (![self isNewAnswer]) {
        return;
    }
    
#warning test
    /*
    NSNumber *answerCount = (NSNumber *)[self.question objectForKey:kLUQuestionAnswerCountKey];
    NSNumber *newAnswerCount = @([answerCount intValue] + 1);
    [self.question setObject:newAnswerCount forKey:kLUQuestionAnswerCountKey];
    [self.question saveInBackground];
     */
    
    Question *questionObject = (Question *)self.question;
    int answerCount = questionObject.answerCount;
    int newAnswerCount = answerCount + 1;
    questionObject.answerCount = newAnswerCount;
    [questionObject saveInBackground];
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

#pragma mark - ()

- (BOOL)isNewQuestion
{
    return [self.question isDirty];
}

- (BOOL)isNewAnswer
{
    return !self.answer;
}

@end



