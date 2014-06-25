//
//  PXHSLColorValue.m
//  pixate-freestyle
//
//  Created by Kevin Lindsey on 4/17/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "PXHSLColorValue.h"
#import "UIColor+PXColors.h"

@implementation PXHSLColorValue

#pragma mark - Initializers

- (id)initWithColor:(UIColor *)color
{
    CGFloat hue, saturation, lightness, alpha;

    [color getHue:&hue saturation:&saturation brightness:&lightness alpha:&alpha];

    return [self initWithHue:hue * 360.0 saturation:saturation lightness:lightness alpha:alpha];
}

- (id)initWithHue:(double)hue saturation:(double)saturation lightness:(double)lightness
{
    return [self initWithHue:hue saturation:saturation lightness:lightness alpha:1.0];
}

- (id)initWithHue:(double)hue saturation:(double)saturation lightness:(double)lightness alpha:(double)alpha
{
    if (self = [super init])
    {
        _hue = hue;
        _saturation = saturation;
        _lightness = lightness;
        _alpha = alpha;

        [self addDoublePropertyForName:@"hue"];
        [self addDoublePropertyForName:@"saturation"];
        [self addDoublePropertyForName:@"lightness"];
        [self addDoublePropertyForName:@"alpha"];
    }

    return self;
}

#pragma mark - PXExpressionValue Implementation

- (NSString *)stringValue
{
    return @"[value HSLColor]";
}

#pragma mark - PXExpressionColor Implementation

- (UIColor *)colorValue
{
    return [UIColor colorWithHue:_hue / 360.0 saturation:_saturation lightness:_lightness alpha:_alpha];
}

- (PXHSLColorValue *)hslColorValue
{
    return self;
}

#pragma mark - Overrides

- (NSString *)description
{
    return [NSString stringWithFormat:@"hsla(%g,%g,%g,%g)", _hue, _saturation, _lightness, _alpha];
}

@end
