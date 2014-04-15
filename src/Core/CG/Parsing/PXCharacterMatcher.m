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
//  PXCharacterToken.m
//  Pixate
//
//  Created by Kevin Lindsey on 6/23/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXCharacterMatcher.h"

@implementation PXCharacterMatcher
{
    NSDictionary *typeMap;
}

#pragma mark - Initializers

- (id)initWithCharactersInString:(NSString *)characters withTypes :(NSArray *)types
{
    if (self = [super init])
    {
        NSUInteger size = MIN([characters length], [types count]);
        NSMutableDictionary *map = [NSMutableDictionary dictionaryWithCapacity:size];

        for (int i = 0; i < size; i++)
        {
            NSString *character = [characters substringWithRange:NSMakeRange(i, 1)];

            [map setObject:[types objectAtIndex:i] forKey:character];
        }

        self->typeMap = [NSMutableDictionary dictionaryWithDictionary:map];
    }

    return self;
}

#pragma mark - PXSLexemeCreator implementation

- (PXStylesheetLexeme *)createLexemeWithString:(NSString *)aString withRange:(NSRange)aRange
{
    NSRange characterRange = NSMakeRange(aRange.location, 1);
    NSString *character = [aString substringWithRange:characterRange];
    NSNumber *type = [typeMap objectForKey:character];
    PXStylesheetLexeme *result = nil;

    if (type)
    {
        NSString *text = [aString substringWithRange:characterRange];

        result = [PXStylesheetLexeme lexemeWithType:[type intValue] withRange:characterRange withValue:text];
    }

    return result;
}

@end
