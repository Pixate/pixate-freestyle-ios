//
//  PXColorValueProperty.h
//  pixate-freestyle
//
//  Created by Kevin Lindsey on 4/17/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "PXExpressionProperty.h"
#import "PXExpressionColor.h"

@interface PXColorValueProperty : NSObject <PXExpressionProperty>

- (id)initWithInstance:(id)instance getterName:(NSString *)getterName setterName:(NSString *)setterName;
- (id)initWithInstance:(id)instance getterSelector:(SEL)getterSelector setterSelector:(SEL)setterSelector;

- (id<PXExpressionColor>)getWithObject:(id)object;
- (void)setValue:(id<PXExpressionColor>)value withObject:(id)object;

@end
