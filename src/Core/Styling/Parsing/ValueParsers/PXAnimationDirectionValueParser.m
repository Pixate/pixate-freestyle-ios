//
//  PXAnimationDirectionValueParser.m
//  PixateAnimationModule
//
//  Created by Kevin Lindsey on 12/10/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXAnimationDirectionValueParser.h"
#import "PXAnimationInfo.h"
#import "PXStylesheetTokenType.h"

@implementation PXAnimationDirectionValueParser

+ (void)initialize
{
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        ANIMATION_DIRECTION_MAP = @{
            @"normal": @(PXAnimationDirectionNormal),
            @"reverse": @(PXAnimationDirectionReverse),
            @"alternate": @(PXAnimationDirectionAlternate),
            @"alternate-reverse": @(PXAnimationDirectionAlternateReverse),
        };
    });
}

- (BOOL)canParse
{
    return [self isType:PXSS_IDENTIFIER] && ([ANIMATION_DIRECTION_MAP objectForKey:self.currentLexeme.value] != nil);
}

- (id)parse
{
    PXAnimationDirection result = PXAnimationDirectionUndefined;

    if ([self canParse])
    {
        NSString *text = self.currentLexeme.value;
        NSNumber *value = [ANIMATION_DIRECTION_MAP objectForKey:[text lowercaseString]];

        if (value)
        {
            result = (PXAnimationDirection) [value intValue];
        }
    }
    else
    {
        [self errorWithMessage:@"Expected identifier for animation direction"];
    }

    [self advance];

    return @(result);
}

@end
