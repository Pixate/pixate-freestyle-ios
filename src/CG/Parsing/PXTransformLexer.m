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
//  PXTransformLexer.m
//  Pixate
//
//  Created by Kevin Lindsey on 7/27/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXTransformLexer.h"
#import "PXTransformTokenType.h"
#import "PXPatternMatcher.h"
#import "PXNumberMatcher.h"
#import "PXWordMatcher.h"
#import "PXCharacterMatcher.h"

@implementation PXTransformLexer
{
    NSArray *tokens;
    NSUInteger offset;
}

@synthesize source;

#pragma mark - Initializers

- (id)init
{
    if (self = [super init])
    {
        // create tokens
        NSMutableArray *tokenList = [NSMutableArray array];

        // whitespace
        [tokenList addObject: [[PXPatternMatcher alloc] initWithType:PXTransformToken_WHITESPACE
                                                     withPatternString:@"^[ \\t\\r\\n]+"]];

        // dimensions
        NSDictionary *unitMap = @{
                                  @"em": @(PXTransformToken_EMS),
                                  @"ex": @(PXTransformToken_EXS),
                                  @"px": @(PXTransformToken_LENGTH),
                                  @"dpx": @(PXTransformToken_LENGTH),
                                  @"cm": @(PXTransformToken_LENGTH),
                                  @"mm": @(PXTransformToken_LENGTH),
                                  @"in": @(PXTransformToken_LENGTH),
                                  @"pt": @(PXTransformToken_LENGTH),
                                  @"pc": @(PXTransformToken_LENGTH),
                                  @"deg": @(PXTransformToken_ANGLE),
                                  @"rad": @(PXTransformToken_ANGLE),
                                  @"grad": @(PXTransformToken_ANGLE),
                                  @"ms": @(PXTransformToken_TIME),
                                  @"s": @(PXTransformToken_TIME),
                                  @"Hz": @(PXTransformToken_FREQUENCY),
                                  @"kHz": @(PXTransformToken_FREQUENCY),
                                  @"%": @(PXTransformToken_PERCENTAGE),
                                  @"[-a-zA-Z_][-a-zA-Z0-9_]*": @(PXTransformToken_DIMENSION)
                                  };
        [tokenList addObject:[[PXNumberMatcher alloc] initWithType:PXTransformToken_NUMBER withDictionary:unitMap withUnknownType:PXTransformToken_DIMENSION]];

        // keywords
        NSDictionary *keywordMap = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:PXTransformToken_TRANSLATE], @"translate",
                                    [NSNumber numberWithInt:PXTransformToken_TRANSLATEX], @"translateX",
                                    [NSNumber numberWithInt:PXTransformToken_TRANSLATEY], @"translateY",
                                    [NSNumber numberWithInt:PXTransformToken_SCALE], @"scale",
                                    [NSNumber numberWithInt:PXTransformToken_SCALEX], @"scaleX",
                                    [NSNumber numberWithInt:PXTransformToken_SCALEY], @"scaleY",
                                    [NSNumber numberWithInt:PXTransformToken_SKEW], @"skew",
                                    [NSNumber numberWithInt:PXTransformToken_SKEWX], @"skewX",
                                    [NSNumber numberWithInt:PXTransformToken_SKEWY], @"skewY",
                                    [NSNumber numberWithInt:PXTransformToken_ROTATE], @"rotate",
                                    [NSNumber numberWithInt:PXTransformToken_MATRIX], @"matrix",
                                    nil];
        [tokenList addObject:[[PXWordMatcher alloc] initWithDictionary:keywordMap]];

        // single-character operators
        NSString *operators = @"(),";
        NSArray *operatorTypes = [NSArray arrayWithObjects:
                                  [NSNumber numberWithInt:PXTransformToken_LPAREN],
                                  [NSNumber numberWithInt:PXTransformToken_RPAREN],
                                  [NSNumber numberWithInt:PXTransformToken_COMMA],
                                  nil];
        [tokenList addObject:[[PXCharacterMatcher alloc] initWithCharactersInString:operators withTypes:operatorTypes]];

        self->tokens = [NSArray arrayWithArray:tokenList];

    }

    return self;
}

- (id)initWithString:(NSString *)text
{
    if (self = [self init])
    {
        self.source = text;
    }

    return self;
}

#pragma mark - Setter

- (void)setSource:(NSString *)aSource
{
    self->source = aSource;
    self->offset = 0;
}

#pragma mark - Methods

- (PXStylesheetLexeme *)nextLexeme
{
    PXStylesheetLexeme *result = nil;

    if (source)
    {
        NSUInteger length = [source length];

        while (offset < length)
        {
            NSRange range = NSMakeRange(offset, length - offset);
            PXStylesheetLexeme *candidate = nil;

            for (id<PXLexemeCreator> creator in tokens)
            {
                PXStylesheetLexeme *lexeme = [creator createLexemeWithString:source withRange:range];

                if (lexeme)
                {
                    NSRange lexemeRange = lexeme.range;

                    offset = lexemeRange.location + lexemeRange.length;
                    candidate = lexeme;
                    break;
                }
            }

            // skip whitespace
            if (!candidate || candidate.type != PXTransformToken_WHITESPACE)
            {
                result = candidate;
                break;
            }
        }
    }

    return result;
}

@end
