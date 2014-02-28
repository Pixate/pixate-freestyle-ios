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
//  PXStroke.m
//  Pixate
//
//  Created by Kevin Lindsey on 7/2/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXStroke.h"

@implementation PXStroke

#pragma mark - Initializers

- (id)init
{
    return [self initWithStrokeWidth:0.0f];
}

- (id)initWithStrokeWidth:(CGFloat)width
{
    if (self = [super init])
    {
        _type = kStrokeTypeCenter;
        _color = nil;
        _width = width;
        _dashArray = nil;
        _dashOffset = 0;
        _lineCap = kCGLineCapButt;
        _lineJoin = kCGLineJoinMiter;
        _miterLimit = 4.0;  // What is a reasonable default here?
    }

    return self;
}

#pragma mark - Getters

- (CGPathRef)newStrokedPath:(CGPathRef)path
{
    CGPathRef strokedPath;

    if ([_dashArray count] > 0)
    {
        NSUInteger count = [_dashArray count];
        CGFloat lengths[count];

        for (int i = 0; i < count; i++)
        {
            NSNumber *number = [_dashArray objectAtIndex:i];

            lengths[i] = [number floatValue];
        }

        CGPathRef dashedStroke = CGPathCreateCopyByDashingPath(path, NULL, _dashOffset, lengths, count);
        strokedPath = CGPathCreateCopyByStrokingPath(dashedStroke, NULL, _width, _lineCap, _lineJoin, _miterLimit);

        CGPathRelease(dashedStroke);
    }
    else
    {
        strokedPath = CGPathCreateCopyByStrokingPath(path, NULL, _width, _lineCap, _lineJoin, _miterLimit);
    }

    return strokedPath;
}

- (BOOL)isOpaque
{
    return _color.isOpaque;
}

#pragma mark - Methods

- (void)applyStrokeToPath:(CGPathRef)path withContext:(CGContextRef)context
{
    if (_color && _width > 0.0)
    {
        // stroke and possibly dash incoming path
        CGPathRef strokedPath = [self newStrokedPath:path];

        // set up masking for inner/outer/center stroke
        if (_type == kStrokeTypeInner)
        {
            CGContextSaveGState(context);

            // clip to path
            CGContextAddPath(context, path);
            CGContextClip(context);
        }
        else if (_type == kStrokeTypeOuter)
        {
            // TODO:
        }
        // else is center, so do nothing

        [_color applyFillToPath:strokedPath withContext:context];

        // done with stroke path, so release it
        //CGPathRelease(strokedPath);

        // reset environment
        if (_type == kStrokeTypeInner)
        {
            CGContextRestoreGState(context);
        }
        else if (_type == kStrokeTypeOuter)
        {
            // TODO: just move condition into above test
        }

        CGPathRelease(strokedPath);
    }
}

#pragma mark - Overrides

- (void)dealloc
{
    _color = nil;
    _dashArray = nil;
}

- (BOOL)isEqual:(id)object
{
    BOOL result = NO;

    if ([object isKindOfClass:[PXStroke class]])
    {
        PXStroke *that = object;

        result = (_type == that->_type)
            &&  (_color == that->_color)
            &&  (_width == that->_width)
            &&  [_dashArray isEqualToArray:that->_dashArray]
            &&  (_dashOffset == that->_dashOffset)
            &&  (_lineCap == that->_lineCap)
            &&  (_lineJoin == that->_lineJoin)
            &&  (_miterLimit == that->_miterLimit);
    }

    return result;
}

@end
