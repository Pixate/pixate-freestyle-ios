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
//  PXVector.h
//  Pixate
//
//  Created by Kevin Lindsey on 7/27/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  PXVector implements some commonly used vector operations
 */
@interface PXVector : NSObject

/**
 *  The x-component of this vector
 */
@property (readonly, nonatomic) CGFloat x;

/**
 *  The y-component of this vector
 */
@property (readonly, nonatomic) CGFloat y;

/**
 *  The angle of this vector
 */
@property (readonly, nonatomic) CGFloat angle;

/**
 *  The length of this vector
 */
@property (readonly, nonatomic) CGFloat length;

/**
 *  The magnitude (length^2) of this vector
 */
@property (readonly, nonatomic) CGFloat magnitude;

/**
 *  Returns a vector perpendicular to this one
 */
@property (readonly, nonatomic) PXVector *perp;

/**
 *  Returns the unit vector of this vector
 */
@property (readonly, nonatomic) PXVector *unit;

/**
 *  Allocate and initialize a new instance using the specified components
 *
 *  @param x The x-component of this vector
 *  @param y The y-component of this vector
 */
+ (id)vectorWithX:(CGFloat)x Y:(CGFloat)y;

/**
 *  Allocate and initialize a new instance as specified by two end points of a line segment
 *
 *  @param p1 The starting point of the vector
 *  @param p2 The ending point of the vector
 */
+ (id)vectorWithStartPoint:(CGPoint)p1 EndPoint:(CGPoint)p2;

/**
 *  Initialize a new instance
 *
 *  @param x The x-component of this vector
 *  @param y The y-component of this vector
 */
- (id)initWithX:(CGFloat)x Y:(CGFloat)y;

/**
 *  Find the angle between two vectors
 *
 *  @param vector The vector used to find the resulting angle
 */
- (CGFloat)angleBetweenVector:(PXVector *)vector;

/**
 *  Find the dot product of two vectors
 *
 *  @param vector The vector to use against this vector
 */
- (CGFloat)dot:(PXVector *)vector;

/**
 *  Find the cross product of two vectors
 *
 *  @param vector The vector to use against this vector
 */
- (CGFloat)cross:(PXVector *)vector;

/**
 *  Add two vectors, generating a new third vector
 *
 *  @param vector The vector to add to this one
 */
- (PXVector *)add:(PXVector *)vector;

/**
 *  Subtract two vectors, generating a new third vector
 *
 *  @param vector The vector to subtract from this one
 */
- (PXVector *)subtract:(PXVector *)vector;

/**
 *  Divide a vector by a scalar value, returning a new vector
 *
 *  @param scalar The scalar value to apply to this vector
 */
- (PXVector *)divide:(CGFloat)scalar;

/**
 *  Multiply a vector by a scale value, returning a new vector
 *
 *  @param scalar The scalar value to apply to this vector
 */
- (PXVector *)multiply:(CGFloat)scalar;

/**
 *  Find the vector that is the projection of this vector onto the specified vector's normal
 *
 *  @param vector The vector to use for calculating the normal vector
 */
- (PXVector *)perpendicular:(PXVector *)vector;

/**
 *  Project this vector onto another, returning a new third vector
 *
 *  @param vector The vector to project onto
 */
- (PXVector *)projectOnto:(PXVector *)vector;

@end
