/*
 * Copyright 2012-present Pixate, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  PXNumberMatcher.m
//  Pixate
//
//  Created by Kevin Lindsey on 6/23/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXNumberMatcher.h"
#import "PXDimension.h"

@implementation PXNumberMatcher
{
    NSDictionary *dimensionMap;
    int unknownDimensionType;
}

static NSRange NO_MATCH;

+ (void)initialize
{
    NO_MATCH = NSMakeRange(NSNotFound, 0);
}

#pragma mark - Initializers

- (id)initWithType:(int)type
{
    if (self = [super initWithType:type withPatternString:@"^([-+]?(?:[0-9]*\\.[0-9]+|[0-9]+))"])
    {
        // do any local init
    }

    return self;
}

- (id)initWithType:(int)type withDictionary:(NSDictionary *)dictionary withUnknownType:(int)unknownType
{
    if (dictionary)
    {
        NSArray *keys = [dictionary allKeys];
        NSMutableArray *keyPatterns = [NSMutableArray arrayWithCapacity:keys.count];

        for (NSString *key in keys)
        {
            char c = [key characterAtIndex:key.length - 1];


            if ([[NSCharacterSet letterCharacterSet] characterIsMember:c])
            {
                // make sure strings end on a non-word boundary
                [keyPatterns addObject:[key stringByAppendingString:@"\\b"]];
            }
            else
            {
                [keyPatterns addObject:key];
            }
        }

        NSString *patternString = [NSString stringWithFormat:@"^([-+]?(?:[0-9]*\\.[0-9]+|[0-9]+))(%@)?", [keyPatterns componentsJoinedByString:@"|"]];

        if (self = [self initWithType:type withPatternString:patternString])
        {
            self->dimensionMap = [NSDictionary dictionaryWithDictionary:dictionary];
            self->unknownDimensionType = unknownType;
        }
    }
    else
    {
        self = [self initWithType:type];
    }

    return self;
}

#pragma mark - PXSLexemeCreator implementation

- (PXLexeme *)createLexemeWithString:(NSString *)aString withRange:(NSRange)aRange
{
    PXLexeme *result = nil;
    NSArray *matches = [self->pattern matchesInString:aString options:0 range:aRange];

    if (matches.count == 1)
    {
        NSTextCheckingResult *matchResult = [matches objectAtIndex:0];
        NSRange numberRange = [matchResult rangeAtIndex:1];

        NSString *number = [aString substringWithRange:numberRange];
        float floatValue = [number floatValue];

        NSRange dimensionRange = (matchResult.numberOfRanges > 2) ? [matchResult rangeAtIndex:2] : NO_MATCH;

        if (!NSEqualRanges(dimensionRange, NO_MATCH))
        {
            NSString *dimension = [aString substringWithRange:dimensionRange];
            NSNumber *dimensionType = [dimensionMap objectForKey:dimension];
            int type;

            if (dimensionType)
            {
                type = [dimensionType intValue];
            }
            else
            {
                type = self->unknownDimensionType;
            }

            PXDimension *dimensionValue = [PXDimension dimensionWithNumber:floatValue withDimension:dimension];

            result = [PXLexeme lexemeWithType:type withRange:matchResult.range withValue:dimensionValue];

        }
        else
        {
            result = [PXLexeme lexemeWithType:self.type withRange:numberRange withValue:[NSNumber numberWithFloat:floatValue]];
        }
    }

    return result;
}

@end
