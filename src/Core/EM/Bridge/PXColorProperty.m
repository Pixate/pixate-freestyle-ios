//
//  PXColorProperty.m
//  pixate-freestyle
//
//  Created by Kevin Lindsey on 4/17/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "PXColorProperty.h"
#import "PXUndefinedValue.h"
#import "PXRGBColorValue.h"

typedef UIColor * (*ColorGetterImp)(id object, SEL selector);
typedef void (*ColorSetterImp)(id object, SEL selector, UIColor *value);

@interface PXColorProperty ()
@property (nonatomic) SEL getterSelector;
@property (nonatomic) ColorGetterImp getterImp;
@property (nonatomic) SEL setterSelector;
@property (nonatomic) ColorSetterImp setterImp;
@end

@implementation PXColorProperty

#pragma mark - Initializers

- (id)initWithInstance:(id)instance getterName:(NSString *)getterName setterName:(NSString *)setterName
{
    return [self initWithInstance:instance
                   getterSelector:NSSelectorFromString(getterName)
                   setterSelector:NSSelectorFromString(setterName)];
}

- (id)initWithInstance:(id)instance getterSelector:(SEL)getterSelector setterSelector:(SEL)setterSelector
{
    if (self = [super init])
    {
        _getterSelector = getterSelector;
        _setterSelector = setterSelector;

        if (_getterSelector != NULL && [instance respondsToSelector:_getterSelector])
        {
            _getterImp = (ColorGetterImp) [instance methodForSelector:_getterSelector];
        }

        if (_setterSelector != NULL && [instance respondsToSelector:_setterSelector])
        {
            _setterImp = (ColorSetterImp) [instance methodForSelector:_setterSelector];
        }
    }

    return self;
}

#pragma mark - Methods

- (UIColor *)getWithObject:(id)object
{
    return (_getterImp) ? (*_getterImp)(object, _getterSelector) : nil;
}

- (void)setValue:(UIColor *)value withObject:(id)object
{
    if (_setterImp)
    {
        (*_setterImp)(object, _setterSelector, value);
    }
}

#pragma mark - PXExpressionProperty Implementation

- (id<PXExpressionValue>)getExpressionValueFromObject:(id)object
{
    UIColor *result = (_getterImp) ? (*_getterImp)(object, _getterSelector) : [UIColor blackColor];

    return [[PXRGBColorValue alloc] initWithColor:result];
}

- (void)setExpressionValue:(id<PXExpressionValue>)value onObject:(id)object
{
    if (_setterImp && [value conformsToProtocol:@protocol(PXExpressionColor)])
    {
        id<PXExpressionColor> color = (id<PXExpressionColor>)value;

        (*_setterImp)(object, _setterSelector, color.colorValue);
    }
}

@end
