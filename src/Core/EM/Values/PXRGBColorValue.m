//
//  PXRGBColorValue.m
//  pixate-freestyle
//
//  Created by Kevin Lindsey on 4/17/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "PXRGBColorValue.h"

@implementation PXRGBColorValue

#pragma mark - Initializers

- (id)initWithColor:(UIColor *)color
{
    CGFloat red, green, blue, alpha;

    [color getRed:&red green:&green blue:&blue alpha:&alpha];

    return [self initWithRed:red * 255.0 green:green * 255.0 blue:blue * 255.0 alpha:alpha];
}

- (id)initWithRed:(double)red green:(double)green blue:(double)blue
{
    return [self initWithRed:red green:green blue:blue alpha:1.0];
}

- (id)initWithRed:(double)red green:(double)green blue:(double)blue alpha:(double)alpha
{
    if (self = [super init])
    {
        _red = red;
        _green = green;
        _blue = blue;
        _alpha = alpha;

        [self addDoublePropertyForName:@"red"];
        [self addDoublePropertyForName:@"green"];
        [self addDoublePropertyForName:@"blue"];
        [self addDoublePropertyForName:@"alpha"];
    }

    return self;
}

#pragma mark - PXExpressionValue Implementation

- (NSString *)stringValue
{
    return @"[value RGBColor]";
}

#pragma mark - PXExpressionColor Implementation

- (UIColor *)colorValue
{
    return [UIColor colorWithRed:_red/255.0 green:_green/255.0 blue:_blue/255.0 alpha:_alpha];
}

- (PXRGBColorValue *)rgbColorValue
{
    return self;
}

#pragma mark - Overrides

- (NSString *)description
{
    return [NSString stringWithFormat:@"rgba(%d,%d,%d,%g)", (int)_red, (int)_green, (int)_blue, _alpha];
}

@end
