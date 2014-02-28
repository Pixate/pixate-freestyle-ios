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
//  PXRectangle.h
//  Pixate
//
//  Created by Kevin Lindsey on 5/30/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXShape.h"
#import "PXBoundable.h"

/**
 *  A PXShape sub-class used to render rectangles
 */
@interface PXRectangle : PXShape <PXBoundable>

/**
 *  The size (width and height) of this rectangle
 */
@property (nonatomic) CGSize size;

/**
 *  The x-coordinate of the top-left corner of this rectangle
 */
@property (nonatomic) CGFloat x;

/**
 *  The y-coordinate of the top-left corner of this rectangle
 */
@property (nonatomic) CGFloat y;

/**
 *  The width of this rectangle
 */
@property (nonatomic) CGFloat width;

/**
 *  The height of this rectangle
 */
@property (nonatomic) CGFloat height;

/**
 *  The radii of the top-left corner of this rectangle
 */
@property (nonatomic) CGSize radiusTopLeft;

/**
 *  The radii of the top-right corner of this rectangle
 */
@property (nonatomic) CGSize radiusTopRight;

/**
 *  The radii of the bottom-right corner of this rectangle
 */
@property (nonatomic) CGSize radiusBottomRight;

/**
 *  The radii of the bottom-left corner of this rectangle
 */
@property (nonatomic) CGSize radiusBottomLeft;

/**
 *  Initializes a newly allocated rectangle using the specified bounds
 *
 *  @param bounds The bounds point of the rectangle
 */
- (id)initWithRect:(CGRect)bounds;

/**
 *  Determine if any of the corners of this rectangle rounded
 */
- (BOOL)hasRoundedCorners;

/**
 *  Set the corner radius of all corners to the specified value
 *
 *  @param radius A corner radius
 */
- (void)setCornerRadius:(CGFloat)radius;

/**
 *  Set the corner radius of all corners to the specified value
 *
 *  @param radii The x and y radii
 */
- (void)setCornerRadii:(CGSize)radii;

@end
