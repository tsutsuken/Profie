//
//  EmptyView.h
//  Profie
//
//  Created by Ken Tsutsumi on 2014/09/17.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmptyView : UIView

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@end
