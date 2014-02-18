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
//  PXLexeme.m
//  Pixate
//
//  Created by Kevin Lindsey on 6/23/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXLexeme.h"
#import "PXStylesheetTokenType.h"

@implementation PXLexeme
{
    NSUInteger flags_;
}

#pragma mark - Static Initializers

+ (id)lexemeWithType:(int)type
{
    return [[PXLexeme alloc] initWithType:type withRange:NSMakeRange(NSNotFound, 0) withValue:nil];
}

+ (id)lexemeWithType:(int)type withRange:(NSRange)range
{
    return [[PXLexeme alloc] initWithType:type withRange:range withValue:nil];
}

+ (id)lexemeWithType:(int)type withValue:(id)value
{
    return [[PXLexeme alloc] initWithType:type withRange:NSMakeRange(NSNotFound, 0) withValue:value];
}

+ (id)lexemeWithType:(int)type withRange:(NSRange)range withValue:(id)value
{
    return [[PXLexeme alloc] initWithType:type withRange:range withValue:value];
}

#pragma mark - Initializers

- (id)initWithType:(int)aType withRange:(NSRange)aRange withValue:(id)aValue
{
    if (self = [super init])
    {
        _type = aType;
        _range = aRange;
        _value = aValue;
        flags_ = 0;
    }

    return self;
}

#pragma mark - Getters

- (NSString *)typeName
{
    //return [PXSSTokenType typeNameForInt:type];
    return [PXStylesheetTokenType typeNameForInt:_type];
}

#pragma mark - Methods

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@@%lu-%lu:«%@»", self.typeName, (unsigned long) _range.location, (unsigned long) _range.location + _range.length, _value];
}

#pragma mark - Flags

- (void)clearFlag:(PXLexemeFlagType)type
{
    flags_ &= ~type;
}

- (void)setFlag:(PXLexemeFlagType)type
{
    flags_ |= type;
}

- (BOOL)flagIsSet:(PXLexemeFlagType)type
{
    return ((flags_ & type) == type);
}

- (BOOL)followsWhitespace
{
    return [self flagIsSet:PXLexemeFlagFollowsWhitespace];
}

@end
