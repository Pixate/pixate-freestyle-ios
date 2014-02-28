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
//  PXStyleCache.m
//  Pixate
//
//  Created by Kevin Lindsey on 10/2/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXStyleTreeInfo.h"
#import "PXStyleInfo.h"
#import "PXStyleUtils.h"

@implementation PXStyleTreeInfo
{
    NSString *styleKey_;
    PXStyleInfo *styleableStyleInfo_;
    NSMutableDictionary *childStyleInfo_;           // keyed by NSIndexPath
//    NSMutableDictionary *pseudoElementStyleInfo_;   // keyed by NSIndexPath
    NSUInteger descendantCount_;
}

#pragma mark - Initializers

- (id)initWithStyleable:(id<PXStyleable>)styleable
{
    if (self = [super init])
    {
        styleKey_ = styleable.styleKey;
        styleableStyleInfo_ = [PXStyleInfo styleInfoForStyleable:styleable];
        styleableStyleInfo_.forceInvalidation = YES;
        childStyleInfo_ = [NSMutableDictionary dictionary];

        [self collectChildStyleInfoForStyleable:styleable];
    }

    return self;
}

#pragma mark - Getters

- (NSString *)styleKey
{
    return styleKey_;
}

#pragma mark - Methods

- (void)applyStylesToStyleable:(id<PXStyleable>)styleable
{
    if (styleableStyleInfo_ != nil)
    {
        [styleableStyleInfo_ applyToStyleable:styleable];
    }

    for (NSIndexPath *indexPath in childStyleInfo_.keyEnumerator)
    {
        id<PXStyleable> child = [self findDescendantOfStyleable:styleable fromIndexPath:indexPath];

        if (child != nil)
        {
            PXStyleInfo *styleInfo = [childStyleInfo_ objectForKey:indexPath];

            [styleInfo applyToStyleable:child];
        }
    }
}

- (id<PXStyleable>)findDescendantOfStyleable:(id<PXStyleable>)styleable fromIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger indexes[indexPath.length];
    [indexPath getIndexes:indexes];
    id<PXStyleable> result = styleable;

    for (int i = 0; i < indexPath.length; i++)
    {
        NSUInteger index = indexes[i];
        NSArray *children = result.pxStyleChildren;

        if (index < children.count)
        {
            result = children[index];
        }
        else
        {
            result = nil;
            break;
        }
    }

    return result;
}

- (void)collectChildStyleInfoForStyleable:(id<PXStyleable>)styleable
{
    NSUInteger index = 0;

    descendantCount_ = 0;

    for (id<PXStyleable> child in styleable.pxStyleChildren)
    {
        NSIndexPath *childIndexPath = [NSIndexPath indexPathWithIndex:index++];

        [self setChildStyleInfoForStyleable:child withIndexPath:childIndexPath];
        descendantCount_++;
    }
}

- (void)setChildStyleInfoForStyleable:(id<PXStyleable>)styleable withIndexPath:(NSIndexPath *)indexPath
{
    // get style info for this child
    PXStyleInfo *styleInfo = [PXStyleInfo styleInfoForStyleable:styleable];


    if (styleInfo != nil)
    {
        // force invalidation of children
        styleInfo.forceInvalidation = YES;

        // save info for this index path
        [childStyleInfo_ setObject:styleInfo forKey:indexPath];
    }

    // now process this child's children
    NSUInteger index = 0;

    for (id<PXStyleable> child in styleable.pxStyleChildren)
    {
        NSIndexPath *childIndexPath = [indexPath indexPathByAddingIndex:index++];

        [self setChildStyleInfoForStyleable:child withIndexPath:childIndexPath];
        descendantCount_++;
    }
}

#pragma mark - Overrides

- (void)dealloc
{
    styleableStyleInfo_ = nil;
    childStyleInfo_ = nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"{ Key=%@, StyledDescendants=%ld, TotalDescendants=%ld }", self.styleKey, (unsigned long) childStyleInfo_.count, (unsigned long) descendantCount_];
}

@end
