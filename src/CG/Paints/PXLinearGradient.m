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
//  PXLinearGradient.m
//  Pixate
//
//  Created by Kevin Lindsey on 6/8/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXLinearGradient.h"
#import "PXVector.h"
#import "PXMath.h"
#import "UIColor+PXColors.h"

typedef enum {
    PXAngleTypeAngle,
    PXAngleTypePoints,
    PXAngleTypeDirection
} PXAngleType;

@implementation PXLinearGradient
{
    PXAngleType angleType_;
}

#pragma mark - Static Methods

+ (PXLinearGradient *)gradientFromStartColor:(UIColor *)startColor endColor:(UIColor *)endColor
{
    PXLinearGradient *lg = [[PXLinearGradient alloc] init];

    [lg addColor:startColor withOffset:0.0f];
    [lg addColor:endColor withOffset:1.0f];

    return lg;
}

#pragma mark - Initializers

- (id)init
{
    if (self = [super init])
    {
        _angle = 90.0f;
        _p1 = CGPointZero;
        _p2 = CGPointZero;
        angleType_ = PXAngleTypeAngle;
    }

    return self;
}

#pragma mark - Getters

- (CGFloat)cssAngle
{
    return self.angle + 90.0f;
}

- (CGFloat)psAngle
{
    return -self.angle;
}

#pragma mark - Setters

- (void)setAngle:(CGFloat)anAngle
{
    _angle = anAngle;
    angleType_ = PXAngleTypeAngle;
}

- (void)setCssAngle:(CGFloat)anAngle
{
    self.angle = anAngle - 90.0f;
}

- (void)setPsAngle:(CGFloat)anAngle
{
    self.angle = -anAngle;
}

- (void)setP1:(CGPoint)point
{
    _p1 = point;
    angleType_ = PXAngleTypePoints;
}

- (void)setP2:(CGPoint)point
{
    _p2 = point;
    angleType_ = PXAngleTypePoints;
}

- (void)setGradientDirection:(PXLinearGradientDirection)gradientDirection
{
    _gradientDirection = gradientDirection;
    angleType_ = PXAngleTypeDirection;
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

    // placeholders for gradient points
    CGPoint point1, point2;

    if (angleType_ == PXAngleTypePoints)
    {
        if (self.gradientUnits == PXGradientUnitsUserSpace)
        {
            point1 = self.p1;
            point2 = self.p2;
        }
        else
        {
            // linear-gradient points are based on the shape's bbox, so grab that
            CGRect pathBounds = CGPathGetBoundingBox(path);

            // grab the x,y offset which we will apply later
            CGFloat left = pathBounds.origin.x;
            CGFloat top = pathBounds.origin.y;

            // grab the positions within the bbox for each point
            CGFloat p1x = pathBounds.size.width * _p1.x;
            CGFloat p1y = pathBounds.size.height * _p1.y;
            CGFloat p2x = pathBounds.size.width * _p2.x;
            CGFloat p2y = pathBounds.size.height * _p2.y;

            // create final points by offsetting the bbox coordinates by the bbox origin
            point1 = CGPointMake(left + p1x, top + p1y);
            point2 = CGPointMake(left + p2x, top + p2y);
        }
    }
    else
    {
        CGRect pathBounds = CGPathGetBoundingBox(path);
        CGFloat angle;

        if (angleType_ == PXAngleTypeDirection)
        {
            switch (_gradientDirection)
            {
                case PXLinearGradientDirectionToTop:
                    angle = 270.0f;
                    break;

                case PXLinearGradientDirectionToTopRight:
                {
                    PXVector *toBottomRight = [PXVector vectorWithStartPoint:pathBounds.origin
                                                                    EndPoint:CGPointMake(pathBounds.origin.x + pathBounds.size.width, pathBounds.origin.y + pathBounds.size.height)];
                    angle = RADIANS_TO_DEGREES(toBottomRight.angle) - 90.0f;
                    break;
                }

                case PXLinearGradientDirectionToRight:
                    angle = 0.0f;
                    break;

                case PXLinearGradientDirectionToBottomRight:
                {
                    PXVector *toBottomLeft = [PXVector vectorWithStartPoint:CGPointMake(pathBounds.origin.x + pathBounds.size.width, pathBounds.origin.y)
                                                                   EndPoint:CGPointMake(pathBounds.origin.x, pathBounds.origin.y + pathBounds.size.height)];
                    angle = RADIANS_TO_DEGREES(toBottomLeft.angle) - 90.0f;
                    break;
                }

                case PXLinearGradientDirectionToBottom:
                    angle = 90.0f;
                    break;

                case PXLinearGradientDirectionToBottomLeft:
                {
                    PXVector *toTopLeft = [PXVector vectorWithStartPoint:CGPointMake(pathBounds.origin.x + pathBounds.size.width, pathBounds.origin.y + pathBounds.size.height)
                                                                EndPoint:pathBounds.origin];
                    angle = RADIANS_TO_DEGREES(toTopLeft.angle) - 90.0f;
                    break;
                }

                case PXLinearGradientDirectionToLeft:
                    angle = 180.0f;
                    break;

                case PXLinearGradientDirectionToTopLeft:
                {
                    PXVector *toTopRight = [PXVector vectorWithStartPoint:CGPointMake(pathBounds.origin.x, pathBounds.origin.y + pathBounds.size.height)
                                                                 EndPoint:CGPointMake(pathBounds.origin.x + pathBounds.size.width, pathBounds.origin.y)];
                    angle = RADIANS_TO_DEGREES(toTopRight.angle) - 90.0f;
                    break;
                }
            }
        }
        else
        {
            angle = self.angle;
        }

        // normalize between 0 and 2π
        angle = fmodf(angle, 360.0f);

        while (angle < 0.0f)
        {
            angle += 360.0f;
        }

        // calculate end points of gradient based on angle
        if (angle == 0)
        {
            point1 = pathBounds.origin;
            point2 = CGPointMake(pathBounds.origin.x + pathBounds.size.width, pathBounds.origin.y);
        }
        else if (angle == 90)
        {
            point1 = pathBounds.origin;
            point2 = CGPointMake(pathBounds.origin.x, pathBounds.origin.y + pathBounds.size.height);
        }
        else if (angle == 180)
        {
            point1 = CGPointMake(pathBounds.origin.x + pathBounds.size.width, pathBounds.origin.y);
            point2 = pathBounds.origin;
        }
        else if (angle == 270)
        {
            point1 = CGPointMake(pathBounds.origin.x, pathBounds.origin.y + pathBounds.size.height);
            point2 = pathBounds.origin;
        }
        else
        {
            // find active corner and it's opposite
            CGPoint endCorner = CGPointZero;

            // NOTE: assumes angle is in half-open interval [0,360)
            if (0.0f <= angle && angle < 90.0f)
            {
                // top-left
                endCorner = pathBounds.origin;
            }
            else if (90.0f <= angle && angle < 180.0f)
            {
                // top-right
                endCorner = CGPointMake(pathBounds.origin.x + pathBounds.size.width, pathBounds.origin.y);
            }
            else if (180.0f <= angle && angle < 270.0f)
            {
                // bottom-right
                endCorner = CGPointMake(pathBounds.origin.x + pathBounds.size.width, pathBounds.origin.y + pathBounds.size.height);
            }
            else if (270.0f <= angle && angle < 360.0f)
            {
                // bottom-left
                endCorner = CGPointMake(pathBounds.origin.x, pathBounds.origin.y + pathBounds.size.height);
            }
            else
            {
                // error
                NSLog(@"Angle not within the half-closed interval [0,360): %f", angle);
            }

            // find center
            CGPoint center = CGPointMake(pathBounds.origin.x + pathBounds.size.width * 0.5f, pathBounds.origin.y + pathBounds.size.height * 0.5f);

            // get corner and angle vectors
            CGFloat radians = DEGREES_TO_RADIANS(angle);
            PXVector *cornerVector = [PXVector vectorWithStartPoint:center EndPoint:endCorner];
            PXVector *angleVector = [PXVector vectorWithStartPoint:CGPointZero EndPoint:CGPointMake(COS(radians), SIN(radians))];

            // project corner vector onto angle vector
            PXVector *projection = [cornerVector projectOnto:angleVector];

            // apply results
            point1 = CGPointMake(center.x + projection.x, center.y + projection.y);
            point2 = CGPointMake(center.x - projection.x, center.y - projection.y);
        }
    }

    // set blending mode
    CGContextSetBlendMode(context, self.blendMode);

    // do the gradient
    CGContextDrawLinearGradient(context, self.gradient, point1, point2, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);

    // restore coordinate system
    CGContextRestoreGState(context);
}

