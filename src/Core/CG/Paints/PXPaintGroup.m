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
//  PXPaintGroup.m
//  Pixate
//
//  Created by Kevin Lindsey on 7/2/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXPaintGroup.h"

@implementation PXPaintGroup
{
    NSMutableArray *paints_;
}

@synthesize blendMode;

#pragma mark - Initializers

- (id)initWithPaints:(NSArray *)paints
{
    if (self = [super init])
    {
        [paints enumerateObjectsUsingBlock:^(id<PXPaint> paint, NSUInteger idx, BOOL *stop) {
            [self addPaint:paint];
        }];
    }

    return self;
}

#pragma mark - Getters

- (NSArray *)paints
{
    return (paints_ != nil) ? [NSArray arrayWithArray:paints_] : nil;
}

#pragma mark - Methods

- (void)addPaint:(id<PXPaint>)paint
{
    if (paint)
    {
        if (paints_ == nil)
        {
            paints_ = [NSMutableArray array];
        }

        [paints_ addObject:paint];
    }
}

#pragma mark - PXPaint implementation

- (void)applyFillToPath:(CGPathRef)path withContext:(CGContextRef)context
{
    for (id<PXPaint> paint in paints_)
    {
        [paint applyFillToPath:path withContext:context];
    }
}

- (id<PXPaint>)lightenByPercent:(CGFloat)percent
{
    PXPaintGroup *group = [[PXPaintGroup alloc] init];

    [paints_ enumerateObjectsUsingBlock:^(id<PXPaint> paint, NSUInteger idx, BOOL *stop) {
        [group addPaint:[paint lightenByPercent:percent]];
    }];

    return group;
}

- (id<PXPaint>)darkenByPercent:(CGFloat)percent
{
    PXPaintGroup *group = [[PXPaintGroup alloc] init];

    [paints_ enumerateObjectsUsingBlock:^(id<PXPaint> paint, NSUInteger idx, BOOL *stop) {
        [group addPaint:[paint darkenByPercent:percent]];
    }];

    return group;
}

#pragma mark - Getters

- (BOOL)isOpaque
{
    BOOL result = YES;

    for (id<PXPaint> paint in paints_)
    {
        if (paint.isOpaque == NO)
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
    paints_ = nil;
}

- (BOOL)isEqual:(id)object
{
    BOOL result = NO;

    if ([object isKindOfClass:[PXPaintGroup class]])
    {
        PXPaintGroup *that = object;

        result = [paints_ isEqualToArray:that->paints_];
    }

    return result;
}

@end
