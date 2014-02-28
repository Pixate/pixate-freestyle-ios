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
//  PXCircle.h
//  Pixate
//
//  Created by Kevin Lindsey on 5/31/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXShape.h"

/**
 *  A PXShape sub-class used to render circles
 */
@interface PXCircle : PXShape

/**
 *  A point indicating the location of the center of this circle.
 */
@property (nonatomic) CGPoint center;

/**
 *  A value indicating the size of the radius of this circle.
 *
 *  This value may be negative, but it will be normalized to a positive value.
 */
@property (nonatomic) CGFloat radius;

/**
 *  Allocates and initializes a new circle using the specified center location and radius
 *
 *  @param center The center point of the circle
 *  @param radius The radius of the circle
 */
+ (id)circleWithCenter:(CGPoint)center withRadius:(CGFloat)radius;

/**
 *  Initializes a newly allocated circle using the specified center location and radius
 *
 *  @param center The center point of the circle
 *  @param radius The radius of the circle
 */
- (id)initCenter:(CGPoint)center radius:(CGFloat)radius;

@end
