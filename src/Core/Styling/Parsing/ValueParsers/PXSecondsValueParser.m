//
//  PXSecondsValueParser.m
//  PixateCore
//
//  Created by Kevin Lindsey on 12/10/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXSecondsValueParser.h"
#import "PXStylesheetTokenType.h"
#import "PXDimension.h"

@implementation PXSecondsValueParser

- (BOOL)canParse
{
    return [self isType:PXSS_TIME];
}

- (id)parse
{
    CGFloat result = 0.0;

    if ([self isType:PXSS_TIME])
    {
        id value = self.currentLexeme.value;

        if ([value isKindOfClass:[PXDimension class]])
        {
            PXDimension *dimension = value;

            switch (dimension.type)
            {
                case kDimensionTypeMilliseconds:
                    result = dimension.number / 1000.0f;
                    [self advance];
                    break;

                case kDimensionTypeSeconds:
                    result = dimension.number;
                    [self advance];
                    break;

                default:
                {
                    NSString *message = [NSString stringWithFormat:@"Unrecognized time unit: %@", dimension];

                    [self errorWithMessage:message];
                    break;
                }
            }
        }
        else
        {
            [self errorWithMessage:@"TIME lexeme did not have PXDimension value"];
        }
    }
    // else return failure
    
    return @(result);
}

@end
