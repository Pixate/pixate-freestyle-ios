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
//  PXArrowRectangle.m
//  Pixate
//
//  Created by Kevin Lindsey on 12/19/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXArrowRectangle.h"
#import "PXEllipticalArc.h"

@implementation PXArrowRectangle

#pragma mark - Initializers

- (id)initWithDirection:(PXArrowRectangleDirection)direction
{
    return [self initWithRect:CGRectZero direction:direction];
}

- (id)initWithRect:(CGRect)bounds direction:(PXArrowRectangleDirection)direction
{
    if (self = [super initWithRect:bounds])
    {
        _direction = direction;
    }

    return self;
}

#pragma mark - Overrides

- (CGPathRef)newPath
{
    CGFloat handleOffset = 2.5f;
    CGFloat arrowWidth = 12.0f;

    CGFloat left = self.bounds.origin.x;
    CGFloat top = self.bounds.origin.y;
    CGFloat right = left + self.bounds.size.width;
    CGFloat bottom = top + self.bounds.size.height;
    CGFloat arrowLeftY = (top + bottom) * 0.5f;

    CGPathRef resultPath;

    if (self.hasRoundedCorners == NO)
    {
        // create path
        CGMutablePathRef path = CGPathCreateMutable();

        if (_direction == PXArrowRectangleDirectionLeft)
        {
            CGFloat arrowRightX = MIN(right, left + arrowWidth);

            CGPathMoveToPoint(path, NULL, left, arrowLeftY);
            CGPathAddCurveToPoint(path, NULL, left, arrowLeftY, arrowRightX - handleOffset, bottom, arrowRightX, bottom);
            CGPathAddLineToPoint(path, NULL, right, bottom);
            CGPathAddLineToPoint(path, NULL, right, top);
            CGPathAddLineToPoint(path, NULL, arrowRightX, top);
            CGPathAddCurveToPoint(path, NULL, arrowRightX, top, arrowRightX - handleOffset, top, left, arrowLeftY);
            CGPathCloseSubpath(path);
        }
        else
        {
            CGFloat arrowRightX = MAX(left, right - arrowWidth);

            CGPathMoveToPoint(path, NULL, right, arrowLeftY);
            CGPathAddCurveToPoint(path, NULL, right, arrowLeftY, arrowRightX + handleOffset, bottom, arrowRightX, bottom);
            CGPathAddLineToPoint(path, NULL, left, bottom);
            CGPathAddLineToPoint(path, NULL, left, top);
            CGPathAddLineToPoint(path, NULL, arrowRightX, top);
            CGPathAddCurveToPoint(path, NULL, arrowRightX, top, arrowRightX + handleOffset, top, right, arrowLeftY);
            CGPathCloseSubpath(path);
        }

        resultPath = CGPathCreateCopy(path);

        CGPathRelease(path);
    }
    else
    {
        // top points
        CGFloat topLeftX = left + self.radiusTopLeft.width;
        CGFloat topRightX = right - self.radiusTopRight.width;

        // right points
        CGFloat rightTopY = top + self.radiusTopRight.height;
        CGFloat rightBottomY = bottom - self.radiusBottomRight.height;

        // bottom points
        CGFloat bottomLeftX = left + self.radiusBottomLeft.width;
        CGFloat bottomRightX = right - self.radiusBottomRight.width;

        // left points
        CGFloat leftTopY = top + self.radiusTopLeft.height;
        CGFloat leftBottomY = bottom - self.radiusBottomLeft.height;

        // create path
        CGMutablePathRef path = CGPathCreateMutable();

        if (_direction == PXArrowRectangleDirectionLeft)
        {
            CGFloat arrowRightX = MIN(right, left + arrowWidth);

            CGPathMoveToPoint(path, NULL, left, arrowLeftY);
            CGPathAddCurveToPoint(path, NULL, left, arrowLeftY, arrowRightX - handleOffset, bottom, arrowRightX, bottom);

            // add right and bottom-right corner
            if (self.radiusBottomRight.width > 0.0f && self.radiusBottomRight.height > 0.0f)
            {
                CGPathAddLineToPoint(path, NULL, bottomRightX, bottom);
                CGPathAddEllipticalArc(path, NULL, bottomRightX, rightBottomY, self.radiusBottomRight.width, self.radiusBottomRight.height, -3.0 * M_PI_2, 0.0f);
            }
            else
            {
                CGPathAddLineToPoint(path, NULL, right, bottom);
            }

            // add top and top-right corner
            if (self.radiusTopRight.width > 0.0f && self.radiusTopRight.height > 0.0f)
            {
                CGPathAddLineToPoint(path, NULL, right, rightTopY);
                CGPathAddEllipticalArc(path, NULL, topRightX, rightTopY, self.radiusTopRight.width, self.radiusTopRight.height, 0.0f, -M_PI_2);
            }
            else
            {
                CGPathAddLineToPoint(path, NULL, right, top);
            }

            CGPathAddLineToPoint(path, NULL, arrowRightX, top);
            CGPathAddCurveToPoint(path, NULL, arrowRightX, top, arrowRightX - handleOffset, top, left, arrowLeftY);
            CGPathCloseSubpath(path);
        }
        else
        {
            CGFloat arrowRightX = MAX(left, right - arrowWidth);

            CGPathMoveToPoint(path, NULL, right, arrowLeftY);
            CGPathAddCurveToPoint(path, NULL, right, arrowLeftY, arrowRightX + handleOffset, bottom, arrowRightX, bottom);

            // add bottom and bottom-left corner
            if (self.radiusBottomLeft.width > 0.0f && self.radiusBottomLeft.height > 0.0f)
            {
                CGPathAddLineToPoint(path, NULL, bottomLeftX, bottom);
                CGPathAddEllipticalArc(path, NULL, bottomLeftX, leftBottomY, self.radiusBottomLeft.width, self.radiusBottomLeft.height, M_PI_2, -M_PI);
            }
            else
            {
                CGPathAddLineToPoint(path, NULL, left, bottom);
            }

            // add left and top-left corner
            if (self.radiusTopLeft.width > 0.0f && self.radiusTopLeft.height > 0.0f)
            {
                CGPathAddLineToPoint(path, NULL, left, leftTopY);
                CGPathAddEllipticalArc(path, NULL, topLeftX, leftTopY, self.radiusTopLeft.width, self.radiusTopLeft.height, M_PI, 3.0f * M_PI_2);
            }
            else
            {
                CGPathAddLineToPoint(path, NULL, left, top);
            }

            CGPathAddLineToPoint(path, NULL, arrowRightX, top);
            CGPathAddCurveToPoint(path, NULL, arrowRightX, top, arrowRightX + handleOffset, top, right, arrowLeftY);
            CGPathCloseSubpath(path);
        }

        resultPath = CGPathCreateCopy(path);

        CGPathRelease(path);
    }

    return resultPath;
}

@end
