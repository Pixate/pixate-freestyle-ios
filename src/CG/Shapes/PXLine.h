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
//  PXLine.h
//  Pixate
//
//  Created by Kevin Lindsey on 6/6/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXShape.h"

/**
 *  A PXShape sub-class used to render lines
 */
@interface PXLine : PXShape

/**
 *  A point indicating the location of the start of this line.
 */
@property (nonatomic) CGPoint p1;

/**
 *  A point indicating the location of the end of this line.
 */
@property (nonatomic) CGPoint p2;

/**
 *  Initializes a newly allocated line using the specified x and y locations
 *
 *  @param x1 The x coordinate of the start of the line
 *  @param y1 The y coordinate of the start of the line
 *  @param x2 The x coordinate of the end of the line
 *  @param y2 The y coordinate of the end of the line
 */
- (id)initX1:(CGFloat)x1 y1:(CGFloat)y1 x2:(CGFloat)x2 y2:(CGFloat)y2;

@end
