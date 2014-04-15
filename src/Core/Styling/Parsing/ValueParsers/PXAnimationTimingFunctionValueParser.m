//
//  PXAnimationTimingFunctionValueParser.m
//  PixateAnimationModule
//
//  Created by Kevin Lindsey on 12/10/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXAnimationTimingFunctionValueParser.h"
#import "PXAnimationInfo.h"
#import "PXStylesheetTokenType.h"

@implementation PXAnimationTimingFunctionValueParser

+ (void)initialize
{
    ANIMATION_TIMING_FUNCTION_MAP = @{
        @"ease": @(PXAnimationTimingFunctionEase),
        @"linear": @(PXAnimationTimingFunctionLinear),
        @"ease-in": @(PXAnimationTimingFunctionEaseIn),
        @"ease-out": @(PXAnimationTimingFunctionEaseOut),
        @"ease-in-out": @(PXAnimationTimingFunctionEaseInOut),
        @"step-start": @(PXAnimationTimingFunctionStepStart),
        @"step-end": @(PXAnimationTimingFunctionStepEnd),
        // steps(<integer>[, [ start | end ] ]?)
        // cubic-bezier(<number>, <number>, <number>, <number>)
    };
}

- (BOOL)canParse
{
    return [self isType:PXSS_IDENTIFIER] && ([ANIMATION_TIMING_FUNCTION_MAP objectForKey:self.currentLexeme.value] != nil);
}

- (id)parse
{
    PXAnimationTimingFunction result = PXAnimationTimingFunctionUndefined;

    if ([self canParse])
    {
        NSString *text = self.currentLexeme.value;
        NSNumber *value = [ANIMATION_TIMING_FUNCTION_MAP objectForKey:[text lowercaseString]];

        if (value)
        {
            result = (PXAnimationTimingFunction) [value intValue];
        }
    }
    else
    {
        [self errorWithMessage:@"Expected identifier for animation timing function"];
    }

    [self advance];

    return @(result);
}

@end
