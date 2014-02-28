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
//  PXSpecificity.m
//  Pixate
//
//  Created by Kevin Lindsey on 7/10/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXSpecificity.h"

@implementation PXSpecificity
{
    int *values;
    int length;
}

#pragma mark - Initializers

- (id)init
{
    if (self = [super init])
    {
        // NOTE: Fragile as this is based on order of specificity enum
        self->length = kSpecificityTypeElement + 1;

        values = malloc(self->length * sizeof(int));

        if (values)
        {
            for (int i = 0; i < self->length; i++)
            {
                values[i] = 0;
            }
        }
    }

    return self;
}

#pragma mark - Methods

- (NSComparisonResult)compareSpecificity:(PXSpecificity *)specificity
{
    // TODO: check for nils and compare lengths
    int *theseValues = self->values;
    int *thoseValues = specificity->values;

    for (int i = 0; i < self->length; i++)
    {
        if (theseValues[i] < thoseValues[i])
        {
            return NSOrderedAscending;
        }
        else if (theseValues[i] > thoseValues[i])
        {
            return NSOrderedDescending;
        }
    }

    return NSOrderedSame;
}

- (void)incrementSpecifity:(PXSpecificityType)specificity
{
    if (values && specificity < self->length)
    {
        values[specificity]++;
    }
}

- (void)setSpecificity:(PXSpecificityType)specificity toValue:(int)value
{
    if (values && specificity < self->length)
    {
        values[specificity] = value;
    }
}

#pragma mark - Overrides

- (void)dealloc
{
    if (values)
    {
        free(values);
    }
}

- (NSString *)description
{
    NSMutableArray *parts = [NSMutableArray arrayWithCapacity:self->length];

    for (int i = 0; i < self->length; i++)
    {
        [parts addObject:[NSString stringWithFormat:@"%d", values[i]]];
    }

    return [NSString stringWithFormat:@"(%@)", [parts componentsJoinedByString:@","]];
}

@end
