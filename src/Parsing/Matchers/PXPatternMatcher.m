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
//  PXPatternMatcher.m
//  Pixate
//
//  Created by Kevin Lindsey on 6/23/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXPatternMatcher.h"
#import "PXStylesheetLexeme.h"

@implementation PXPatternMatcher

static NSRange NO_MATCH;

@synthesize type;
@synthesize name;

+ (void)initialize
{
    NO_MATCH = NSMakeRange(NSNotFound, 0);
}

#pragma mark - Initializers

- (id)initWithType:(int)aType withPatternString:(NSString *)patternString
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:patternString
                                                                           options:0
                                                                             error:&error];

    return [self initWithType:aType withRegularExpression:regex];
}

- (id)initWithType:(int)aType withRegularExpression:(NSRegularExpression *)aPattern
{
    if (self = [super init])
    {
        self->type = aType;
        self->pattern = aPattern;
    }

    return self;
}

#pragma mark - Methods

- (PXStylesheetLexeme *)createLexemeWithString:(NSString *)aString withRange:(NSRange)aRange
{
    PXStylesheetLexeme *result = nil;

    NSRange range = [pattern rangeOfFirstMatchInString:aString options:0 range:aRange];

    if (!NSEqualRanges(range, NO_MATCH))
    {
        NSString *text = [aString substringWithRange:range];
        id value = [self getValueFromString:text];

        result = [PXStylesheetLexeme lexemeWithType:self.type withRange:range withValue:value];
    }

    return result;
}

- (id)getValueFromString:(NSString *)aString
{
    // default behavior returns the string itself. Sub-classes should convert to the correct type
    return aString;
}

@end
