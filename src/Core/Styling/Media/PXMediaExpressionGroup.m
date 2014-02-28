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
//  PXMediaExpressionGroup.m
//  Pixate
//
//  Created by Kevin Lindsey on 1/10/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXMediaExpressionGroup.h"

@implementation PXMediaExpressionGroup
{
    NSMutableArray *_expressions;
}

#pragma mark - Methods

- (void)addExpression:(id<PXMediaExpression>)expression
{
    if (expression)
    {
        if (!_expressions)
        {
            _expressions = [NSMutableArray array];
        }

        [_expressions addObject:expression];
    }
}

- (NSArray *)expressions
{
    return (_expressions) ? [NSArray arrayWithArray:_expressions] : nil;
}

- (void)clearCache
{
    for (id<PXMediaExpression> expression in _expressions)
        [expression clearCache];
}

- (BOOL)matches
{
    BOOL result = YES;

    for (id<PXMediaExpression> expression in _expressions)
    {
        if (![expression matches])
        {
            result = NO;
            break;
        }
    }

    return result;
}

#pragma mark - Overrides

- (void)dealloc
{
    _expressions = nil;
}

- (NSString *)description
{
    NSMutableArray *parts = [NSMutableArray array];

    for (id<PXMediaExpression> expression in _expressions)
    {
        [parts addObject:expression.description];
    }

    return [parts componentsJoinedByString:@" and "];
}

@end
