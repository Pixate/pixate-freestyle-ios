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
//  PXLine.m
//  Pixate
//
//  Created by Kevin Lindsey on 6/6/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXLine.h"

@implementation PXLine

@synthesize p1 = _p1;
@synthesize p2 = _p2;

#pragma mark - Initializers

- (id)init
{
    return [self initX1:0.0f y1:0.0f x2:0.0f y2:0.0f];
}

- (id)initX1:(CGFloat)aX1 y1:(CGFloat)aY1 x2:(CGFloat)aX2 y2:(CGFloat)aY2
{
    if (self = [super init])
    {
        self.p1 = CGPointMake(aX1, aY1);
        self.p2 = CGPointMake(aX2, aY2);
    }

    return self;
}

#pragma mark - Setters

- (void)setP1:(CGPoint)point
{
    if (!CGPointEqualToPoint(self->_p1, point))
    {
        self->_p1 = point;
        [self clearPath];
    }
}

- (void)setP2:(CGPoint)point
{
    if (!CGPointEqualToPoint(self->_p2, point))
    {
        self->_p2 = point;
        [self clearPath];
    }
}

#pragma mark - Overrides

- (CGPathRef)newPath
{
    CGMutablePathRef path = CGPathCreateMutable();

    CGPathMoveToPoint(path, NULL, self.p1.x, self.p1.y);
    CGPathAddLineToPoint(path, NULL, self.p2.x, self.p2.y);

    CGPathRef resultPath = CGPathCreateCopy(path);
    CGPathRelease(path);

    return resultPath;
}

@end
