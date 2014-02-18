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
//  PXGradient.m
//  Pixate
//
//  Created by Kevin Lindsey on 6/8/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXGradient.h"
#import "UIColor+PXColors.h"

@implementation PXGradient

@synthesize gradient = _gradient;
@synthesize blendMode = _blendMode;

#pragma mark - Initializers

- (id)init
{
    self = [super init];

    if (self)
    {
        _offsets = [NSMutableArray array];
        _colors = [NSMutableArray array];
        _transform = CGAffineTransformIdentity;
        _blendMode = kCGBlendModeNormal;
        _gradientUnits = PXGradientUnitsBoundingBox;
    }

    return self;
}

#pragma mark - Methods

- (void)addColor:(UIColor *)color
{
    [_colors addObject:color];
}

- (void)addColor:(UIColor *)color withOffset:(CGFloat)offset
{
    if (color)
    {
        int index = -1;

        for (int i = 0; i < [_offsets count]; i++)
        {
            if ([[_offsets objectAtIndex:i] floatValue] == offset)
            {
                index = i;
                break;
            }
        }

        if (index == -1)
        {
            [_colors addObject:color];
            [_offsets addObject:[NSNumber numberWithFloat:offset]];
        }
        else
        {
            [_colors replaceObjectAtIndex:index withObject:color];
            [_offsets replaceObjectAtIndex:index withObject:[NSNumber numberWithFloat:offset]];
        }
    }
}

- (void)applyFillToPath:(CGPathRef)path withContext:(CGContextRef)context
{
    // sub-classes need to override
}

- (id<PXPaint>)lightenByPercent:(CGFloat)percent
{
    // sub-classes need to override
    return nil;
}

- (id<PXPaint>)darkenByPercent:(CGFloat)percent
{
    // sub-classes need to override
    return nil;
}

#pragma mark - Getters

- (CGGradientRef)gradient
{
    if (!_gradient)
    {
        // if color count and offset count don't match, then evenly distribute all colors from 0 to 1
        if (_colors.count != self.offsets.count)
        {
            [_offsets removeAllObjects];

            for (int i = 0; i < _colors.count; i++)
            {
                [_offsets addObject:[NSNumber numberWithFloat:(CGFloat) i / (_colors.count - 1)]];
            }
        }

        // convert locations
        NSUInteger locationCount = [_offsets count];
        CGFloat locations[locationCount];

        for (int i = 0; i < locationCount; i++)
        {
            locations[i] = [[_offsets objectAtIndex:i] floatValue];
        }

        // convert colors
        NSMutableArray *cgColorArray = [NSMutableArray array];

        for (int i = 0; i < [_colors count]; i++)
        {
            CGColorRef cref = ((UIColor *) [_colors objectAtIndex:i]).CGColor;

            [cgColorArray addObject:(__bridge id)cref];
        }

        NSArray *colorArray = [NSArray arrayWithArray:cgColorArray];

        // create color space
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

        // create gradient
        _gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colorArray, locations);

        // release color space
        CGColorSpaceRelease(colorSpace);
    }

    // return gradient
    return _gradient;
}

- (BOOL)isOpaque
{
    BOOL result = YES;

    for (UIColor *color in _colors)
    {
        if (color.isOpaque == NO)
        {
            result = NO;
            break;
        }
    }

    return result;
}

#pragma mark - Setters

- (void)setGradient:(CGGradientRef)aGradient
{
    if (self->_gradient)
    {
        CGGradientRelease(self->_gradient);
    }

    self->_gradient = aGradient;
}

#pragma mark - Overrides

-(void)dealloc
{
    // release gradient
    self.gradient = nil;
}

- (BOOL)isEqual:(id)object
{
    BOOL result = NO;

    if ([object isKindOfClass:[PXGradient class]])
    {
        PXGradient *that = object;

        result = [self->_offsets isEqualToArray:that->_offsets]
            &&  [self->_colors isEqualToArray:that->_colors]
            &&  CGAffineTransformEqualToTransform(self->_transform, that->_transform)
            &&  (self->_gradient == that->_gradient)
            &&  (self->_blendMode == that->_blendMode);
    }

    return result;
}

@end
