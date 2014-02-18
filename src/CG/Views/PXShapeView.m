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
//  PXShapeView.m
//  Pixate
//
//  Created by Kevin Lindsey on 5/30/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXShapeView.h"
#import "PXShapeGroup.h"
#import "PXSVGLoader.h"

@implementation PXShapeView

#pragma mark - Setters

- (void)setResourcePath:(NSString *)aResourcePath
{
    _resourcePath = aResourcePath;

    if (_resourcePath)
    {
#ifndef FREE
        NSString *fullPath = [[NSBundle mainBundle] pathForResource:aResourcePath ofType:@"svg"];

        if (fullPath)
        {
            [self loadSceneFromURL:[NSURL fileURLWithPath:fullPath]];
        }
        else
#endif
        {
            _document = nil;
        }
    }
    else
    {
        _document = nil;
    }
}

- (void)setDocument:(PXShapeDocument *)document
{
    if (_document)
    {
        _document.parentView = nil;
    }

    _document = document;

    if (_document)
    {
        _document.parentView = self;
    }

    [self applyBoundsToScene];
}

#pragma mark - Methods

- (UIImage *)renderToImage
{
    UIImage *result = nil;
    CGRect bounds = self.bounds;

    if (bounds.size.width > 0 && bounds.size.height > 0)
    {
        // start new image context
        UIGraphicsBeginImageContextWithOptions(bounds.size, NO, 0.0);

        // grab context
        CGContextRef context = UIGraphicsGetCurrentContext();

        // translate to bound's origin
        CGContextTranslateCTM(context, -bounds.origin.x, -bounds.origin.y);

        // render this shape
        [_document render:context];

        // grab image
        result = UIGraphicsGetImageFromCurrentImageContext();

        // end image context
        UIGraphicsEndImageContext();
    }

    return result;
}

- (void)loadSceneFromURL:(NSURL *)URL
{
    // TODO: this has been exposed and when used directly, resourcePath will keep it's old value
    self.document = [PXSVGLoader loadFromURL:URL];
}

- (void)applyBoundsToScene
{
    if (_document)
    {
        _document.bounds = self.bounds;
    }
}

#pragma mark - Overrides

- (void)dealloc
{
    _document = nil;
}

- (void)drawRect:(CGRect)rect
{
    if (_document)
    {
        CGContextRef context = UIGraphicsGetCurrentContext();

        [_document render:context];
    }
}

@end
