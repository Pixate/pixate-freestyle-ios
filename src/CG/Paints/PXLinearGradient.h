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
//  PXLinearGradient.h
//  Pixate
//
//  Created by Kevin Lindsey on 6/8/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXPaint.h"
#import "PXGradient.h"

typedef enum {
    PXLinearGradientDirectionToTop,
    PXLinearGradientDirectionToTopRight,
    PXLinearGradientDirectionToRight,
    PXLinearGradientDirectionToBottomRight,
    PXLinearGradientDirectionToBottom,
    PXLinearGradientDirectionToBottomLeft,
    PXLinearGradientDirectionToLeft,
    PXLinearGradientDirectionToTopLeft
} PXLinearGradientDirection;

/**
 *  PXLinearGradient is an implementation of a linear gradient. Linear gradients may be specified by an angle, or by two
 *  user-defined points.
 */
@interface PXLinearGradient : PXGradient

/**
 *  The angle to be used when calculating the rendering of this gradient. Note that setting this value overrides any
 *  values set using points or gradient directions.
 */
@property (nonatomic) CGFloat angle;

/**
 *  Angles in iOS and CSS differ. This is a convenience property that allows angles to follow the CSS specification's
 *  definition of an angle. Note that setting this value overrides any values set using points or gradient directions.
 */
@property (nonatomic) CGFloat cssAngle;

/**
 *  Angles in iOS and Photoshop differ. This is a convenience property that allows angles to follow Photoshop's
 *  definition of an angle. Note that setting this value overrides any values set using points or gradient directions.
 */
@property (nonatomic) CGFloat psAngle;

/**
 *  The first point in the gradient. Note that setting this point overrides any values set by angle or gradient
 *  direction.
 */
@property (nonatomic) CGPoint p1;

/**
 *  The last point in the gradient. Note that setting this point overrides any values set by angle or gradient
 *  direction.
 */
@property (nonatomic) CGPoint p2;

/**
 *  Specify a direction for the gradient. Note that setting this point overrides any vluaes set by points or angle.
 */
@property (nonatomic) PXLinearGradientDirection gradientDirection;

/**
 *  Allocate and initialize a new linear gradient using the specified starting and ending colors
 *
 *  @param startColor The starting color of this gradient
 *  @param endColor The ending color of this gradient
 */
+ (PXLinearGradient *)gradientFromStartColor:(UIColor *)startColor endColor:(UIColor *)endColor;

@end
