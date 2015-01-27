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
//  PXParserBase.m
//  Pixate
//
//  Created by Kevin Lindsey on 6/30/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXParserBase.h"
//#import "PixateFreestyle.h"

@implementation PXParserBase
{
    NSMutableArray *errors;
}

@synthesize errors;

#pragma mark - Methods
- (void)internalAddError:(NSString *)error
{
    if (error && error.length > 0)
    {
        if (!errors)
        {
            errors = [NSMutableArray array];
        }

        [errors addObject:error];
    }
}

- (void)addError:(NSString *)error
{
    [self internalAddError:error];
}

- (void)addError:(NSString *)error filename:(NSString *)filename offset:(NSString *)offset
{
    NSString *ammendedError;

    if (filename.length > 0)
    {
        ammendedError = [NSString stringWithFormat:@"[Pixate.ParseError, file='%@', offset=%@]: %@", filename, offset, error];
    }
    else
    {
        ammendedError = [NSString stringWithFormat:@"[Pixate.ParseError, offset=%@]: %@", offset, error];
    }

    [self internalAddError:ammendedError];

//    [PixateFreestyle.configuration sendParseMessage:ammendedError];
}

- (void)clearErrors
{
    errors = nil;
}

- (id<PXLexeme>)advance
{
    // TODO: generalize so descendants don't have to override this method
    return currentLexeme = nil;
}

- (NSString *)lexemeNameFromType:(int)type
{
    // NOTE: sub-classes should override this
    return [NSString stringWithFormat:@"%d", type];
}

- (void)errorWithMessage:(NSString *)message
{
    [NSException raise:@"Unexpected token type"
                format:@"%@. Found %@ token", message, currentLexeme.name];
}

- (void)assertType:(int)type
{
    if (currentLexeme.type != type)
    {
        [self errorWithMessage:[NSString stringWithFormat:@"Expected a %@ token", [self lexemeNameFromType:type]]];
    }
}

- (void)assertTypeInSet:(NSIndexSet *)set
{
    if (![self isInTypeSet:set])
    {
        NSMutableArray *tokens = [[NSMutableArray alloc] init];

        [set enumerateIndexesUsingBlock:^(NSUInteger type, BOOL *stop) {
            [tokens addObject:[self lexemeNameFromType:(int)type]];
        }];

        NSString *message = [tokens componentsJoinedByString:@", "];

        [self errorWithMessage:[NSString stringWithFormat:@"Expected a token of one of these types: %@", message]];
    }
}

- (id<PXLexeme>)assertTypeAndAdvance:(int)type
{
    [self assertType:type];

    return [self advance];
}

- (void)advanceIfIsType:(int)type
{
    if (currentLexeme.type == type)
    {
        [self advance];
    }
}

- (void)advanceIfIsType:(int)type withWarning:(NSString *)warning
{
    if (currentLexeme.type == type)
    {
        [self advance];
    }
    else
    {
        [self errorWithMessage:warning];
    }
}

- (BOOL)isType:(int)type
{
    return currentLexeme.type == type;
}

- (BOOL)isInTypeSet:(NSIndexSet *)types
{
    return ([types containsIndex:currentLexeme.type]);
}

@end
