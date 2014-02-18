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
//  PXPolygon.h
//  Pixate
//
//  Created by Kevin Lindsey on 6/9/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXShape.h"

/**
 *  A PXShape sub-class used to render open and closed polygons
 */
@interface PXPolygon : PXShape

/**
 *  A flag indicating whether this polygon should be closed or not
 *
 *  When this flag is true, the final point of this polygon will automatically be joined to the first it's first point.
 *  If you do not close this polygon and instead duplicate the first point as the last, you will not get a clean
 *  connection at the start point.
 */
@property (nonatomic) BOOL closed;

/**
 *  An array of points describing the shape of this polygon
 */
@property (nonatomic, strong) NSArray *points;

/**
 *  Initializes a newly allocated polygon using the specified list of points
 *
 *  @param points The list of points describing the shape of this polygon
 */
- (id)initWithPoints:(NSArray *)points;

@end
