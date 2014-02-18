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
//  PXArc.m
//  Pixate
//
//  Created by Kevin Lindsey on 9/4/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXArc.h"
#import "PXMath.h"

@implementation PXArc

@synthesize center = _center;
@synthesize radius = _radius;
@synthesize startingAngle = _startingAngle;
@synthesize endingAngle = _endingAngle;

#pragma mark - Initializers

- (id)init
{
    if (self = [super init])
    {
        self->_center = CGPointZero;
        self->_radius = 0.0f;
        self->_startingAngle = 0.0f;
        self->_endingAngle = 360.0f;
    }

    return self;
}

#pragma mark - Setters

- (void)setCenter:(CGPoint)center
{
    if (!CGPointEqualToPoint(self->_center, center))
    {
        self->_center = center;
        [self clearPath];
    }
}

- (void)setRadius:(CGFloat)radius
{
    // Use positive values only
    if (radius < 0.0f)
    {
        radius = -radius;
    }

    if (self->_radius != radius)
    {
        self->_radius = radius;
        [self clearPath];
    }
}

- (void)setStartingAngle:(CGFloat)startingAngle
{
    if (self->_startingAngle != startingAngle)
    {
        self->_startingAngle = startingAngle;
        [self clearPath];
    }
}

- (void)setEndingAngle:(CGFloat)endingAngle
{
    if (self->_endingAngle != endingAngle)
    {
        self->_endingAngle = endingAngle;
        [self clearPath];
    }
}

#pragma mark - Overrides

- (CGPathRef)newPath
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat startingRadians = DEGREES_TO_RADIANS(self.startingAngle);
    CGFloat endingRadians = DEGREES_TO_RADIANS(self.endingAngle);

    CGPathAddArc(path, NULL, self.center.x, self.center.y, self.radius, startingRadians, endingRadians, NO);

    CGPathRef resultPath = CGPathCreateCopy(path);
    CGPathRelease(path);

    return resultPath;
}

@end
