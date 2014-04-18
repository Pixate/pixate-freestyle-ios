//
//  PXPropertyTestClass.m
//  pixate-freestyle
//
//  Created by Kevin Lindsey on 4/18/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "PXPropertyTestClass.h"
#import "PXHSBColorValue.h"

@implementation PXPropertyTestClass

@synthesize color = _color;
@synthesize pxColor = _pxColor;

- (id)init
{
    if (self = [super init])
    {
        _color = [UIColor redColor];
        _pxColor = [[PXHSBColorValue alloc] initWithHue:180 saturation:0.5 brightness:0.75];
    }

    return self;
}

@end
