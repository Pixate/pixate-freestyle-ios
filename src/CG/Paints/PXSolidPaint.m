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
//  PXSolidPaint.m
//  Pixate
//
//  Created by Kevin Lindsey on 6/7/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXSolidPaint.h"
#import "UIColor+PXColors.h"

@implementation PXSolidPaint

@synthesize blendMode = _blendMode;

#pragma mark - Static Initializers

+ (id)paintWithColor:(UIColor *)color
{
    return [[PXSolidPaint alloc] initWithColor:color];
}

#pragma mark - Initializers

- (id)init
{
    return [self initWithColor:[UIColor blackColor]];
}

- (id)initWithColor:(UIColor *)aColor
{
    if (self = [super init])
    {
        _color = aColor;
        _blendMode = kCGBlendModeNormal;
    }

    return self;
}

#pragma mark - Getters

- (UIColor *)activeColor
{
    return (_color) ? _color : [UIColor clearColor];
}

- (BOOL)isOpaque
{
    return _color.isOpaque;
}

#pragma mark - Overrides

- (BOOL)isEqual:(id)object
{
    BOOL result = NO;

    if (object && [object isKindOfClass:[PXSolidPaint class]])
    {
        PXSolidPaint *that = object;

        result = [_color isEqual:that->_color] && _blendMode == that->_blendMode;
    }

    return result;
}

#pragma mark - PXPaint implementation

- (void)applyFillToPath:(CGPathRef)path withContext:(CGContextRef)context
{
    CGContextSetFillColorWithColor(context, [self activeColor].CGColor);

    CGContextAddPath(context, path);

    // set blending mode
    CGContextSetBlendMode(context, _blendMode);

    CGContextFillPath(context);
}

- (id<PXPaint>)lightenByPercent:(CGFloat)percent
{
    return [[PXSolidPaint alloc] initWithColor:[_color lightenByPercent:percent]];
}

- (id<PXPaint>)darkenByPercent:(CGFloat)percent
{
    return [[PXSolidPaint alloc] initWithColor:[_color darkenByPercent:percent]];
}

@end
