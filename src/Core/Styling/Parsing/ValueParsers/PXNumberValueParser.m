//
//  PXNumberValueParser.m
//  PixateCore
//
//  Created by Kevin Lindsey on 12/10/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXNumberValueParser.h"
#import "PXStylesheetTokenType.h"
#import "PXDimension.h"

@implementation PXNumberValueParser

- (BOOL)canParse
{
    return [self isType:PXSS_NUMBER];
}

- (id)parse
{
    // TODO: make more robust by testing token types
    id value = self.currentLexeme.value;
    CGFloat result = 0.0;

    if ([value isKindOfClass:[NSNumber class]])
    {
        NSNumber *number = (NSNumber *)value;

        result = [number floatValue];
    }
    else if ([value isKindOfClass:[PXDimension class]])
    {
        PXDimension *dimension = (PXDimension *)value;
        PXDimension *points = dimension.points;

        result = points.number;
    }

    [self advance];
    
    return @(result);
}

@end
