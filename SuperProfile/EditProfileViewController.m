//
//  EditProfileViewController.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/05/26.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "EditProfileViewController.h"

@interface EditProfileViewController ()

@property (nonatomic, strong) UIImage *image;

@end

@implementation EditProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                          target:self
                                                                                          action:@selector(didPushDoneButton)];
    
    self.title = NSLocalizedString(@"EditProfileView_Title", nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CloseView

- (void)didPushDoneButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    PFUser *currentUser = [PFUser currentUser];
    
    PFRoundedImageView *imageView = (PFRoundedImageView *)[cell viewWithTag:1];
    imageView.image = [UIImage imageNamed:@"person"];
    imageView.file = [currentUser objectForKey:kLUUserProfilePicSmallKey];
    [imageView loadInBackground];
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:2];
    titleLabel.text = NSLocalizedString(@"EditProfileView_Cell_ProfileImage", nil);
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showImageSelectionActionSheet];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIActionSheet

- (void)showImageSelectionActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    
    actionSheet.delegate = self;
    actionSheet.cancelButtonIndex = 2;
    [actionSheet addButtonWithTitle:NSLocalizedString(@"EditProfileView_ActionSheet_Camera", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"EditProfileView_ActionSheet_Album", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"EditProfileView_ActionSheet_Cancel", nil)];
    
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self pickImageWithSourceType:UIImagePickerControllerSourceTypeCamera];
            break;
        case 1:
            [self pickImageWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
        case 2:
            //Cancel
            break;
    }
}

#pragma mark - SelectImage

-(void)pickImageWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    if([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = sourceType;
        imagePicker.allowsEditing = YES;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingImage:(UIImage*)image editingInfo:(NSDictionary*)editingInfo
{
    [self uploadImage:image];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)uploadImage:(UIImage *)image
{
    //http://appllio.com/20140423-5138-twitter-new-web-profile
    //400x400 Twitterのプロフィール画像の推奨サイズ
    
    UIImage *mediumImage = [image resizedImageToSize:CGSizeMake(400, 400)];
    UIImage *smallImage = [image resizedImageToSize:CGSizeMake(100, 100)];
    
    NSData *mediumImageData = UIImageJPEGRepresentation(mediumImage, 0.5);
    NSData *smallImageData = UIImagePNGRepresentation(smallImage);
    
    PFFile *mediumImageFile = [PFFile fileWithData:mediumImageData];
    PFFile *smallImageFile = [PFFile fileWithData:smallImageData];
    
    // Save PFFile
    [mediumImageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Uploaded Profile Picture Thumbnail");
            [[PFUser currentUser] setObject:mediumImageFile forKey:kLUUserProfilePicMediumKey];
            [[PFUser currentUser] saveInBackgroundWithBlock:nil];
        }
    }];
    
    [smallImageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Uploaded Profile Picture Thumbnail");
            [[PFUser currentUser] setObject:smallImageFile forKey:kLUUserProfilePicSmallKey];
            
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    [self.tableView reloadData];//セル内の画像を更新するため
                    [[PFUser currentUser] fetchInBackgroundWithBlock:nil];//currentUserのキャッシュを更新するため
                }
            }];
        }
    }];
}

@end