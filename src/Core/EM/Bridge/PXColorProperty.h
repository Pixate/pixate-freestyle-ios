//
//  PXColorProperty.h
//  pixate-freestyle
//
//  Created by Kevin Lindsey on 4/17/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "PXExpressionProperty.h"

@interface PXColorProperty : NSObject <PXExpressionProperty>

- (UIColor *)getWithObject:(id)object;
- (void)setValue:(UIColor *)value withObject:(id)object;

@end
