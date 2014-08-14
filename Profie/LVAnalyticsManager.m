//
//  LVAnalyticsManager.m
//  Profie
//
//  Created by Ken Tsutsumi on 2014/08/06.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "LVAnalyticsManager.h"

@implementation LVAnalyticsManager

#pragma mark - Initialization

+ (LVAnalyticsManager *)sharedManager
{
    static LVAnalyticsManager* sharedSingleton;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedSingleton = [[LVAnalyticsManager alloc] initSharedManager];
    });
    
    return sharedSingleton;
}

- (id)initSharedManager
{
    self = [super init];
    if (self)
    {
        // 初期化処理
    }
    return self;
}

//initされることを防ぐ
- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Methods For Other Class

- (void)trackView:(id)sender
{
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName value:NSStringFromClass([sender class])];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName value:nil];
}

- (void)trackEvent:(NSString *)actionName sender:(id)sender
{
    NSDictionary *parameters = [[GAIDictionaryBuilder createEventWithCategory:NSStringFromClass([sender class])
                                                                       action:actionName
                                                                        label:@""
                                                                        value:@-1] build];
    
    [[GAI sharedInstance].defaultTracker send:parameters];  // Event value
    
}

/*

- (void)trackPropertyWithKey:(NSString *)key value:(NSString *)value sender:(id)sender
{
    [GA_TRACKER sendEventWithCategory:NSStringFromClass([sender class])
                           withAction:key
                            withLabel:value
                            withValue:@-1];
}

- (void)registerSuperProperties:(NSDictionary *)properties
{
    [MP_TRACKER registerSuperProperties:properties];
}
 */

@end
