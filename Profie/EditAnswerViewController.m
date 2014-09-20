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
@property (weak, nonatomic) IBOutlet PFRoundedImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) UIButton *twitterButton;

@end

@implementation EditAnswerViewController

static NSString *kAssociatedObjectKeyAccountArray = @"kAssociatedObjectKeyAccountArray";

#pragma mark - Initialization

- (void)dealloc
{
    [self removeNotifications];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNotifications];
    
    [self searchPastAnswerIfNeeded];
    
    self.shareKitTwitter = [[LVShareKitTwitter alloc] init];
    self.shareKitTwitter.delegate = self;
    
    self.title = NSLocalizedString(@"EditAnswerView_Title", nil);
    
    [self configureNavigationButtons];
    
    [self configureTableHeaderView];
    
    [self configureTextView];
    
    [self enableDoneButtonWithWordCount:self.textView.text.length];
}

- (void)searchPastAnswerIfNeeded
{
    if (!self.shouldSearchPastAnswer) {
        return;
    }
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.minShowTime = 0.6;
    hud.labelText = NSLocalizedString(@"EditAnswerView_HUD_SearchingPastAnswer", nil);
    [self.navigationController.view addSubview:hud];
    
    [hud showAnimated:YES whileExecutingBlock:^{
        Answer *answer = [LVUtility answerOfCurrentUserForQuestion:self.question];
        if (answer) {
            self.answer = answer;
        }
    } completionBlock:^{
        if (self.answer) {
            self.textView.text = self.answer.title;
        }
        [hud removeFromSuperview];
    }];
}

- (void)configureNavigationButtons
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

- (void)configureTableHeaderView
{
    User *currentUser = [User currentUser];
    
    [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:currentUser.profilePictureMedium.url]
                             placeholderImage:[UIImage imageNamed:@"person_small.png"]];
    
    self.usernameLabel.text =  currentUser.username;
    
    self.questionLabel.text = self.question.titleWithTag;
}

- (void)configureTextView
{
    self.automaticallyAdjustsScrollViewInsets = NO;//To aboid bug about textView inset
    
    if (![self isNewAnswer]) {
        self.textView.text = self.answer.title;
    }
    
    [self configureTwitterButton];
    
    [self.textView becomeFirstResponder];
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [ANALYTICS trackView:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.textView resignFirstResponder];
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
}

- (void)saveObjects
{
    //Save Question　→Save Answer
    if ([self isNewQuestion]) {
        [self.question saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                //AnswerをSaveする前に、QuestionをSaveする必要がある。objectIdとか使うし
                [self saveAnswer];
                
                [ANALYTICS trackEvent:kAnEventAddQuestion sender:self];
            }
        }];
    }
    else {
		[self saveAnswer];
	}
}

- (void)saveAnswer
{
    Answer *answer;
    if ([self isNewAnswer]) {
        answer = [Answer object];
        answer.auther = [User currentUser];
        answer.question = self.question;
        answer.questionId = self.question.objectId;
        
        [answer.question incrementAnswerCount];
        
        [ANALYTICS trackEvent:kAnEventAddAnswer sender:self];
    }
    else {
        answer = self.answer;
        
        [ANALYTICS trackEvent:kAnEventEditAnswer sender:self];
	}
    
    answer.title = self.textView.text;
    [answer saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kLVNotificationDidEditAnswer object:nil];
            
            [self.shareKitTwitter postAnswerIfNeeded:answer];
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
    
    [self enableDoneButtonWithWordCount:wordCount];
    
    return YES;
}

#pragma mark - NSNotification

- (void)setNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
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



