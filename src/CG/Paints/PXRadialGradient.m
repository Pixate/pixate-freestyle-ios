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
//  PXRadialGradient.m
//  Pixate
//
//  Created by Kevin Lindsey on 6/8/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXRadialGradient.h"
#import "UIColor+PXColors.h"

@implementation PXRadialGradient

#pragma mark - Initializers

- (id)init
{
    if (self = [super init])
    {
        _startCenter = CGPointZero;
        _endCenter = CGPointZero;
        _radius = 0;
    }

    return self;
}

#pragma mark - PXPaint implementation

- (void)applyFillToPath:(CGPathRef)path withContext:(CGContextRef)context
{
    CGContextSaveGState(context);

    // clip to path
    CGContextAddPath(context, path);
    CGContextClip(context);

    // transform gradient space
    CGContextConcatCTM(context, self.transform);

    CGPoint center1;
    CGPoint center2;
    CGFloat r;

    if (_radius == 0)
    {
        CGRect bounds = CGPathGetPathBoundingBox(path);
        center1 = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
        center2 = center1;
        r = fmin(CGRectGetWidth(bounds) * 0.5f, CGRectGetHeight(bounds) * 0.5f);
    }
    else if (self.gradientUnits == PXGradientUnitsUserSpace)
    {
        center1 = _startCenter;
        center2 = _endCenter;
        r = _radius;
    }
    else
    {
        // linear-gradient points are based on the shape's bbox, so grab that
        CGRect pathBounds = CGPathGetBoundingBox(path);

        // grab the x,y offset which we will apply later
        CGFloat left = pathBounds.origin.x;
        CGFloat top = pathBounds.origin.y;

        // grab the positions within the bbox for each point
        CGFloat p1x = pathBounds.size.width * _startCenter.x;
        CGFloat p1y = pathBounds.size.height * _startCenter.y;
        CGFloat p2x = pathBounds.size.width * _endCenter.x;
        CGFloat p2y = pathBounds.size.height * _endCenter.y;

        // create final points by offsetting the bbox coordinates by the bbox origin
        center1 = CGPointMake(left + p1x, top + p1y);
        center2 = CGPointMake(left + p2x, top + p2y);

        // TODO: need rx and ry. Using width for both now
        r = pathBounds.size.width * _radius;
    }

    // set blending mode
    CGContextSetBlendMode(context, self.blendMode);

    // do the gradient
    CGContextDrawRadialGradient(context, self.gradient, center1, 0, center2, r, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);

    // restore coordinate system
    CGContextRestoreGState(context);
}

- (id<PXPaint>)lightenByPercent:(CGFloat)percent
{
    PXRadialGradient *result = [self createCopyWithoutColors];

    // copy and darken colors
    [self.colors enumerateObjectsUsingBlock:^(UIColor *color, NSUInteger idx, BOOL *stop) {
        [result addColor:[color lightenByPercent:percent]];
    }];

    return result;
}

- (id<PXPaint>)darkenByPercent:(CGFloat)percent
{
    PXRadialGradient *result = [self createCopyWithoutColors];

    // copy and darken colors
    [self.colors enumerateObjectsUsingBlock:^(UIColor *color, NSUInteger idx, BOOL *stop) {
        [result addColor:[color darkenByPercent:percent]];
    }];

    return result;
}

- (PXRadialGradient *)createCopyWithoutColors
{
    PXRadialGradient *result = [[PXRadialGradient alloc] init];

    // copy properties
    result->_startCenter = _startCenter;
    result->_endCenter = _endCenter;
    result->_radius = _radius;

    // copy PXGradient properties, but not colors
    result.transform = self.transform;
    result.offsets = [NSMutableArray arrayWithArray:self.offsets];

    return result;
}

#pragma mark - Overrides

- (BOOL)isEqual:(id)object
{
    BOOL result = [super isEqual:object];

    if (result && object && [object isKindOfClass:[PXRadialGradient class]])
    {
        PXRadialGradient *that = object;

        result = CGPointEqualToPoint(_startCenter, that->_startCenter)
            && CGPointEqualToPoint(_endCenter, that->_endCenter)
            && _radius == that->_radius;
    }

    return result;
}

@end
