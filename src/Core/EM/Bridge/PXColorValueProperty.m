//
//  PXColorValueProperty.m
//  pixate-freestyle
//
//  Created by Kevin Lindsey on 4/17/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "PXColorValueProperty.h"
#import "PXUndefinedValue.h"

typedef id<PXExpressionColor> (*ColorValueGetterImp)(id object, SEL selector);
typedef void (*ColorValueSetterImp)(id object, SEL selector, id<PXExpressionColor> value);

@interface PXColorValueProperty ()
@property (nonatomic) SEL getterSelector;
@property (nonatomic) ColorValueGetterImp getterImp;
@property (nonatomic) SEL setterSelector;
@property (nonatomic) ColorValueSetterImp setterImp;
@end

@implementation PXColorValueProperty

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
            _getterImp = (ColorValueGetterImp) [instance methodForSelector:_getterSelector];
        }

        if (_setterSelector != NULL && [instance respondsToSelector:_setterSelector])
        {
            _setterImp = (ColorValueSetterImp) [instance methodForSelector:_setterSelector];
        }
    }

    return self;
}

#pragma mark - Methods

- (id<PXExpressionColor>)getWithObject:(id)object
{
    return (_getterImp) ? (*_getterImp)(object, _getterSelector) : nil;
}

- (void)setValue:(id<PXExpressionColor>)value withObject:(id)object
{
    if (_setterImp)
    {
        (*_setterImp)(object, _setterSelector, value);
    }
}

#pragma mark - PXExpressionProperty Implementation

- (id<PXExpressionValue>)getExpressionValueFromObject:(id)object
{
    return (_getterImp) ? (*_getterImp)(object, _getterSelector) : [PXUndefinedValue undefined];
}

- (void)setExpressionValue:(id<PXExpressionValue>)value onObject:(id)object
{
    if (_setterImp && [value conformsToProtocol:@protocol(PXExpressionColor)])
    {
        id<PXExpressionColor> color = (id<PXExpressionColor>)value;

        (*_setterImp)(object, _setterSelector, color);
    }
}

@end
