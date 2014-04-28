//
//  PXHSLFunction.m
//  pixate-freestyle
//
//  Created by Kevin Lindsey on 4/18/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "PXHSLFunction.h"
#import "PXHSLColorValue.h"

@implementation PXHSLFunction

- (void)invokeWithEnvironment:(PXExpressionEnvironment *)env
             invocationObject:(id<PXExpressionValue>)invocationObject
                         args:(id<PXExpressionArray>)args
{
    double hue        = (args.length > 0) ? ([args valueForIndex:0]).doubleValue : 0.0;
    double saturation = (args.length > 1) ? ([args valueForIndex:1]).doubleValue : 0.0;
    double lightness  = (args.length > 2) ? ([args valueForIndex:2]).doubleValue : 0.0;
    double alpha      = 1.0;

    PXHSLColorValue *color = [[PXHSLColorValue alloc] initWithHue:hue saturation:saturation lightness:lightness alpha:alpha];

    [env pushValue:color];
}

@end
