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
//  PXRenderable.h
//  Pixate
//
//  Created by Kevin Lindsey on 5/30/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXOffsets.h"

/**
 *  The PXRenderable protocol declares properties needed when describing the structure of content rendered to a
 *  CGContext.
 */
@protocol PXRenderable <NSObject>

/**
 *  A property indicating the PXRenderable that this shape belongs to
 */
@property (nonatomic, strong) id<PXRenderable> parent;

/**
 *  A transform to be applied to this shape during rendering
 */
@property (nonatomic) CGAffineTransform transform;

/**
 *  Padding to be applied to this instance during rendering
 */
@property (nonatomic) PXOffsets *padding;

/**
 *  The method responsible for painting this shape to the specified CGContext
 *
 *  @param context the context in which to render
 */
- (void)render:(CGContextRef)context;

/**
 *  Render this shape within the specified bounds and return that as a UIImage
 *
 *  @param bounds The bounds which establishes the view bounds and the resulting image size
 *  @param opaque Determine if the resulting image should have an alph channel or not
 *  @returns A UIImage of the rendered shape
 */
- (UIImage *)renderToImageWithBounds:(CGRect)bounds withOpacity:(BOOL)opaque;

@end
