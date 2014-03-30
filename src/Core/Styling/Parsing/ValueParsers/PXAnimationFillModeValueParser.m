//
//  PXAnimationFillModeValueParser.m
//  PixateAnimationModule
//
//  Created by Kevin Lindsey on 12/10/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXAnimationFillModeValueParser.h"
#import "PXAnimationInfo.h"
#import "PXStylesheetTokenType.h"

@implementation PXAnimationFillModeValueParser

+ (void)initialize
{
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        ANIMATION_FILL_MODE_MAP = @{
            @"none": @(PXAnimationFillModeNone),
            @"forwards" : @(PXAnimationFillModeForwards),
            @"backwards" : @(PXAnimationFillModeBackwards),
            @"both" : @(PXAnimationFillModeBoth),
        };
    });
}

- (BOOL)canParse
{
    return [self isType:PXSS_IDENTIFIER] && ([ANIMATION_FILL_MODE_MAP objectForKey:self.currentLexeme.value] != nil);
}

- (id)parse
{
    PXAnimationFillMode result = PXAnimationFillModeUndefined;

    if ([self canParse])
    {
        NSString *text = self.currentLexeme.value;
        NSNumber *value = [ANIMATION_FILL_MODE_MAP objectForKey:[text lowercaseString]];

        if (value)
        {
            result = (PXAnimationFillMode) [value intValue];
        }
    }
    else
    {
        [self errorWithMessage:@"Expected identifier for animation fill mode"];
    }

    [self advance];

    return @(result);
}

@end
