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
//  PXScene.m
//  Pixate
//
//  Created by Kevin Lindsey on 6/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXShapeDocument.h"
#import "PXShapeGroup.h"

@implementation PXShapeDocument
{
    NSMutableDictionary *nameDictionary;
}

@synthesize shape = _shape;
@synthesize bounds = _bounds;
@synthesize transform = _transform;
@synthesize parentView = _parentView;
@synthesize padding = _padding;

#pragma mark - Initializers

- (id)init
{
    self = [super init];

    if (self)
    {
        self.shape = nil;
        self.transform = CGAffineTransformIdentity;
    }

    return self;
}

#pragma mark - Getters

- (id<PXRenderable>)parent
{
    return nil;
}

#pragma mark - Setters

- (void)setBounds:(CGRect)aBounds
{
    _bounds = aBounds;

    // TODO: handle top-left as well
    if ([self.shape isKindOfClass:[PXShapeGroup class]])
    {
        CGSize size = self.bounds.size;
        PXShapeGroup *group = (PXShapeGroup *) self.shape;

        group.width = size.width;
        group.height = size.height;
    }
}

- (void)setParent:(id<PXRenderable>)parent
{
    // scenes are always the top-most parent
}

- (void)setShape:(id<PXRenderable>)aShape
{
    if (_shape != aShape)
    {
        // disconnect parent from old shape
        if (_shape)
        {
            _shape.parent = nil;
        }

        _shape = aShape;

        // connect parent on new shape
        if (_shape)
        {
            _shape.parent = self;
        }
    }
}

#pragma mark - Methods

- (id<PXRenderable>)shapeForName:(NSString *)name
{
    id<PXRenderable> result = nil;

    if (nameDictionary && name)
    {
        result = [nameDictionary objectForKey:name];
    }

    return result;
}

- (void)addShape:(id<PXRenderable>)aShape forName:(NSString *)aName
{
    if (aName && aShape)
    {
        if (!nameDictionary)
        {
            nameDictionary = [NSMutableDictionary dictionary];
        }

        [nameDictionary setObject:aShape forKey:aName];
    }
}

#pragma mark - PXRenderable Methods

- (void)render:(CGContextRef)context
{
    if (self->_shape)
    {
        CGContextConcatCTM(context, self.transform);
        [self->_shape render:context];
    }
}

- (UIImage *)renderToImageWithBounds:(CGRect)aBounds withOpacity:(BOOL)opaque
{
    UIImage *result = nil;

    if (aBounds.size.width > 0 && aBounds.size.height > 0)
    {
        // start new image context
        UIGraphicsBeginImageContextWithOptions(aBounds.size, opaque, 0.0);

        // grab context
        CGContextRef context = UIGraphicsGetCurrentContext();

        // translate to bound's origin
        CGContextTranslateCTM(context, -aBounds.origin.x, -aBounds.origin.y);

        // render this shape
        [self render:context];

        // grab image
        result = UIGraphicsGetImageFromCurrentImageContext();

        // end image context
        UIGraphicsEndImageContext();
    }

    return result;
}

#pragma mark - Overrides

- (void)dealloc
{
    self.shape = nil;
    _parentView = nil;
    nameDictionary = nil;
}

@end
