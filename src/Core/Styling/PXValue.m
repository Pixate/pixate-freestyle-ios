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
//  PXValue.m
//  Pixate
//
//  Created by Kevin Lindsey on 1/23/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXValue.h"

@implementation PXValue
{
    NSValue *value_;
}

- (id)initWithBytes:(const void *)value type:(PXValueType)type
{
    if (self = [super init])
    {
        _type = type;

        switch (type)
        {
            case PXValueType_CGRect:
                value_ = [[NSValue alloc] initWithBytes:value objCType:@encode(CGRect)];
                break;

            case PXValueType_CGSize:
                value_ = [[NSValue alloc] initWithBytes:value objCType:@encode(CGSize)];
                break;

            case PXValueType_CGFloat:
                value_ = [[NSValue alloc] initWithBytes:value objCType:@encode(CGFloat)];
                break;

            case PXValueType_CGAffineTransform:
                value_ = [[NSValue alloc] initWithBytes:value objCType:@encode(CGAffineTransform)];
                break;

            case PXValueType_UIEdgeInsets:
                value_ = [[NSValue alloc] initWithBytes:value objCType:@encode(UIEdgeInsets)];
                break;

            case PXValueType_NSTextAlignment:
                value_ = [[NSValue alloc] initWithBytes:value objCType:@encode(NSTextAlignment)];
                break;

            case PXValueType_NSLineBreakMode:
                value_ = [[NSValue alloc] initWithBytes:value objCType:@encode(NSLineBreakMode)];
                break;

            case PXValueType_Boolean:
                value_ = [[NSValue alloc] initWithBytes:value objCType:@encode(BOOL)];
                break;

            case PXValueType_PXParseErrorDestination:
                value_ = [[NSValue alloc] initWithBytes:value objCType:@encode(PXParseErrorDestination)];
                break;

            case PXValueType_PXCacheStylesType:
                value_ = [[NSValue alloc] initWithBytes:value objCType:@encode(PXCacheStylesType)];
                break;

            case PXValueType_UITextBorderStyle:
                value_ = [[NSValue alloc] initWithBytes:value objCType:@encode(UITextBorderStyle)];
                break;

            case PXValueType_CGColorRef:
                value_ = [[NSValue alloc] initWithBytes:value objCType:@encode(CGColorRef)];
                break;

            case PXValueType_PXBorderStyle:
                value_ = [[NSValue alloc] initWithBytes:value objCType:@encode(PXBorderStyle)];
                break;

            default:
                break;
        }
    }

    return self;
}

- (CGRect)CGRectValue
{
    return (_type == PXValueType_CGRect) ? [value_ CGRectValue] : CGRectZero;
}

- (CGSize)CGSizeValue
{
    return (_type == PXValueType_CGSize) ? [value_ CGSizeValue] : CGSizeZero;
}

- (CGFloat)CGFloatValue
{
    CGFloat result = 0.0f;

    if (_type == PXValueType_CGFloat)
    {
        [value_ getValue:&result];
    }

    return result;
}

- (CGAffineTransform)CGAffineTransformValue
{
    CGAffineTransform result = CGAffineTransformIdentity;

    if (_type == PXValueType_CGAffineTransform)
    {
        [value_ getValue:&result];
    }

    return result;
}

- (UIEdgeInsets)UIEdgeInsetsValue
{
    UIEdgeInsets result = UIEdgeInsetsZero;

    if (_type == PXValueType_UIEdgeInsets)
    {
        [value_ getValue:&result];
    }

    return result;
}

- (NSTextAlignment)NSTextAlignmentValue
{
    NSTextAlignment result = NSTextAlignmentCenter;

    if (_type == PXValueType_NSTextAlignment)
    {
        [value_ getValue:&result];
    }

    return result;
}

- (NSLineBreakMode)NSLineBreakModeValue
{
    NSLineBreakMode result = NSLineBreakByTruncatingMiddle;

    if (_type == PXValueType_NSLineBreakMode)
    {
        [value_ getValue:&result];
    }

    return result;
}

- (BOOL)BooleanValue
{
    BOOL result = NO;

    if (_type == PXValueType_Boolean)
    {
        [value_ getValue:&result];
    }

    return result;
}

- (PXParseErrorDestination)PXParseErrorDestinationValue
{
    PXParseErrorDestination result = PXParseErrorDestinationNone;

    if (_type == PXValueType_PXParseErrorDestination)
    {
        [value_ getValue:&result];
    }

    return result;
}

- (PXCacheStylesType)PXCacheStylesTypeValue
{
    PXCacheStylesType result = PXCacheStylesTypeNone;

    if (_type == PXValueType_PXCacheStylesType)
    {
        [value_ getValue:&result];
    }

    return result;
}

- (UITextBorderStyle)UITextBorderStyleValue
{
    UITextBorderStyle result = UITextBorderStyleNone;

    if (_type == PXValueType_UITextBorderStyle)
    {
        [value_ getValue:&result];
    }

    return result;
}

- (CGColorRef)CGColorRefValue
{
    CGColorRef result;

    if (_type == PXValueType_CGColorRef)
    {
        [value_ getValue:&result];
    }
    else
    {
        // TODO: Is this a reasonable default value?
        result = [UIColor blackColor].CGColor;
    }

    return result;
}

- (PXBorderStyle)PXBorderStyleValue
{
    PXBorderStyle result = PXBorderStyleNone;

    if (_type == PXValueType_PXBorderStyle)
    {
        [value_ getValue:&result];
    }

    return result;
}

@end
