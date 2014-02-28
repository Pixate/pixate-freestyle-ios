/*
 * Copyright 2012-present Pixate, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  NSDictionary+PXObject.m
//  Pixate
//
//  Created by Kevin Lindsey on 3/26/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "NSDictionary+PXObject.h"
#import "PXValue.h"

void PXForceLoadNSDictionaryPXObject() {}

@implementation NSDictionary (PXObject)

- (id)nilableObjectForKey:(id)key
{
    id object = [self objectForKey:key];

    return (object == [NSNull null]) ? nil : object;
}

- (CGRect)rectForKey:(id)key
{
    id object = [self objectForKey:key];

    if ([object isKindOfClass:[PXValue class]])
    {
        PXValue *value = object;

        return [value CGRectValue];
    }
    else
    {
        return CGRectZero;
    }
}

- (CGFloat)floatForKey:(id)key
{
    id object = [self objectForKey:key];

    if ([object isKindOfClass:[PXValue class]])
    {
        PXValue *value = object;

        return [value CGFloatValue];
    }
    else
    {
        return 0.0f;
    }
}

- (CGColorRef)colorRefForKey:(id)key
{
    id object = [self objectForKey:key];

    if ([object isKindOfClass:[PXValue class]])
    {
        PXValue *value = object;

        return [value CGColorRefValue];
    }
    else
    {
        // TODO: is this a reaonsable default value?
        return [UIColor blackColor].CGColor;
    }
}

- (CGSize)sizeForKey:(id)key
{
    id object = [self objectForKey:key];

    if ([object isKindOfClass:[PXValue class]])
    {
        PXValue *value = object;

        return [value CGSizeValue];
    }
    else
    {
        return CGSizeZero;
    }
}

- (BOOL)booleanForKey:(id)key
{
    id object = [self objectForKey:key];

    if ([object isKindOfClass:[PXValue class]])
    {
        PXValue *value = object;

        return [value BooleanValue];
    }
    else
    {
        return NO;
    }
}

- (CGAffineTransform)transformForKey:(id)key
{
    id object = [self objectForKey:key];

    if ([object isKindOfClass:[PXValue class]])
    {
        PXValue *value = object;

        return [value CGAffineTransformValue];
    }
    else
    {
        return CGAffineTransformIdentity;
    }
}

- (UIEdgeInsets)insetsForKey:(id)key
{
    id object = [self objectForKey:key];

    if ([object isKindOfClass:[PXValue class]])
    {
        PXValue *value = object;

        return [value UIEdgeInsetsValue];
    }
    else
    {
        return UIEdgeInsetsZero;
    }
}

- (NSLineBreakMode)lineBreakModeForKey:(id)key
{
    id object = [self objectForKey:key];

    if ([object isKindOfClass:[PXValue class]])
    {
        PXValue *value = object;

        return [value NSLineBreakModeValue];
    }
    else
    {
        return NSLineBreakByTruncatingMiddle;
    }
}

- (NSTextAlignment)textAlignmentForKey:(id)key
{
    id object = [self objectForKey:key];
    
    if ([object isKindOfClass:[PXValue class]])
    {
        PXValue *value = object;
        
        return [value NSTextAlignmentValue];
    }
    else
    {
        return NSTextAlignmentLeft;
    }
    
}

@end
