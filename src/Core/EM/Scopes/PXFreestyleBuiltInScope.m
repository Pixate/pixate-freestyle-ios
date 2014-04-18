//
//  PXFreestyleBuiltInScope.m
//  pixate-freestyle
//
//  Created by Kevin Lindsey on 4/17/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "PXFreestyleBuiltInScope.h"
#import "PXFreestyleBuiltinSource.h"
#import "PXHSBFunction.h"
#import "PXHSBAFunction.h"
#import "PXHSLFunction.h"
#import "PXHSLAFunction.h"
#import "PXRGBFunction.h"
#import "PXRGBAFunction.h"

@implementation PXFreestyleBuiltInScope

static id<PXExpressionScope> EMA_SCOPE;
static id<PXExpressionScope> EM_SCOPE;

#pragma mark - Initializers

- (id)init
{
    if (self = [super init])
    {
        // color functions
        [self setValue:[[PXHSBFunction alloc] init] forSymbolName:@"hsb"];
        [self setValue:[[PXHSBAFunction alloc] init] forSymbolName:@"hsba"];
        [self setValue:[[PXHSLFunction alloc] init] forSymbolName:@"hsl"];
        [self setValue:[[PXHSLAFunction alloc] init] forSymbolName:@"hsla"];
        [self setValue:[[PXRGBFunction alloc] init] forSymbolName:@"rgb"];
        [self setValue:[[PXRGBAFunction alloc] init] forSymbolName:@"rgba"];

        if (EMA_SCOPE == nil)
        {
            EMA_SCOPE = [self scopeFromEmaString:[PXFreestyleBuiltInSource emaSource]];
        }
        if (EM_SCOPE == nil)
        {
            EM_SCOPE = [self scopeFromEmString:[PXFreestyleBuiltInSource emSource]];
        }

        // copy em- and ema-defined built-ins
        [self copySymbolsFromScope:EMA_SCOPE];
        [self copySymbolsFromScope:EM_SCOPE];
    }

    return self;
}

@end
