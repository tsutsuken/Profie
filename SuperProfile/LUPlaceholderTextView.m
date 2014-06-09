//
//  LUPlaceholderTextView.m
//  SuperProfile
//
//  Created by Ken Tsutsumi on 2014/05/03.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "LUPlaceholderTextView.h"

@implementation LUPlaceholderTextView

//下記を参照
//https://devforums.apple.com/message/889840#889840


//最後の一文字が編集出来なくなるので、実装しない
/*
 //行末にカーソルが合わない問題、を解決
 - (UITextPosition *)closestPositionToPoint:(CGPoint)point
 {
 point.y -= self.textContainerInset.top;
 point.x -= self.textContainerInset.left;
 
 NSUInteger glyphIndex = [self.layoutManager glyphIndexForPoint:point inTextContainer:self.textContainer];
 NSUInteger characterIndex = [self.layoutManager characterIndexForGlyphAtIndex:glyphIndex];
 UITextPosition *pos = [self positionFromPosition:self.beginningOfDocument offset:characterIndex];
 
 return pos;
 }
 */

//最後の行がキーボードに隠れる問題、を解決
- (void)scrollRangeToVisible:(NSRange)range
{
    [super scrollRangeToVisible:range];
    
    if (self.layoutManager.extraLineFragmentTextContainer != nil && self.selectedRange.location == range.location)
    {
        CGRect caretRect = [self caretRectForPosition:self.selectedTextRange.start];
        [self scrollRectToVisible:caretRect animated:YES];
    }
}



@end
