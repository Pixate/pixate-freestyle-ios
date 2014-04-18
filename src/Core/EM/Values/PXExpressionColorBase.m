//
//  PXExpressionColorBase.m
//  pixate-freestyle
//
//  Created by Kevin Lindsey on 4/17/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "PXExpressionColorBase.h"
#import "PXHSBColorValue.h"
#import "PXHSLColorValue.h"
#import "PXRGBColorValue.h"

@implementation PXExpressionColorBase

- (id)init
{
    return [self initWithValueType:PX_VALUE_TYPE_OBJECT];
}

- (id)initWithColor:(UIColor *)color
{
    if (self = [super init])
    {
        // subclasses are responsible for implementing this initializer
    }

    return self;
}

#pragma mark - PXExpressionColor Implementation

- (PXHSBColorValue *)hsbColorValue
{
    return [[PXHSBColorValue alloc] initWithColor:[self colorValue]];
}

- (PXHSLColorValue *)hslColorValue
{
    return [[PXHSLColorValue alloc] initWithColor:[self colorValue]];
}

- (PXRGBColorValue *)rgbColorValue
{
    return [[PXRGBColorValue alloc] initWithColor:[self colorValue]];
}

- (UIColor *)colorValue
{
    return [UIColor blackColor];
}

- (id<PXExpressionColor>)convertColor:(id<PXExpressionColor>)color
{
    if ([self class] == [color class])
    {
        return color;
    }
    else
    {
        id<PXExpressionColor> result = [[self class] alloc];

        return [result initWithColor:[color colorValue]];
    }
}

@end
