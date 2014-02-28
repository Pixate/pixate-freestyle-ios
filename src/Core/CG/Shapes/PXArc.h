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
//  PXArc.h
//  Pixate
//
//  Created by Kevin Lindsey on 9/4/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXShape.h"

/**
 *  A PXShape subclass used to render arcs
 */
@interface PXArc : PXShape

/**
 *  A point indicating the location of the center of this arc.
 */
@property (nonatomic) CGPoint center;

/**
 *  A value indicating the size of the radius of this arc.
 *
 *  This value may be negative, but it will be normalized to a positive value.
 */
@property (nonatomic) CGFloat radius;

/**
 *  A value indicating the starting angle for this arc
 */
@property (nonatomic) CGFloat startingAngle;

/**
 *  A value indicating the ending angle for this arc
 */
@property (nonatomic) CGFloat endingAngle;

@end
