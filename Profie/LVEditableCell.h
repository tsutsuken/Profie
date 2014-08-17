//
//  LVEditableCell.h
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/06/28.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LVEditableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end
