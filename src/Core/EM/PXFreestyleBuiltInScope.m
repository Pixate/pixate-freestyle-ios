//
//  PXFreestyleBuiltInScope.m
//  pixate-freestyle
//
//  Created by Kevin Lindsey on 4/17/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "PXFreestyleBuiltInScope.h"
#import "PXFreestyleBuiltinSource.h"

@implementation PXFreestyleBuiltInScope

static id<PXExpressionScope> EMA_SCOPE;
static id<PXExpressionScope> EM_SCOPE;

#pragma mark - Static Methods

+ (void)initialize
{
    if (EMA_SCOPE == nil)
    {
        EMA_SCOPE = [self scopeFromEmaString:[PXFreestyleBuiltInSource emaSource]];
    }
    if (EM_SCOPE == nil)
    {
        EM_SCOPE = [self scopeFromEmString:[PXFreestyleBuiltInSource emSource]];
    }
}

#pragma mark - Initializers

- (id)init
{
    if (self = [super init])
    {
        // copy em- and ema-defined built-ins
        [self copySymbolsFromScope:EMA_SCOPE];
        [self copySymbolsFromScope:EM_SCOPE];
    }

    return self;
}

@end