- (id<PXPaint>)lightenByPercent:(CGFloat)percent
{
    PXLinearGradient *result = [self createCopyWithoutColors];

    // copy and darken colors
    [self.colors enumerateObjectsUsingBlock:^(UIColor *color, NSUInteger idx, BOOL *stop) {
        [result addColor:[color lightenByPercent:percent]];
    }];

    return result;
}

- (id<PXPaint>)darkenByPercent:(CGFloat)percent
{
    PXLinearGradient *result = [self createCopyWithoutColors];

    // copy and darken colors
    [self.colors enumerateObjectsUsingBlock:^(UIColor *color, NSUInteger idx, BOOL *stop) {
        [result addColor:[color darkenByPercent:percent]];
    }];

    return result;
}

- (PXLinearGradient *)createCopyWithoutColors
{
    PXLinearGradient *result = [[PXLinearGradient alloc] init];

    // copy properties
    result->_angle = _angle;
    result->_p1 = _p1;
    result->_p2 = _p2;
    result->_gradientDirection = _gradientDirection;

    // copy PXGradient properties, but not colors
    result.transform = self.transform;
    result.offsets = [NSMutableArray arrayWithArray:self.offsets];

    return result;
}

#pragma mark - Overrides

- (NSString *)description
{
    NSMutableArray *parts = [[NSMutableArray alloc] init];

    [parts addObject:@"linear-gradient("];

    // show degree
    [parts addObject:[NSString stringWithFormat:@"%6.2fdeg", self.cssAngle]];

    // show colors with offsets
    for (UIColor *color in self.colors)
    {
        [parts addObject:@","];
        [parts addObject:color.description];
    }

    [parts addObject:@")"];

    return [parts componentsJoinedByString:@""];
}

- (BOOL)isEqual:(id)object
{
    BOOL result = [super isEqual:object];

    if (result && object && [object isKindOfClass:[PXLinearGradient class]])
    {
        PXLinearGradient *that = object;

        result = (angleType_ == that->angleType_);

        if (result)
        {
            switch (angleType_)
            {
                case PXAngleTypeAngle:
                    result = (_angle == that->_angle);
                    break;

                case PXAngleTypeDirection:
                    result = (_gradientDirection == that->_gradientDirection);
                    break;

                case PXAngleTypePoints:
                    result = (CGPointEqualToPoint(_p1, that->_p1) && CGPointEqualToPoint(_p2, that->_p2));
                    break;
            }
        }
    }

    return result;
}

@end
