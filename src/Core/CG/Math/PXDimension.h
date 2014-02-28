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
//  PXDimension.h
//  Pixate
//
//  Created by Kevin Lindsey on 7/7/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  An enumeration indicating a dimension type
 */
typedef enum
{
    kDimensionTypeEms,
    kDimensionTypeExs,
    kDimensionTypePixels,
    kDimensionTypeDevicePixels,
    kDimensionTypeCentimeters,
    kDimensionTypeMillimeters,
    kDimensionTypeInches,
    kDimensionTypePoints,
    kDimensionTypePicas,
    kDimensionTypeDegrees,
    kDimensionTypeRadians,
    kDimensionTypeGradians,
    kDimensionTypeMilliseconds,
    kDimensionTypeSeconds,
    kDimensionTypeHertz,
    kDimensionTypeKilohertz,
    kDimensionTypePercentage,
    kDimensionTypeUserDefined,
} PXDimensionType;

/**
 *  PXDimension is used to associate a dimensions with a float. Methods are included to inquire into the general
 *  category of the dimension (length, angle, time, etc.). Some conversions between dimensions is included.
 */
@interface PXDimension : NSObject

/**
 *  The scalar value of this dimension
 */
@property (readonly, nonatomic) CGFloat number;

/**
 *  The string value of the dimension. This is used for user-defined types.
 */
@property (readonly, nonatomic, strong) NSString *dimension;

/**
 *  The dimension type of this dimension as defined in the PXSSDimensionType enumeration. If this value is
 *  kDimensionTypeUserDefined, then dimension will be defined, incidating the string value used when creating this
 *  instance.
 */
@property (readonly, nonatomic) PXDimensionType type;

/**
 *  Allocate and initialize a new PXDimension using the given number and dimension
 *
 *  @param number The dimension's scalar value
 *  @param dimension The dimension units as a string
 */
+ (id)dimensionWithNumber:(CGFloat)number withDimension:(NSString *)dimension;

/**
 *  Initialize a new instance
 *
 *  @param number The dimension's scalar value
 *  @param dimension The dimension units as a string
 */
- (id)initWithNumber:(CGFloat)number withDimension:(NSString *)dimension;

/**
 *  A predicate indicating if this is a length value
 */
- (BOOL)isLength;

/**
 *  A predicate indicating if this is a angle value
 */
- (BOOL)isAngle;

/**
 *  A predicate indicating if this is a time value
 */
- (BOOL)isTime;

/**
 *  A predicate indicating if this is a frequency value
 */
- (BOOL)isFrequency;

/**
 *  A predicate indicating if this is a percentage
 */
- (BOOL)isPercentage;

/**
 *  A predicate indicating if this is a user-defined value
 */
- (BOOL)isUserDefined;

/**
 *  Return a new PXDimension, converting this instance's value to points. If this instance is not a length, then a zero
 *  value will be returned.
 */
- (PXDimension *)points;

/**
 *  Return a new PXDimension, converting this instance's value to degrees. If this instance is not an angle, then a zero
 *  value will be returned.
 */
- (PXDimension *)degrees;

/**
 *  Return a new PXDimesion, converting this instance's value to radians. If this instance is not an angle, then a zero
 *  value will be returned.
 */
- (PXDimension *)radians;



@end
