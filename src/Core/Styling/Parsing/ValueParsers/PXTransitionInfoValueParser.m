//
//  PXTransitionInfoValueParser.m
//  PixateAnimationModule
//
//  Created by Kevin Lindsey on 12/11/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXTransitionInfoValueParser.h"
#import "PXValueParserManager.h"
#import "PXAnimationInfo.h"
#import "PXStylesheetTokenType.h"
#import "PXAnimationTimingFunctionValueParser.h"

@implementation PXTransitionInfoValueParser


- (id)parse
{
    // grab dependent parsers
    PXValueParserManager *manager = [PXValueParserManager sharedInstance];
    id<PXValueParserProtocol> secondsParser = [manager parserForName:kPXValueParserSeconds withLexer:self.lexer];
    id<PXValueParserProtocol> timingFunctionParser = [manager parserForName:kPXValueParserAnimationTimingFunction withLexer:self.lexer];

    // create empty result value
    PXAnimationInfo *info = [[PXAnimationInfo alloc] init];

    if ([self isType:PXSS_IDENTIFIER] && ([ANIMATION_TIMING_FUNCTION_MAP objectForKey:self.currentLexeme.value] == nil))
    {
        info.animationName = self.currentLexeme.value;
        [self advance];
    }

    // duration
    if ([secondsParser canParse])
    {
        info.animationDuration = [[secondsParser parse] floatValue];
    }

    // timing function
    if ([timingFunctionParser canParse])
    {
        info.animationTimingFunction = [[timingFunctionParser parse] integerValue];
    }

    // delay
    if ([secondsParser canParse])
    {
        info.animationDelay = [[secondsParser parse] floatValue];
    }

    return info;
}

@end
