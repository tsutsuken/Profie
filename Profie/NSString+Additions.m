//
//  NSString+Additions.m
//  Profie
//
//  Created by Ken Tsutsumi on 2014/09/06.
//  Copyright (c) 2014年 LvUP Inc. All rights reserved.
//

#import "NSString+Additions.h"

@implementation NSString (Additions)

//アルファベットと数字と記号のみか
- (BOOL)includesCharactersOtherThanAlphaNumericSymbol
{
    BOOL includesCharacters;
    
    NSMutableCharacterSet *characterSet = [[NSMutableCharacterSet alloc] init];
    //'a'から'z'を追加
    [characterSet addCharactersInRange:NSMakeRange('a', 26)];
    //'A'から'Z'を追加
    [characterSet addCharactersInRange:NSMakeRange('A', 26)];
    //'0'から'9'を追加
    [characterSet addCharactersInRange:NSMakeRange('0', 10)];
    //記号を追加
    [characterSet addCharactersInString:@"_"];
    
    includesCharacters = [self includesCharactersOtherThanCharacters:characterSet];
    
    return includesCharacters;
}

- (BOOL)includesCharactersOtherThanCharacters:(NSCharacterSet *)permittedCharacters
{
    BOOL includesCharacters;
    
    NSCharacterSet * charactersToBlock = [permittedCharacters invertedSet];
    
    if ([self rangeOfCharacterFromSet:charactersToBlock].location == NSNotFound) {
        includesCharacters = NO;
    } else {
        includesCharacters = YES;
    }
    
    return includesCharacters;
}

@end
