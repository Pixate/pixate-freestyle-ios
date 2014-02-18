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
//  PXBarShadowStyler
//  Pixate
//
//  Created by Paul Colton on 10/16/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXBarShadowStyler.h"
#import "PXShapeView.h"
#import "PXRectangle.h"
#import "PXStroke.h"
#import "PXSolidPaint.h"
#import "PXShadowPaint.h"
#import "PXShadowGroup.h"
#import <QuartzCore/QuartzCore.h>

@implementation PXBarShadowStyler

- (NSDictionary *)declarationHandlers
{
    static __strong NSDictionary *handlers = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        handlers = @{
            @"shadow" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                context.shadowUrl = declaration.URLValue;
            },
            @"shadow-size" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                CGSize size = declaration.sizeValue;
                context.shadowBounds = CGRectMake(0.0f, 0.0f, size.width, size.height);
            },
            @"shadow-inset": ^(PXDeclaration *declaration, PXStylerContext *context) {
                context.shadowInsets = declaration.insetsValue;
            },
            @"shadow-padding" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                context.shadowPadding = declaration.floatValue;
            },
        };
    });

    return handlers;
}

- (void)applyStylesWithContext:(PXStylerContext *)context
{
    if (context.shadowUrl)
    {
        CGSize size = context.shadowBounds.size;

        // create image
        if ([[context.shadowUrl.pathExtension lowercaseString] isEqualToString:@"svg"])
        {
            CGRect bounds = context.shadowBounds;

            // use view bounds as default if no bounds has been specified
            if (CGRectEqualToRect(bounds, CGRectZero))
            {
                bounds = context.styleable.bounds;
                size = bounds.size;
            }

            PXShapeView *shapeView = [[PXShapeView alloc] initWithFrame:bounds];

            [shapeView loadSceneFromURL:context.shadowUrl];
            context.shadowImage = [shapeView renderToImage];
        }
        else
        {
            // TODO: Use selector with error param?
            NSData *data = [NSData dataWithContentsOfURL:context.shadowUrl];

            if (data)
            {
                // grab image
                context.shadowImage = [[UIImage alloc] initWithData:data];

                // use image as default if no size has been specified
                if (CGSizeEqualToSize(size, CGSizeZero))
                {
                    size = context.shadowImage.size;
                }

                // resize, if necessary
                if (context.shadowImage && !CGSizeEqualToSize(context.shadowImage.size, size))
                {
                    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
                    [context.shadowImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
                    context.shadowImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
            }
        }

        // pad, if necessary
        if (context.shadowImage && context.shadowPadding > 0.0f)
        {
            CGSize paddedSize = CGSizeMake(size.width + 2.0f * context.shadowPadding, size.height + 2.0f * context.shadowPadding);
            UIGraphicsBeginImageContextWithOptions(paddedSize, NO, 0.0);
            [context.shadowImage drawInRect:CGRectMake(context.shadowPadding, context.shadowPadding, size.width, size.height)];
            context.shadowImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }

        // apply insets, if we have any
        if (context.shadowImage && !UIEdgeInsetsEqualToEdgeInsets(context.shadowInsets, UIEdgeInsetsZero))
        {
            context.shadowImage = [context.shadowImage resizableImageWithCapInsets:context.shadowInsets];
        }
    }

    [super applyStylesWithContext:context];
}

@end
