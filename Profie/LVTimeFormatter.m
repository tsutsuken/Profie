//
//  LVTimeFormatter.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/06/08.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "LVTimeFormatter.h"

@implementation LVTimeFormatter

static LVTimeFormatter *_sharedData = nil;

+ (LVTimeFormatter *)sharedManager
{
    static dispatch_once_t  onceToken;
    dispatch_once(&onceToken, ^{
        //1度だけ実行するコード
        _sharedData = [[LVTimeFormatter alloc] init];
    });
    
    return _sharedData;
}

- (id)init
{
    self = [super init];
    if (self) {
        //Initialization
        self.pastDeicticExpression = @"";
        self.suffixExpressionFormat = @"%@%@";
        self.usesAbbreviatedCalendarUnits = YES;
    }
    return self;
}

@end
