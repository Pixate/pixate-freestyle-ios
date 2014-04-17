//
//  PXExpressionColor.h
//  pixate-freestyle
//
//  Created by Kevin Lindsey on 4/17/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "PXExpressionValue.h"

@protocol PXExpressionColor <PXExpressionValue>

- (id)initWithColor:(UIColor *)color;

- (UIColor *)colorValue;

@end
