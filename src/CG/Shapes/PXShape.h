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
//  PXShape.h
//  Pixate
//
//  Created by Kevin Lindsey on 5/30/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXRenderable.h"
#import "PXPaintable.h"
#import "PXShapeDocument.h"

/**
 *  A common base class for all shapes in ShapeKit.
 *
 *  A PXShape must implement the PXRenderable protocol and the PXPaintable protocol. This class can be used to cache the
 *  geometry of the shape it describes.
 */
@interface PXShape : NSObject <PXRenderable,PXPaintable>

/**
 *  A read-only property of the path data associated with this shape instance.
 *
 *  Note that when this property is accessed, the buildPath method may be called to populate the path cache for the
 *  instance. This property may return nil, which indicates that the instance was unable to create a path.
 */
@property (readonly, nonatomic) CGPathRef path;

/**
 *  A read-only property pointing to the PXScene that owns this instance.
 *
 *  This property can be thought of as being analogous to the W3C DOM Node#getDocument method.
 */
@property (readonly, nonatomic) PXShapeDocument *owningDocument;

/**
 *  Build a CGPathRef that contains the geometry of this instance's shape.
 *
 *  Typically, this method would not be called in isolation. It is more of a helper method for the path property.
 */
- (CGPathRef)newPath;

/**
 *  Clear the path cache.
 *
 *  This method is used to clear the path cache maintained by this shape. This can be useful in low memory situations,
 *  but this is more likely to be used when some attribute of the shape has changed which affects its geometry. At which
 *  point, the cache is invalidated and will be rebuilt the next time the path property is accessed.
 */
- (void)clearPath;

/**
 *  Render any children associated with this shape.
 *
 *  This method is used to render any child content associated with this shape. In most cases, this will only be used by
 *  container classes, such as PXShapeGroup.
 *
 *  @param context The context into which children of this shape should be rendered.
 */
- (void)renderChildren:(CGContextRef)context;

/**
 *  Indicate that this shape needs to be redrawn.
 *
 *  This method is used to indicate that this shape needs to be redrawn. This will effectively call setNeedsDisplay on
 *  the view that utlimately owns this shape; however, note that shape geometry is cached. This will force the shape to
 *  be redrawn, but it will not force the shape's geometry to be recalculated. If you need to clear the cache and
 *  refresh, call clearPath.
 */
- (void)setNeedsDisplay;

@end
