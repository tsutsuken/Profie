//
//  UIColor+ColorWithHex.h
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/06/08.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

//下記を参考
//http://d.hatena.ne.jp/sakusan_net/20100906/1283740351

#import <UIKit/UIKit.h>

@interface UIColor (ColorWithHex)

+ (UIColor*)colorWithHexString:(NSString*)string;

@end
