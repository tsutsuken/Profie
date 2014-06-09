//
//  AnswerCell.h
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/06/08.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import <Parse/Parse.h>

@interface AnswerCell : PFTableViewCell

@property (weak, nonatomic) IBOutlet PFRoundedImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UILabel *answerLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
