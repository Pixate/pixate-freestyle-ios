//
//  PXHSBColorValue.m
//  pixate-freestyle
//
//  Created by Kevin Lindsey on 4/17/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "PXHSBColorValue.h"
#import "UIColor+PXColors.h"

@implementation PXHSBColorValue

#pragma mark - Initializers

- (id)initWithColor:(UIColor *)color
{
    CGFloat hue, saturation, brightness, alpha;

    [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];

    return [self initWithHue:hue * 360.0 saturation:saturation brightness:brightness alpha:alpha];
}

- (id)initWithHue:(double)hue saturation:(double)saturation brightness:(double)brightness
{
    return [self initWithHue:hue saturation:saturation brightness:brightness alpha:1.0];
}

- (id)initWithHue:(double)hue saturation:(double)saturation brightness:(double)brightness alpha:(double)alpha
{
    if (self = [super init])
    {
        _hue = hue;
        _saturation = saturation;
        _brightness = brightness;
        _alpha = alpha;

        [self addDoublePropertyForName:@"hue"];
        [self addDoublePropertyForName:@"saturation"];
        [self addDoublePropertyForName:@"brightness"];
        [self addDoublePropertyForName:@"alpha"];
    }

    return self;
}

#pragma mark - PXExpressionValue Implementation

- (NSString *)stringValue
{
    return @"[value HSBColor]";
}

#pragma mark - PXExpressionColor Implementation

- (UIColor *)colorValue
{
    return [UIColor colorWithHue:_hue / 360.0 saturation:_saturation brightness:_brightness alpha:_alpha];
}

- (PXHSBColorValue *)hsbColorValue
{
    return self;
}

#pragma mark - Overrides

- (NSString *)description
{
    return [NSString stringWithFormat:@"hsba(%g,%g,%g,%g)", _hue, _saturation, _brightness, _alpha];
}

@end
