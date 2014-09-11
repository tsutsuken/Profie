//
//  ProfileSettingViewController.m
//  Profie
//
//  Created by Ken Tsutsumi on 2014/09/11.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "ProfileSettingViewController.h"

@interface ProfileSettingViewController ()

@end

@implementation ProfileSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"ProfileSettingView_Title", nil);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];//編集後のFullnameを表示するため
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *currentUser = [User currentUser];
    
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell" forIndexPath:indexPath];
        
        PFRoundedImageView *imageView = (PFRoundedImageView *)[cell viewWithTag:1];
        imageView.userInteractionEnabled = NO;//To pass through touch event
        imageView.file = currentUser.profilePictureSmall;
        [imageView loadInBackground];
        
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:2];
        titleLabel.text = NSLocalizedString(@"ProfileSettingView_Cell_ProfileImage", nil);
        
        return cell;
    } else {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.textLabel.text = NSLocalizedString(@"ProfileSettingView_Cell_Fullname", nil);
        cell.detailTextLabel.text = currentUser.fullname;
        return cell;
	}
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self showActionSheetForSelectingImage];
    } else {
        [self showProfileItemSettingView];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - SelectImage

- (void)showActionSheetForSelectingImage
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    
    actionSheet.delegate = self;
    actionSheet.cancelButtonIndex = 2;
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Common_ActionSheet_Camera", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Common_ActionSheet_Album", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Common_ActionSheet_Cancel", nil)];
    actionSheet.tapBlock = ^(UIActionSheet *actionSheet, NSInteger buttonIndex){
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
    };
    
    [actionSheet showInView:self.view];
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
    User *currentUser = [User currentUser];
    [largeImageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Uploaded largeImageFile");
            currentUser.profilePictureLarge = largeImageFile;
            [currentUser saveInBackgroundWithBlock:nil];
        }
    }];
    
    [mediumImageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Uploaded mediumImageFile");
            currentUser.profilePictureMedium = mediumImageFile;
            [currentUser saveInBackgroundWithBlock:nil];
        }
    }];
    
    [smallImageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Uploaded smallImageFile");
            currentUser.profilePictureSmall = smallImageFile;
            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    [self.tableView reloadData];//セル内の画像を更新するため
                    [currentUser fetchInBackgroundWithBlock:nil];//currentUserのキャッシュを更新するため
                }
            }];
        }
    }];
}

#pragma mark - Show Other View

#pragma mark ProfileItemSettingView

- (void)showProfileItemSettingView
{
    [self performSegueWithIdentifier:@"showProfileItemSettingView" sender:self];
}


@end
