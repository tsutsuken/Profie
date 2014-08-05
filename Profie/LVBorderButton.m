//
//  LVBorderButton.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/06/17.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "LVBorderButton.h"

@implementation LVBorderButton

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self configureButton];
    }
    return self;
}

- (void)configureButton
{
    self.layer.borderWidth = 1.0;
    self.layer.cornerRadius = 6;
}

#pragma mark - Delegate

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self setNeedsDisplay];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];//drawRectのNormalを呼び出す。imageだけのボタンで必要。
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    UIColor *textColor;
    UIColor *borderColor;
    UIColor *backgroundColor;
    
    if (self.enabled) {
        if (self.selected) {
            //Selected
            textColor = [UIColor whiteColor];
            borderColor = [self titleColorForState:UIControlStateNormal];
            backgroundColor = borderColor;
        }else {
            //Normal
            textColor = [self titleColorForState:UIControlStateNormal];
            borderColor = textColor;
            backgroundColor = [UIColor clearColor];
        }
    }else {
		//Disabled
        textColor = [self titleColorForState:UIControlStateDisabled];
        borderColor = textColor;
        backgroundColor = [UIColor clearColor];
	}
    
    UIColor *imageColor = textColor;
    
    self.titleLabel.textColor = textColor;
    self.imageView.image = [self.imageView.image imageTintedWithColor:imageColor];
    self.layer.borderColor = borderColor.CGColor;
    self.layer.backgroundColor = backgroundColor.CGColor;
}

@end
