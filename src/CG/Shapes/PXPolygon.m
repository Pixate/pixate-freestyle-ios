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
//  PXPolygon.m
//  Pixate
//
//  Created by Kevin Lindsey on 6/9/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXPolygon.h"

@implementation PXPolygon

@synthesize closed = _closed;
@synthesize points = _points;

#pragma mark - Initializers

- (id)init
{
    return [self initWithPoints:nil];
}

- (id)initWithPoints:(NSArray *)pointArray
{
    self = [super init];

    if (self)
    {
        self.points = pointArray;
    }

    return self;
}

#pragma mark - Setters

- (void)setClosed:(BOOL)flag
{
    if (self->_closed != flag)
    {
        self->_closed = flag;
        [self clearPath];
    }
}

- (void)setPoints:(NSArray *)newPoints
{
    if (self->_points != newPoints)
    {
        self->_points = newPoints;
        [self clearPath];
    }
}

#pragma mark - Overrides

- (CGPathRef)newPath
{
    CGPathRef resultPath = nil;

    if ([self.points count] > 1)
    {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPoint p = [[self.points objectAtIndex:0] CGPointValue];

        CGPathMoveToPoint(path, NULL, p.x, p.y);

        for (int i = 1; i < [self.points count]; i++)
        {
            p = [[self.points objectAtIndex:i] CGPointValue];

            CGPathAddLineToPoint(path, NULL, p.x, p.y);
        }

        if (self.closed)
        {
            CGPathCloseSubpath(path);
        }

        resultPath = CGPathCreateCopy(path);
        CGPathRelease(path);
    }

    return resultPath;
}

- (void)dealloc
{
    self->_points = nil;
}

@end
