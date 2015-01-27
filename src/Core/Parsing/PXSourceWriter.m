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
//  PXSourceWriter.m
//  Pixate
//
//  Created by Kevin Lindsey on 6/26/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXSourceWriter.h"

@implementation PXSourceWriter
{
    NSString *currentIndent;
    NSString *indentString;
    NSMutableArray *strings;
}

#pragma mark - Initializers

- (id)init
{
    if (self = [super init])
    {
        self->currentIndent = @"";
        self->indentString = @"  ";
        self->strings = [NSMutableArray array];
    }

    return self;
}

#pragma mark - Methods

- (void)increaseIndent
{
    currentIndent = [currentIndent stringByAppendingString:indentString];
}

- (void)decreaseIndent
{
    if ([currentIndent length] >= [indentString length])
    {
        currentIndent = [currentIndent substringToIndex:[currentIndent length] - [indentString length]];
    }
    // else log error
}

- (void)printIndent
{
    if ([currentIndent length] > 0)
    {
        [strings addObject:currentIndent];
    }
}

- (void)printWithIndent:(NSString *)text
{
    [self printIndent];
    [self print:text];
}

- (void)print:(NSString *)text
{
    if (text)
    {
        [strings addObject:text];
    }
}

- (void)printNewLine
{
    [strings addObject:@"\n"];
}

- (void)printWithNewLine:(NSString *)text
{
    [self print:text];
    [self printNewLine];
}

#pragma mark - Overrides

- (NSString *)description
{
    return [strings componentsJoinedByString:@""];
}

@end
