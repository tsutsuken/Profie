//
//  LVAnalyticsManager.h
//  Profie
//
//  Created by Ken Tsutsumi on 2014/08/06.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LVAnalyticsManager : NSObject

+ (LVAnalyticsManager *)sharedManager;

- (void)trackView:(id)sender;
- (void)trackEvent:(NSString *)actionName sender:(id)sender;

@end
