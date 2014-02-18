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
//  PXEllipse.h
//  Pixate
//
//  Created by Kevin Lindsey on 6/6/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXShape.h"
#import "PXBoundable.h"

/**
 *  A PXShape sub-class used to render ellipses
 */
@interface PXEllipse : PXShape <PXBoundable>

/**
 *  A point indicating the location of the center of this ellipse.
 */
@property (nonatomic) CGPoint center;

/**
 *  A value indicating the size of the x-radius of this ellipse.
 *
 *  This value may be negative, but it will be normalized to a positive value.
 */
@property (nonatomic) CGFloat radiusX;

/**
 *  A value indicating the size of the y-radius of this ellipse.
 *
 *  This value may be negative, but it will be normalized to a positive value.
 */
@property (nonatomic) CGFloat radiusY;

/**
 *  Allocates and initializes a new ellipse using the specified center location and radii
 *
 *  @param center The center point of the ellipse
 *  @param radiusX The x-radius of the ellipse
 *  @param radiusY The y-radius of the ellipse
 */
+ (id)ellipseWithCenter:(CGPoint)center withRadiusX:(CGFloat)radiusX withRadiusY:(CGFloat)radiusY;

/**
 *  Initializes a newly allocated ellipse using the specified center location and radii
 *
 *  @param center The center point of the ellipse
 *  @param radiusX The x-radius of the ellipse
 *  @param radiusY The y-radius of the ellipse
 */
- (id)initCenter:(CGPoint)center radiusX:(CGFloat)radiusX radiusY:(CGFloat)radiusY;

@end
