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
//  PXPath.h
//  Pixate
//
//  Created by Kevin Lindsey on 5/31/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXShape.h"

/**
 *  A PXShape sub-class used to render paths
 */
@interface PXPath : PXShape

/**
 *  Generate a new PXPath instance using the specified data
 *
 *  This method parses the specifying data, generating calls to the path building methods in this class. The data is
 *  expected to be in the form as defined by the SVG 1.1 specification for the path data's d attribute.
 *
 *  @param data A string of path data
 *  @returns A newly allocated PXPath instance
 */
+ (PXPath *)createPathFromPathData:(NSString *)data;

/**
 *  Add a close command to the current path
 */
- (void)close;

/**
 *  Add a lineto command to the current path
 *
 *  @param x The x-coordinate of the line being added
 *  @param y The y-coordinate of the line being added
 */
- (void)lineToX:(CGFloat)x y:(CGFloat) y;

/**
 *  Add a moveto command to the current path
 *
 *  @param x The x-coordinate of the new position to move to within this path
 *  @param y The y-coordinate of the new position to move to within this path
 */
- (void)moveToX:(CGFloat)x y:(CGFloat) y;

/**
 *  Add a curveto command to the current path
 *
 *  @param x1 The x-coordinate of the first handle of the cubic bezier curve being added
 *  @param y1 The y-coordinate of the first handle of the cubic bezier curve being added
 *  @param x2 The x-coordinate of the second handle of the cubic bezier curve being added
 *  @param y2 The y-coordinate of the second handle of the cubic bezier curve being added
 *  @param x3 The x-coordinate of the third handle of the cubic bezier curve being added
 *  @param y3 The y-coordinate of the third handle of the cubic bezier curve being added
 */
- (void)cubicBezierToX1:(CGFloat)x1 y1:(CGFloat)y1 x2:(CGFloat)x2 y2:(CGFloat)y2 x3:(CGFloat)x3 y3:(CGFloat)y3;

/**
 *  Add a qcurveto command to the current path
 *
 *  @param x1 The x-coordinate of the first handle of the quadratic bezier curve being added
 *  @param y1 The y-coordinate of the first handle of the quadratic bezier curve being added
 *  @param x2 The x-coordinate of the second handle of the quadratic bezier curve being added
 *  @param y2 The y-coordinate of the second handle of the quadratic bezier curve being added
 */
- (void)quadraticBezierToX1:(CGFloat)x1 y1:(CGFloat)y1 x2:(CGFloat)x2 y2:(CGFloat)y2;

/**
 *  Add an arc of an ellipse to the current path
 *
 *  @param x The x-coordinate of the center of the ellipse
 *  @param y The y-coordinate of the center of the ellipse
 *  @param radiusX The x-radius of the ellipse
 *  @param radiusY The y-radius of the ellipse
 *  @param startAngle The starting angle of the arc
 *  @param endAngle The ending angle of the arc
 */
- (void)ellipticalArcX:(CGFloat)x y:(CGFloat)y radiusX:(CGFloat)radiusX radiusY:(CGFloat)radiusY startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle;

@end
