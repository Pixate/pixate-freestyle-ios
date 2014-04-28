//
//  PXExpressionColorBase.m
//  pixate-freestyle
//
//  Created by Kevin Lindsey on 4/17/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "PXExpressionColorBase.h"
#import "PXHSBColorValue.h"
#import "PXHSLColorValue.h"
#import "PXRGBColorValue.h"
#import "PXExpressionProperty.h"
#import "PXDoubleProperty.h"

@interface PXExpressionColorBase ()
@property (nonatomic, strong) NSMutableDictionary *properties;
@end

@implementation PXExpressionColorBase

- (id)init
{
    return [super initWithValueType:PX_VALUE_TYPE_OBJECT];
}

- (id)initWithColor:(UIColor *)color
{
    if (self = [self init])
    {
        // subclasses are responsible for implementing this initializer
    }

    return self;
}

#pragma mark - Method

- (void)addDoublePropertyForName:(NSString *)name
{
    if (name.length > 0)
    {
        NSString *getterName = name;
        NSString *setterName = [NSString stringWithFormat:@"set%@%@:", [[name substringToIndex:1] uppercaseString], [name substringFromIndex:1]];
        SEL getter = NSSelectorFromString(getterName);
        SEL setter = NSSelectorFromString(setterName);

        PXDoubleProperty *property = [[PXDoubleProperty alloc] initWithInstance:self getterSelector:getter setterSelector:setter];

        [self addProperty:property forName:name];
    }
}

- (void)addProperty:(id<PXExpressionProperty>)property forName:(NSString *)name
{
    if (property != nil && name.length > 0)
    {
        if (_properties == nil)
        {
            _properties = [[NSMutableDictionary alloc] init];
        }

        [_properties setObject:property forKey:name];
    }
}

#pragma mark - PXExpressionObject Implementation

- (uint)length
{
    return (uint)_properties.count;
}

- (NSArray *)propertyNames
{
    return [_properties allKeys];
}

- (NSArray *)propertyValues
{
    NSMutableArray *result = [[NSMutableArray alloc] init];

    [self.propertyNames enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        [result addObject:[self valueForPropertyName:key]];
    }];

    return [result copy];
}

- (id<PXExpressionValue>)valueForPropertyName:(NSString *)name
{
    id<PXExpressionProperty> property = [_properties objectForKey:name];

    return [property getExpressionValueFromObject:self];
}

- (void)setValue:(id<PXExpressionValue>)value forPropertyName:(NSString *)name
{
    id<PXExpressionProperty> property = [_properties objectForKey:name];

    [property setExpressionValue:value onObject:self];
}

#pragma mark - PXExpressionColor Implementation

- (PXHSBColorValue *)hsbColorValue
{
    return [[PXHSBColorValue alloc] initWithColor:[self colorValue]];
}

- (PXHSLColorValue *)hslColorValue
{
    return [[PXHSLColorValue alloc] initWithColor:[self colorValue]];
}

- (PXRGBColorValue *)rgbColorValue
{
    return [[PXRGBColorValue alloc] initWithColor:[self colorValue]];
}

- (UIColor *)colorValue
{
    return [UIColor blackColor];
}

- (id<PXExpressionColor>)convertColor:(id<PXExpressionColor>)color
{
    if ([self class] == [color class])
    {
        return color;
    }
    else
    {
        id<PXExpressionColor> result = [[self class] alloc];

        return [result initWithColor:[color colorValue]];
    }
}

@end
