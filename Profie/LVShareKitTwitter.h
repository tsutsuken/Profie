//
//  LVShareKitTwitter.h
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/07/22.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LVShareKitTwitterDelegate;

@interface LVShareKitTwitter : NSObject <UIActionSheetDelegate>

@property (nonatomic, assign) id <LVShareKitTwitterDelegate> delegate;
- (BOOL)isAuthorized;
- (BOOL)shouldShare;
- (void)setShouldShare:(BOOL)shouldShare;

- (void)authorizeInViewController:(UIViewController *)viewController;

- (void)logout;

- (void)postMessageIfNeeded:(NSString *)message;
@end

@protocol LVShareKitTwitterDelegate <NSObject>
@optional
- (void)shareKitDidSucceedAuthorizing;
- (void)shareKitDidFailToAuthorize;
@end
