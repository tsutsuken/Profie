//
//  LUTimeFormatter.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/06/08.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "LUTimeFormatter.h"

@implementation LUTimeFormatter

static LUTimeFormatter *_sharedData = nil;

+ (LUTimeFormatter *)sharedManager
{
    static dispatch_once_t  onceToken;
    dispatch_once(&onceToken, ^{
        //1度だけ実行するコード
        _sharedData = [[LUTimeFormatter alloc] init];
    });
    
    return _sharedData;
}

- (id)init
{
    self = [super init];
    if (self) {
        //Initialization
        self.pastDeicticExpression = kLUFormatterPastDeicticExpression;
        self.suffixExpressionFormat = kLUFormatterSuffixExpressionFormat;
        self.usesAbbreviatedCalendarUnits = YES;
    }
    return self;
}

@end
