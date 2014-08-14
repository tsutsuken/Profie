//
//  UIColor+ColorWithHex.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/06/08.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "UIColor+ColorWithHex.h"

@implementation UIColor (ColorWithHex)

+ (UIColor*)colorWithHexString:(NSString *)hexString
{
    //#を除いた形式
    
	NSScanner *colorScanner = [NSScanner scannerWithString:hexString];
	unsigned int color;
    
	[colorScanner scanHexInt:&color];
    
	CGFloat r = ((color & 0xFF0000) >> 16)/255.0f;
	CGFloat g = ((color & 0x00FF00) >> 8) /255.0f;
	CGFloat b =  (color & 0x0000FF) /255.0f;
    
	//NSLog(@"HEX to RGB >> r:%f g:%f b:%f",r,g,b);
    
	return [UIColor colorWithRed:r green:g blue:b alpha:1];
}

@end
