//
//  PXNameValueParser.m
//  PixateCore
//
//  Created by Kevin Lindsey on 12/10/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXNameValueParser.h"
#import "PXStylesheetTokenType.h"

@implementation PXNameValueParser

- (BOOL)canParse
{
    return [self isType:PXSS_IDENTIFIER];
}

- (id)parse
{
    NSString *result = nil;
    
    if ([self isType:PXSS_IDENTIFIER])
    {
        result = self.currentLexeme.value;
        [self advance];
    }

    return result;
}

@end
