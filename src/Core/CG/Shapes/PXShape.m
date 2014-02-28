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
//  PXShape.m
//  Pixate
//
//  Created by Kevin Lindsey on 5/30/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXShape.h"
#import "PXShapeView.h"
#import "PXShadow.h"

@implementation PXShape

@synthesize parent = _parent;
@synthesize owningDocument = _owningDocument;

@synthesize path = _path;
@synthesize stroke = _stroke;
@synthesize fill = _fill;
@synthesize opacity = _opacity;
@synthesize visible = _visible;
@synthesize transform = _transform;
@synthesize clippingPath = _clippingPath;
@synthesize shadow = _shadow;
@synthesize padding = _padding;

#pragma mark - Initializers

- (id)init
{
    self = [super init];

    if (self)
    {
        self->_parent = nil;
        self->_owningDocument = nil;

        self->_path = nil;
        self.stroke = nil;
        self.fill = nil;
        self.opacity = 1.0;
        self.visible = YES;
        self.transform = CGAffineTransformIdentity;
        self.clippingPath = nil;
        self.shadow = nil;
    }

    return self;
}

#pragma mark - Getters

- (CGPathRef)path
{
    if (!self->_path)
    {
        self->_path = [self newPath];
    }

    return self->_path;
}

- (PXShapeDocument *)owningDocument
{
    id<PXRenderable> result = self;

    while (result.parent != nil)
    {
        result = result.parent;
    }

    PXShapeDocument *scene = nil;

    if ([result isKindOfClass:[PXShapeDocument class]])
    {
        scene = (PXShapeDocument *)result;
    }

    return scene;
}

#pragma mark - Setters

- (void)setPath:(CGPathRef)aPath
{
    if (self->_path)
    {
        CGPathRelease(self->_path);
    }

    self->_path = aPath;
}

- (void)setStroke:(id<PXStrokeRenderer>)stroke
{
    if (self->_stroke != stroke)
    {
        self->_stroke = stroke;
        [self setNeedsDisplay];
    }
}

- (void)setFill:(id<PXPaint>)fill
{
    if (self->_fill != fill)
    {
        self->_fill = fill;
        [self setNeedsDisplay];
    }
}

- (void)setOpacity:(CGFloat)aOpacity
{
    // clamp input to valid range
    CGFloat opacity = MIN(MAX(0.0, aOpacity), 1.0);

    if (self->_opacity != opacity)
    {
        self->_opacity = opacity;
        [self setNeedsDisplay];
    }
}

- (void)setVisible:(BOOL)visible
{
    if (self->_visible != visible)
    {
        self->_visible = visible;
        [self setNeedsDisplay];
    }
}

- (void)setTransform:(CGAffineTransform)transform
{
    if (!CGAffineTransformEqualToTransform(self->_transform, transform))
    {
        self->_transform = transform;
        [self setNeedsDisplay];
    }
}

- (void)setClippingPath:(PXShape *)clippingPath
{
    if (self->_clippingPath != clippingPath)
    {
        self->_clippingPath = clippingPath;
        [self setNeedsDisplay];
    }
}

- (void)setShadow:(id<PXShadowPaint>)shadow
{
    if (self->_shadow != shadow)
    {
        self->_shadow = shadow;
        [self setNeedsDisplay];
    }
}

#pragma mark - Methods

- (void)clearPath
{
    self.path = nil;

    [self setNeedsDisplay];
}

- (void)render:(CGContextRef)context
{
    // Don't draw if we're not visible
    if (context != nil && self.visible == YES)
    {
        // push context
        CGContextSaveGState(context);

        // apply transform
        if (CGAffineTransformEqualToTransform(self.transform, CGAffineTransformIdentity) == NO)
        {
            CGContextConcatCTM(context, self.transform);
        }

        // apply clipping path
        if (self.clippingPath)
        {
            CGContextAddPath(context, self.clippingPath.path);
            CGContextClip(context);
        }

        // setup transparency layer
        if ([self needsTransparencyLayer])
        {
            CGContextSetAlpha(context, self.opacity);
            CGContextBeginTransparencyLayer(context, NULL);
        }

        // render content
        if (self.path)
        {
            [self.shadow applyOutsetToPath:self.path withContext:context];
            [self.fill applyFillToPath:self.path withContext:context];
            [self.shadow applyInsetToPath:self.path withContext:context];
            [self.stroke applyStrokeToPath:self.path withContext:context];
        }

        // render children
        [self renderChildren:context];

        // tear down transparency layer
        if ([self needsTransparencyLayer])
        {
            CGContextEndTransparencyLayer(context);
        }

        // restore context
        CGContextRestoreGState(context);
    }
}

- (BOOL)needsTransparencyLayer
{
    return (self.opacity < 1.0f);
}

- (UIImage *)renderToImageWithBounds:(CGRect)bounds withOpacity:(BOOL)opaque
{
    UIImage *result = nil;

    if (bounds.size.width > 0 && bounds.size.height > 0)
    {
        // start new image context
        UIGraphicsBeginImageContextWithOptions(bounds.size, opaque, 0.0);

        // grab context
        CGContextRef context = UIGraphicsGetCurrentContext();

        // translate to bound's origin
        CGContextTranslateCTM(context, -bounds.origin.x, -bounds.origin.y);

        // render this shape
        [self render:context];

        // grab image
        result = UIGraphicsGetImageFromCurrentImageContext();

        // end image context
        UIGraphicsEndImageContext();
    }

    return result;
}

- (void)setNeedsDisplay
{
    [self.owningDocument.parentView setNeedsDisplay];
}

#pragma mark - Abstract Methods

- (CGPathRef)newPath
{
    return nil;
}

- (void)renderChildren:(CGContextRef)context
{
}

#pragma mark - Overrides

- (void)dealloc
{
    _parent = nil;
    _owningDocument = nil;

    self.path = nil;
    self.stroke = nil;
    self.fill = nil;
    self.clippingPath = nil;
    self.shadow = nil;
}
@end
