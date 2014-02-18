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
//  PXStrokeGroup.h
//  Pixate
//
//  Created by Kevin Lindsey on 7/2/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXStroke.h"

/**
 *  PXStrokeGroup allows a collection of PXStrokeRenderers to be treated as a single stroke. This is particularly useful
 *  when more than one stroke needs to be drawn for a given contour. Without this class, clones of the contour would
 *  have to be generated, one for each stroke to apply
 */
@interface PXStrokeGroup : NSObject <PXStrokeRenderer>

/**
 *  Add the specified stroke to this instance's list of strokes
 *
 *  @param stroke The stroke to add to this group
 */
- (void)addStroke:(id<PXStrokeRenderer>)stroke;

@end
