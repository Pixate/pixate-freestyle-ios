//
//  PXRGBAFunction.m
//  pixate-freestyle
//
//  Created by Kevin Lindsey on 4/18/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "PXRGBAFunction.h"
#import "PXRGBColorValue.h"

@implementation PXRGBAFunction

- (void)invokeWithEnvironment:(PXExpressionEnvironment *)env
             invocationObject:(id<PXExpressionValue>)invocationObject
                         args:(id<PXExpressionArray>)args
{
    double red   = (args.length > 0) ? ([args valueForIndex:0]).doubleValue : 0.0;
    double green = (args.length > 1) ? ([args valueForIndex:1]).doubleValue : 0.0;
    double blue  = (args.length > 2) ? ([args valueForIndex:2]).doubleValue : 0.0;
    double alpha = (args.length > 3) ? ([args valueForIndex:3]).doubleValue : 1.0;

    PXRGBColorValue *color = [[PXRGBColorValue alloc] initWithRed:red green:green blue:blue alpha:alpha];

    [env pushValue:color];
}

@end
