//
//  EmptyView.m
//  Profie
//
//  Created by Ken Tsutsumi on 2014/09/17.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "EmptyView.h"

@implementation EmptyView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSString *className = NSStringFromClass([self class]);
        [[NSBundle mainBundle] loadNibNamed:className owner:self options:0];
        self.contentView.frame = self.bounds;
        
        //未設定の場合に、Xibの文字が表示されないように
        self.mainLabel.text = nil;
        self.detailLabel.text = nil;
        
        [self addSubview:self.contentView];
    }
    return self;
}
@end
