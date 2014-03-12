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
//  PXImagePaint.m
//  Pixate
//
//  Created by Kevin Lindsey on 3/27/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXImagePaint.h"
#import "PXShapeView.h"

@implementation PXImagePaint

@synthesize blendMode = _blendMode;

#pragma mark - Initializers

- (id)initWithURL:(NSURL *)url
{
    if (self = [super init]) {
        _imageURL = url;
    }

    return self;
}

#pragma mark - Getters

- (BOOL)isOpaque
{
    // TODO:
    return YES;
}

- (BOOL)hasSVGImageURL
{
    return
    [[_imageURL.pathExtension lowercaseString] isEqualToString:@"svg"]
    ||  ([@"data" isEqualToString:_imageURL.scheme] && [_imageURL.resourceSpecifier hasPrefix:@"image/svg+xml"]);
}

# pragma mark - Helper Methods

- (UIImage *)imageForBounds:(CGRect)bounds
{
    UIImage *image = nil;

    if (_imageURL)
    {
        CGSize size = bounds.size;

        // create image
        if ([self hasSVGImageURL])
        {
            PXShapeView *shapeView = [[PXShapeView alloc] initWithFrame:bounds];

            [shapeView loadSceneFromURL:_imageURL];
            image = [shapeView renderToImage];
        }
        else
        {
            // TODO: Use selector with error param?
            NSData *data = [NSData dataWithContentsOfURL:_imageURL];

            if (data)
            {
                CGFloat scale;

                if ([@"data" isEqualToString:_imageURL.scheme])
                {
                    scale = [UIScreen mainScreen].scale;
                }
                else
                {
                    NSString *filename = _imageURL.lastPathComponent;
                    NSString *basename = [filename stringByDeletingPathExtension];

                    scale = [basename hasSuffix:@"@2x"] ? 2.0f : 1.0f;  // TODO: pull out number and use that?
                }

                // grab image
                image = [[UIImage alloc] initWithData:data scale:scale];
            }
            else // Assuming it's an asset name at this point
            {
                image = [UIImage imageNamed:_imageURL.relativePath];
            }
            
            // resize, if necessary
            if (image && !CGSizeEqualToSize(image.size, size))
            {
                UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
                [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
        }
    }

    return image;
}

#pragma mark - PXPaint Implementation

- (void)applyFillToPath:(CGPathRef)path withContext:(CGContextRef)context
{
    UIImage *image = [self imageForBounds:CGPathGetBoundingBox(path)];

    if (image != nil)
    {
        // create pattern color
        UIColor *color = [UIColor colorWithPatternImage:image];
        CGContextSetFillColorWithColor(context, color.CGColor);

        CGContextAddPath(context, path);

        // set blending mode
        CGContextSetBlendMode(context, _blendMode);

        // fill
        CGContextFillPath(context);
    }
}

- (id<PXPaint>)lightenByPercent:(CGFloat)percent
{
    // TODO:
    return self;
}

- (id<PXPaint>)darkenByPercent:(CGFloat)percent
{
    // TODO:
    return self;
}

@end
