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
//  PXValue.h
//  Pixate
//
//  Created by Kevin Lindsey on 1/23/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PixateFreestyleConfiguration.h"
#import "PXBorderInfo.h"

typedef enum {
    PXValueType_CGRect,
    PXValueType_CGSize,
    PXValueType_CGFloat,
    PXValueType_CGAffineTransform,
    PXValueType_UIEdgeInsets,
    PXValueType_NSTextAlignment,
    PXValueType_NSLineBreakMode,
    PXValueType_Boolean,
    PXValueType_PXParseErrorDestination,
    PXValueType_PXCacheStylesType,
    PXValueType_UITextBorderStyle,
    PXValueType_CGColorRef,
    PXValueType_PXBorderStyle,
} PXValueType;

@interface PXValue : NSObject

@property (nonatomic, readonly) PXValueType type;

- (id)initWithBytes:(const void *)value type:(PXValueType)type;

- (CGRect)CGRectValue;
- (CGSize)CGSizeValue;
- (CGFloat)CGFloatValue;
- (CGAffineTransform)CGAffineTransformValue;
- (UIEdgeInsets)UIEdgeInsetsValue;
- (NSTextAlignment)NSTextAlignmentValue;
- (NSLineBreakMode)NSLineBreakModeValue;
- (BOOL)BooleanValue;
- (PXParseErrorDestination)PXParseErrorDestinationValue;
- (PXCacheStylesType)PXCacheStylesTypeValue;
- (UITextBorderStyle)UITextBorderStyleValue;
- (CGColorRef)CGColorRefValue;
- (PXBorderStyle)PXBorderStyleValue;

@end
