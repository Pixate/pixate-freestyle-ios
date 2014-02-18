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
//  PXEllipse.m
//  Pixate
//
//  Created by Kevin Lindsey on 6/6/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXEllipse.h"

@implementation PXEllipse

#pragma mark - Static Initializers

+ (id)ellipseWithCenter:(CGPoint)aCenter withRadiusX:(CGFloat)aRadiusX withRadiusY:(CGFloat)aRadiusY
{
    return [[PXEllipse alloc] initCenter:aCenter radiusX:aRadiusX radiusY:aRadiusY];
}

#pragma mark - Initializers

- (id)init
{
    return [self initCenter:CGPointZero radiusX:0.0f radiusY:0.0f];
}

- (id)initCenter:(CGPoint)aCenter radiusX:(CGFloat)aRadiusX radiusY:(CGFloat)aRadiusY
{
    if (self = [super init])
    {
        self.center = aCenter;
        self.radiusX = aRadiusX;
        self.radiusY = aRadiusY;
    }

    return self;
}

#pragma mark - Getters

- (CGRect)bounds
{
    return CGRectMake(_center.x - _radiusX, _center.y - _radiusY, _center.x + _radiusX, _center.y + _radiusY);
}

#pragma mark - Setters

- (void)setBounds:(CGRect)bounds
{
    // TODO: check against current value to avoid unnecessary clearing of the path cache?
    _radiusX = bounds.size.width * 0.5f;
    _radiusY = bounds.size.height * 0.5f;
    _center.x = bounds.origin.x + _radiusX;
    _center.y = bounds.origin.y + _radiusY;
    [self clearPath];
}

- (void)setCenter:(CGPoint)aCenter
{
    if (!CGPointEqualToPoint(self->_center, aCenter))
    {
        self->_center = aCenter;
        [self clearPath];
    }
}

- (void)setRadiusX:(CGFloat)radius
{
    // Use positive absolute values only
    if (radius < 0)
    {
        radius = -radius;
    }

    if (self->_radiusX != radius)
    {
        self->_radiusX = radius;
        [self clearPath];
    }
}

- (void)setRadiusY:(CGFloat)radius
{
    // Use positive absolute values only
    if (radius < 0)
    {
        radius = -radius;
    }

    if (self->_radiusY != radius)
    {
        self->_radiusY = radius;
        [self clearPath];
    }
}

#pragma mark - Overrides

- (CGPathRef)newPath
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGRect rect = CGRectMake(self.center.x - self.radiusX, self.center.y - self.radiusY, self.radiusX * 2.0, self.radiusY * 2.0);

    CGPathAddEllipseInRect(path, NULL, rect);

    CGPathRef resultPath = CGPathCreateCopy(path);
    CGPathRelease(path);

    return resultPath;
}

@end
