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
//  PXCircle.m
//  Pixate
//
//  Created by Kevin Lindsey on 5/31/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXCircle.h"

@implementation PXCircle

@synthesize center = _center;
@synthesize radius = _radius;

#pragma mark - Static Initializers

+ (id)circleWithCenter:(CGPoint)aCenter withRadius:(CGFloat)aRadius
{
    return [[PXCircle alloc] initCenter:aCenter radius:aRadius];
}

#pragma mark - Initializers

- (id)init
{
    return [self initCenter:CGPointZero radius:0.0f];
}

- (id)initCenter:(CGPoint)aCenter radius:(CGFloat)aRadius
{
    if (self = [super init])
    {
        self.center = aCenter;
        self.radius = aRadius;
    }

    return self;
}

#pragma mark - Setters

- (void)setCenter:(CGPoint)aCenter
{
    if (!CGPointEqualToPoint(self->_center, aCenter))
    {
        self->_center = aCenter;
        [self clearPath];
    }
}

- (void)setRadius:(CGFloat)aRadius
{
    // Use positive values only
    if (aRadius < 0.0f)
    {
        aRadius = -aRadius;
    }

    if (self->_radius != aRadius)
    {
        self->_radius = aRadius;
        [self clearPath];
    }
}

#pragma mark - Overrides

- (CGPathRef)newPath
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat diameter = self.radius * 2.0f;
    CGRect rect = CGRectMake(self.center.x - self.radius, self.center.y - self.radius, diameter, diameter);

    CGPathAddEllipseInRect(path, NULL, rect);

    CGPathRef resultPath = CGPathCreateCopy(path);
    CGPathRelease(path);

    return resultPath;
}

@end
