//
//  PXExpressionColorBase.m
//  pixate-freestyle
//
//  Created by Kevin Lindsey on 4/17/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "PXExpressionColorBase.h"

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

- (UIColor *)colorValue
{
    return [UIColor blackColor];
}

@end
