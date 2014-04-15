//
//  PXAnimationPlayStateValueParser.m
//  PixateAnimationModule
//
//  Created by Kevin Lindsey on 12/10/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXAnimationPlayStateValueParser.h"
#import "PXAnimationInfo.h"
#import "PXStylesheetTokenType.h"

@implementation PXAnimationPlayStateValueParser

+ (void)initialize
{
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        ANIMATION_PLAY_STATE_MAP = @{
            @"running": @(PXAnimationPlayStateRunning),
            @"paused": @(PXAnimationPlayStatePaused),
        };
    });
}

- (BOOL)canParse
{
    return [self isType:PXSS_IDENTIFIER] && ([ANIMATION_PLAY_STATE_MAP objectForKey:self.currentLexeme.value] != nil);
}

- (id)parse
{
    PXAnimationPlayState result = PXAnimationPlayStateUndefined;

    if ([self canParse])
    {
        NSString *text = self.currentLexeme.value;
        NSNumber *value = [ANIMATION_PLAY_STATE_MAP objectForKey:[text lowercaseString]];

        if (value)
        {
            result = (PXAnimationPlayState) [value intValue];
        }
    }
    else
    {
        [self errorWithMessage:@"Expected identifier for animation play state"];
    }

    [self advance];

    return @(result);
}

@end
