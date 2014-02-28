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
//  PXRadialGradient.h
//  Pixate
//
//  Created by Kevin Lindsey on 6/8/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXGradient.h"
#import "PXPaint.h"

/**
 *  PXRadialGradient is an implementation of a radial gradient. Radial gradients are specified by a starting and ending
 *  center point along with a radius
 */
@interface PXRadialGradient : PXGradient

/**
 *  The center point where the first color is to be rendered
 */
@property (nonatomic) CGPoint startCenter;

/**
 *  The center point where the last color is to be rendered
 */
@property (nonatomic) CGPoint endCenter;

/**
 *  The radius of the final color being rendered. The starting radius is implied to be zero, or some reasonably small
 *  value
 */
@property (nonatomic) CGFloat radius;

@end
