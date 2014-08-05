//
//  SettingViewController.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/07/18.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

#pragma mark - Initialization
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(didPushDoneButton)];
    
    self.title = NSLocalizedString(@"SettingView_Title", nil);
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell" forIndexPath:indexPath];
        
        PFUser *currentUser = [PFUser currentUser];
        
        PFRoundedImageView *imageView = (PFRoundedImageView *)[cell viewWithTag:1];
        imageView.file = [currentUser objectForKey:kLVUserProfilePicSmallKey];
        [imageView loadInBackground];
        
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:2];
        titleLabel.text = NSLocalizedString(@"SettingView_Cell_ProfileImage", nil);
        
        return cell;
    } else if (indexPath.section == 1) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.textLabel.text = NSLocalizedString(@"SettingView_Cell_ShareSetting", nil);
        return cell;
	} else {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogOutCell" forIndexPath:indexPath];
        cell.textLabel.text = NSLocalizedString(@"SettingView_Cell_LogOut", nil);
        return cell;
	}
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self showImageSelectionActionSheet];
    } else if (indexPath.section == 1) {
        [self showShareSettingView];
    } else {
		[self logOut];
	}
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - SelectImage
#pragma mark UIActionSheet

- (void)showImageSelectionActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    
    actionSheet.delegate = self;
    actionSheet.cancelButtonIndex = 2;
    [actionSheet addButtonWithTitle:NSLocalizedString(@"SettingView_ActionSheet_Camera", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"SettingView_ActionSheet_Album", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"SettingView_ActionSheet_Cancel", nil)];
    
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

#pragma mark UIImagePicker

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
    
    UIImage *largeImage = [image resizedImageToSize:kSizeProfileImageLarge];
    UIImage *mediumImage = [image resizedImageToSize:kSizeProfileImageMedium];
    UIImage *smallImage = [image resizedImageToSize:kSizeProfileImageSmall];
    
    NSData *largeImageData = UIImageJPEGRepresentation(largeImage, 0.5);
    NSData *mediumImageData = UIImageJPEGRepresentation(mediumImage, 0.5);
    NSData *smallImageData = UIImageJPEGRepresentation(smallImage, 0.5);
    
    PFFile *largeImageFile = [PFFile fileWithData:largeImageData];
    PFFile *mediumImageFile = [PFFile fileWithData:mediumImageData];
    PFFile *smallImageFile = [PFFile fileWithData:smallImageData];
    
    // Save PFFile
    [largeImageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Uploaded largeImageFile");
            [[PFUser currentUser] setObject:largeImageFile forKey:kLVUserProfilePicLargeKey];
            [[PFUser currentUser] saveInBackgroundWithBlock:nil];
        }
    }];
    
    [mediumImageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Uploaded mediumImageFile");
            [[PFUser currentUser] setObject:mediumImageFile forKey:kLVUserProfilePicMediumKey];
            [[PFUser currentUser] saveInBackgroundWithBlock:nil];
        }
    }];
    
    [smallImageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Uploaded smallImageFile");
            [[PFUser currentUser] setObject:smallImageFile forKey:kLVUserProfilePicSmallKey];
            
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    [self.tableView reloadData];//セル内の画像を更新するため
                    [[PFUser currentUser] fetchInBackgroundWithBlock:nil];//currentUserのキャッシュを更新するため
                }
            }];
        }
    }];
}

#pragma mark - LogOut

- (void)logOut
{
    [self dismissViewControllerAnimated:NO completion:^{
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] logOut];
    }];
}

#pragma mark - Show Other View
#pragma mark EditProfileView

- (void)showShareSettingView
{
    [self performSegueWithIdentifier:@"showShareSettingView" sender:self];
}

@end
