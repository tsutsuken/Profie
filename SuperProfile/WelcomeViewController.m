//
//  WelcomeViewController.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/06/24.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "WelcomeViewController.h"

@interface WelcomeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *logInButton;

@end

@implementation WelcomeViewController

#pragma mark - Initialization

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configureImageView];
    
    self.subtitleLabel.text = NSLocalizedString(@"WelcomeView_Label_Subtitle", nil);
    
    [self configureButtons];
}

- (void)configureImageView
{
    UIImage *image;
    if ([UIScreen mainScreen].bounds.size.height == 568) {
        
        // 640*1136 device
        image = [UIImage imageNamed:@"bg_welcome-568h@2x.png"];
    } else {
        
        // Other
        image = [UIImage imageNamed:@"bg_welcome.png"];
    }

    self.imageView.image = image;
}

- (void)configureButtons
{
    //SignUpButton
    self.signUpButton.layer.cornerRadius = 3;
    [self.signUpButton setTitle:NSLocalizedString(@"WelcomeView_Button_SignUp", nil) forState:UIControlStateNormal];
    [self.signUpButton addTarget:self action:@selector(showSignUpView) forControlEvents:UIControlEventTouchUpInside];
    
    //LogInButton
    self.logInButton.layer.cornerRadius = 3;
    [self.logInButton setTitle:NSLocalizedString(@"WelcomeView_Button_LogIn", nil) forState:UIControlStateNormal];
    [self.logInButton addTarget:self action:@selector(showLogInView) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Show Other View

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LOG(@"%@", [segue identifier]);
    if ([[segue identifier] isEqualToString:@"showSignUpView"]) {
        SignUpViewController *controller = (SignUpViewController *)segue.destinationViewController;
        controller.delegate = self;
    } else if ([[segue identifier] isEqualToString:@"showLogInView"]) {
        LogInViewController *controller = (LogInViewController *)segue.destinationViewController;
        controller.delegate = self;
    }
}

#pragma mark - SignUpView
- (void)showSignUpView
{
    [self performSegueWithIdentifier:@"showSignUpView" sender:self];
}

#pragma mark - LogInView
- (void)showLogInView
{
    [self performSegueWithIdentifier:@"showLogInView" sender:self];
}

#pragma mark - SignUpViewControllerDelegate
- (void)signUpViewController:(SignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
}

#pragma mark - LogInViewControllerDelegate

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(LogInViewController *)logInController didLogInUser:(PFUser *)user
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
}

/*
- (IBAction)didPushSignUpButton
{
    PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
    signUpViewController.delegate = self;
    signUpViewController.fields = PFSignUpFieldsUsernameAndPassword | PFSignUpFieldsEmail | PFSignUpFieldsSignUpButton;
    
    [self.navigationController pushViewController:signUpViewController animated:YES];
}

- (IBAction)didPushLogInButton
{
    PFLogInViewController *loginViewController = [[PFLogInViewController alloc] init];
    loginViewController.delegate = self;
    loginViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton;
    
   [self.navigationController pushViewController:loginViewController animated:YES];
}
*/
/*
#pragma mark - PFSignUpViewControllerDelegate

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
}
 */

/*
#pragma mark - PFLogInViewControllerDelegate

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
}
*/



@end
