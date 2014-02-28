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
//  PXRectangle.m
//  Pixate
//
//  Created by Kevin Lindsey on 5/30/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXRectangle.h"
#import "PXEllipticalArc.h"

@implementation PXRectangle

@synthesize bounds = _bounds;

#pragma mark - Initializers

- (id)initWithRect:(CGRect)rect
{
    self = [super init];

    if (self)
    {
        self.bounds = rect;
    }

    return self;
}

#pragma mark - Getters

- (CGSize)size
{
    return _bounds.size;
}

- (CGFloat)x
{
    return _bounds.origin.x;
}

- (CGFloat)y
{
    return _bounds.origin.y;
}

- (CGFloat)width
{
    return _bounds.size.width;
}

- (CGFloat)height
{
    return self.bounds.size.height;
}

#pragma mark - Setters

- (void)setBounds:(CGRect)bounds
{
    if (!CGRectEqualToRect(_bounds, bounds))
    {
        _bounds = bounds;
        [self clearPath];
    }
}

- (void)setSize:(CGSize)size
{
    if (!CGSizeEqualToSize(_bounds.size, size))
    {
        _bounds.size = size;
        [self clearPath];
    }
}

- (void)setX:(CGFloat)x
{
    if (_bounds.origin.x != x)
    {
        _bounds.origin.x = x;
        [self clearPath];
    }
}

- (void)setY:(CGFloat)y
{
    if (_bounds.origin.y != y)
    {
        _bounds.origin.y = y;
        [self clearPath];
    }
}

- (void)setWidth:(CGFloat)width
{
    if (_bounds.size.width != width)
    {
        _bounds.size.width = width;
        [self clearPath];
    }
}

- (void)setHeight:(CGFloat)height
{
    if (_bounds.size.height != height)
    {
        _bounds.size.height = height;
        [self clearPath];
    }
}

- (void)setRadiusTopLeft:(CGSize)radiusTopLeft
{
    if (!CGSizeEqualToSize(_radiusTopLeft, radiusTopLeft))
    {
        _radiusTopLeft = radiusTopLeft;
        [self clearPath];
    }
}

- (void)setRadiusTopRight:(CGSize)radiusTopRight
{
    if (!CGSizeEqualToSize(_radiusTopRight, radiusTopRight))
    {
        _radiusTopRight = radiusTopRight;
        [self clearPath];
    }
}

- (void)setRadiusBottomRight:(CGSize)radiusBottomRight
{
    if (!CGSizeEqualToSize(_radiusBottomRight, radiusBottomRight))
    {
        _radiusBottomRight = radiusBottomRight;
        [self clearPath];
    }
}

- (void)setRadiusBottomLeft:(CGSize)radiusBottomLeft
{
    if (CGSizeEqualToSize(_radiusBottomLeft, radiusBottomLeft) == NO)
    {
        _radiusBottomLeft = radiusBottomLeft;
        [self clearPath];
    }
}

- (void)setCornerRadius:(CGFloat)radius
{
    [self setCornerRadii:CGSizeMake(radius, radius)];
}

- (void)setCornerRadii:(CGSize)radii
{
    self.radiusTopLeft = radii;
    self.radiusTopRight = radii;
    self.radiusBottomRight = radii;
    self.radiusBottomLeft = radii;
}

#pragma mark - Methods

- (BOOL)hasRoundedCorners
{
    return
        CGSizeEqualToSize(_radiusTopLeft, CGSizeZero) == NO
    ||  CGSizeEqualToSize(_radiusTopRight, CGSizeZero) == NO
    ||  CGSizeEqualToSize(_radiusBottomRight, CGSizeZero) == NO
    ||  CGSizeEqualToSize(_radiusBottomLeft, CGSizeZero) == NO;
}

- (CGPathRef)newPath
{
    CGPathRef resultPath;

    if (self.hasRoundedCorners == NO)
    {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, self.bounds);

        resultPath = CGPathCreateCopy(path);

        CGPathRelease(path);
    }
    else
    {
        CGFloat left = self.bounds.origin.x;
        CGFloat top = self.bounds.origin.y;
        CGFloat right = left + self.bounds.size.width;
        CGFloat bottom = top + self.bounds.size.height;

        // top points
        CGFloat topLeftX = left + _radiusTopLeft.width;
        CGFloat topRightX = right - _radiusTopRight.width;

        // right points
        CGFloat rightTopY = top + _radiusTopRight.height;
        CGFloat rightBottomY = bottom - _radiusBottomRight.height;

        // bottom points
        CGFloat bottomLeftX = left + _radiusBottomLeft.width;
        CGFloat bottomRightX = right - _radiusBottomRight.width;

        // left points
        CGFloat leftTopY = top + _radiusTopLeft.height;
        CGFloat leftBottomY = bottom - _radiusBottomLeft.height;

        // create path
        CGMutablePathRef path = CGPathCreateMutable();

        // move to starting point
        CGPathMoveToPoint(path, NULL, topLeftX, top);

        // add top and top-right corner
        if (_radiusTopRight.width > 0.0f && _radiusTopRight.height > 0.0f)
        {
            CGPathAddLineToPoint(path, NULL, topRightX, top);
            CGPathAddEllipticalArc(path, NULL, topRightX, rightTopY, _radiusTopRight.width, _radiusTopRight.height, -M_PI_2, 0.0f);
        }
        else
        {
            CGPathAddLineToPoint(path, NULL, right, top);
        }

        // add right and bottom-right corner
        if (_radiusBottomRight.width > 0.0f && _radiusBottomRight.height > 0.0f)
        {
            CGPathAddLineToPoint(path, NULL, right, rightBottomY);
            CGPathAddEllipticalArc(path, NULL, bottomRightX, rightBottomY, _radiusBottomRight.width, _radiusBottomRight.height, 0.0f, M_PI_2);
        }
        else
        {
            CGPathAddLineToPoint(path, NULL, right, bottom);
        }

        // add bottom and bottom-left corner
        if (_radiusBottomLeft.width > 0.0f && _radiusBottomLeft.height > 0.0f)
        {
            CGPathAddLineToPoint(path, NULL, bottomLeftX, bottom);
            CGPathAddEllipticalArc(path, NULL, bottomLeftX, leftBottomY, _radiusBottomLeft.width, _radiusBottomLeft.height, M_PI_2, M_PI);
        }
        else
        {
            CGPathAddLineToPoint(path, NULL, left, bottom);
        }

        // add left and top-left corner
        if (_radiusTopLeft.width > 0.0f && _radiusTopLeft.height > 0.0f)
        {
            CGPathAddLineToPoint(path, NULL, left, leftTopY);
            CGPathAddEllipticalArc(path, NULL, topLeftX, leftTopY, _radiusTopLeft.width, _radiusTopLeft.height, M_PI, 3.0f * M_PI_2);
        }
        else
        {
            CGPathAddLineToPoint(path, NULL, left, top);
        }

        // close path
        CGPathCloseSubpath(path);

        resultPath = CGPathCreateCopy(path);

        CGPathRelease(path);
    }

    return resultPath;
}

@end
