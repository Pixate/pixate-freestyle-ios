//
//  PXRGBColorValue.h
//  pixate-freestyle
//
//  Created by Kevin Lindsey on 4/17/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "PXExpressionColorBase.h"

@interface PXRGBColorValue : PXExpressionColorBase

@property (nonatomic, readonly) double red;
@property (nonatomic, readonly) double green;
@property (nonatomic, readonly) double blue;
@property (nonatomic, readonly) double alpha;

- (id)initWithRed:(double)red green:(double)green blue:(double)blue;
- (id)initWithRed:(double)red green:(double)green blue:(double)blue alpha:(double)alpha;

@end
