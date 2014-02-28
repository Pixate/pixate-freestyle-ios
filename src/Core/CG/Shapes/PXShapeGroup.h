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
//  PXShapeGroup.h
//  Pixate
//
//  Created by Kevin Lindsey on 6/1/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PXShape.h"
#import "PXRenderable.h"

typedef enum {
    kAlignViewPortNone,
    kAlignViewPortXMinYMin,
    kAlignViewPortXMinYMid,
    kAlignViewPortXMinYMax,
    kAlignViewPortXMidYMin,
    kAlignViewPortXMidYMid,
    kAlignViewPortXMidYMax,
    kAlignViewPortXMaxYMin,
    kAlignViewPortXMaxYMid,
    kAlignViewPortXMaxYMax,
} AlignViewPortType;

typedef enum {
    kCropTypeMeet,
    kCropTypeSlice
} CropType;

/**
 *  A PXShape sub-class used to render collections of shapes
 */
@interface PXShapeGroup : PXShape

/**
 *  The width of this shape group.
 *
 *  This value is deprecated
 */
@property (nonatomic) CGFloat width;

/**
 *  The height of this shape group.
 *
 *  This value is deprecated
 */
@property (nonatomic) CGFloat height;

/**
 *  The viewport of this shape group.
 */
@property (nonatomic) CGRect viewport;

/**
 *  The alignment to use when mapping a shape group's viewport to the screen
 */
@property (nonatomic) AlignViewPortType viewportAlignment;

/**
 *  The type of crop to use when applying the shape group's viewport to the screen
 */
@property (nonatomic) CropType viewportCrop;

/**
 *  A read-only property indicating how many child shapes this group contains.
 */
@property (readonly, nonatomic) NSUInteger shapeCount;

/**
 *  A read-only property of the transform that would need to be applied to this shape group in order for its viewport to
 *  fit within the specified shape group width and height.
 */
@property (readonly, nonatomic) CGAffineTransform viewPortTransform;

/**
 *  Adds a shape to this shape group.
 *
 *  Nil values are ignored
 *
 *  @param shape The shape to add
 */
- (void)addShape:(id<PXRenderable>)shape;

/**
 *  Removes the specified shape from the shape group
 *
 *  @param shape The shape to remove
 */
- (void)removeShape:(id<PXRenderable>)shape;

/**
 *  Returns the shape at the specified index.
 *
 *  Nil is returned for index values that are out of range
 *
 *  @param index The index of the shape to return
 *  @returns A PXRenderable to nil
 */
- (id<PXRenderable>)shapeAtIndex:(NSUInteger)index;

@end
