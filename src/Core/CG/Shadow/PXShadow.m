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
//  PXShadow.m
//  Pixate
//
//  Created by Kevin Lindsey on 8/31/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXShadow.h"

@implementation PXShadow

@synthesize blendMode = _blendMode;

#pragma mark - Initializers

- (id)init
{
    if (self = [super init])
    {
        _blendMode = kCGBlendModeNormal;
    }

    return self;
}

#pragma mark - Overrides

- (NSString *)description
{
    NSMutableArray *parts = [[NSMutableArray alloc] init];

    if (_inset)
    {
        [parts addObject:@"inset "];
    }

    [parts addObject:[NSString stringWithFormat:@"%f ", _horizontalOffset]];
    [parts addObject:[NSString stringWithFormat:@"%f ", _verticalOffset]];
    [parts addObject:[NSString stringWithFormat:@"%f ", _blurDistance]];
    [parts addObject:[NSString stringWithFormat:@"%f ", _spreadDistance]];
    [parts addObject:_color.description];

    return [parts componentsJoinedByString:@""];
}

- (void)applyOutsetToPath:(CGPathRef)path withContext:(CGContextRef)context
{
    if (!_inset)
    {
        CGSize offset = CGSizeMake(_horizontalOffset, _verticalOffset);

        if (_color)
        {
            CGContextSetShadowWithColor(context, offset, _blurDistance, _color.CGColor);
        }
        else
        {
            CGContextSetShadow(context, offset, _blurDistance);
        }

        CGContextAddPath(context, path);

        // set blending mode
        CGContextSetBlendMode(context, self.blendMode);

        CGContextFillPath(context);
    }
}

- (void)applyInsetToPath:(CGPathRef)path withContext:(CGContextRef)context
{
    if (_inset)
    {
        // calculate shadow bounds
        CGRect bounds = CGPathGetBoundingBox(path);
        CGRect shadowBounds = CGRectInset(bounds, -_blurDistance, -_blurDistance);
        shadowBounds = CGRectOffset(shadowBounds, -_horizontalOffset, -_verticalOffset);
        shadowBounds = CGRectInset(CGRectUnion(shadowBounds, bounds), -1.0, -1.0);

        CGMutablePathRef invertedPath = CGPathCreateMutable();
        CGPathAddRect(invertedPath, nil, shadowBounds);
        CGPathAddPath(invertedPath, nil, path);

        // save context
        CGContextSaveGState(context);

        // render shadown
        CGFloat xOffset = _horizontalOffset + round(shadowBounds.size.width);
        CGFloat yOffset = _verticalOffset;
        CGSize offset = CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset));

        if (_color)
        {
            CGContextSetShadowWithColor(context, offset, _blurDistance, _color.CGColor);
        }
        else
        {
            CGContextSetShadow(context, offset, _blurDistance);
        }

        // add clipping path
        CGContextAddPath(context, path);
        CGContextClip(context);

        // transform shadow
        CGContextTranslateCTM(context, -round(shadowBounds.size.width), 0);

        // add negative path
        CGContextAddPath(context, invertedPath);

        // set blending mode
        CGContextSetBlendMode(context, self.blendMode);

        // fill
        CGContextEOFillPath(context);

        // retore context
        CGContextRestoreGState(context);

        // release path
        CGPathRelease(invertedPath);
    }
}

@end
