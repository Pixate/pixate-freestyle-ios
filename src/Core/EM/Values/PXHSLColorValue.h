//
//  PXHSLColorValue.h
//  pixate-freestyle
//
//  Created by Kevin Lindsey on 4/17/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "PXExpressionColorBase.h"

@interface PXHSLColorValue : PXExpressionColorBase

@property (nonatomic, readonly) double hue;
@property (nonatomic, readonly) double saturation;
@property (nonatomic, readonly) double lightness;
@property (nonatomic, readonly) double alpha;

- (id)initWithHue:(double)hue saturation:(double)saturation lightness:(double)lightness;
- (id)initWithHue:(double)hue saturation:(double)saturation lightness:(double)lightness alpha:(double)alpha;

@end
