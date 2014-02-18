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
//  PXShapeGroup.m
//  Pixate
//
//  Created by Kevin Lindsey on 6/1/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXShapeGroup.h"
#import "PXRenderable.h"

@implementation PXShapeGroup
{
    NSMutableArray *shapes_;
}

#pragma mark - Initializers

- (id)init
{
    self = [super init];

    if (self) {
        shapes_ = [NSMutableArray array];
        _width = 0;
        _height = 0;
        _viewport = CGRectMake(0, 0, 0, 0);
        _viewportAlignment = kAlignViewPortXMidYMid;
        _viewportCrop = kCropTypeMeet;
    }

    return self;
}

#pragma mark - Getters

-(NSUInteger)shapeCount
{
    return (shapes_) ? shapes_.count : 0;
}

#pragma mark - Methods

- (void)addShape:(id<PXRenderable>)shape
{
    if (shape)
    {
        // add shape to child list
        [shapes_ addObject: shape];

        // set child's parent
        shape.parent = self;
    }
}

- (void)removeShape:(id<PXRenderable>)shape
{
    if (shape)
    {
        [shapes_ removeObject:shape];

        // TODO: verify this is in this group
        shape.parent = nil;
    }
}

- (id<PXRenderable>)shapeAtIndex:(NSUInteger)index
{
    return (shapes_) ? [shapes_ objectAtIndex:index] : nil;
}

- (CGAffineTransform) viewPortTransform
{
    CGPoint viewPortOrigin = self.viewport.origin;
    CGSize viewPortSize = self.viewport.size;

    CGAffineTransform matrix = CGAffineTransformIdentity;

    // TODO: take viewPort x and y into account
    if (viewPortSize.width && viewPortSize.height && self.width > 0 && self.height > 0)
    {
        CGFloat ratioX = self.width / viewPortSize.width;
        CGFloat ratioY = self.height / viewPortSize.height;

        matrix = CGAffineTransformTranslate(matrix, viewPortOrigin.x, viewPortOrigin.y);

        if (self.viewportAlignment == kAlignViewPortNone)
        {
            matrix = CGAffineTransformScale(matrix, ratioX, ratioY);
        }
        else
        {
            if ((ratioX > ratioY && self.viewportCrop == kCropTypeMeet) ||
                (ratioX < ratioY && self.viewportCrop == kCropTypeSlice))
            {
                CGFloat tx = 0;
                CGFloat diffX = self.width - viewPortSize.width * ratioY ;

                switch (self.viewportAlignment)
                {
                    case kAlignViewPortXMidYMin:
                    case kAlignViewPortXMidYMid:
                    case kAlignViewPortXMidYMax:
                        tx = diffX * 0.5;
                        break;

                    case kAlignViewPortXMaxYMin:
                    case kAlignViewPortXMaxYMid:
                    case kAlignViewPortXMaxYMax:
                        tx = diffX;
                        break;

                    default:
                        break;
                }

                matrix = CGAffineTransformTranslate(matrix, tx, 0);
                matrix = CGAffineTransformScale(matrix, ratioY, ratioY);
            }
            else if ((ratioX < ratioY && self.viewportCrop == kCropTypeMeet) ||
                     (ratioX > ratioY && self.viewportCrop == kCropTypeSlice))
            {
                CGFloat ty = 0;
                CGFloat diffY = self.height - viewPortSize.height * ratioX;

                switch (self.viewportAlignment)
                {
                    case kAlignViewPortXMinYMid:
                    case kAlignViewPortXMidYMid:
                    case kAlignViewPortXMaxYMid:
                        ty = diffY * 0.5;
                        break;

                    case kAlignViewPortXMinYMax:
                    case kAlignViewPortXMidYMax:
                    case kAlignViewPortXMaxYMax:
                        ty = diffY;
                        break;

                    default:
                        break;
                }

                matrix = CGAffineTransformTranslate(matrix, 0, ty);
                matrix = CGAffineTransformScale(matrix, ratioX, ratioX);
            }
            else
            {
                matrix = CGAffineTransformScale(matrix, ratioX, ratioX);
            }

        }
    }

    return matrix;
}

- (void) renderChildren:(CGContextRef)context
{

    CGAffineTransform matrix = [self viewPortTransform];

    CGContextConcatCTM(context, matrix);

    for (id<PXRenderable> shape in shapes_)
    {
        [shape render:context];
    }
}

#pragma mark - Overrides

- (void)dealloc
{
    for (id<PXRenderable> shape in shapes_)
    {
        shape.parent = nil;
    }

    shapes_ = nil;
}

@end
