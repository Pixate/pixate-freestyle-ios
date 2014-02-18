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
//  PXBoxModel.m
//  Pixate
//
//  Created by Kevin Lindsey on 3/25/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXBoxModel.h"
#import "PXPath.h"
#import "PXStroke.h"

@implementation PXBoxModel
{
    PXBorderInfo *borderTop_;
    PXBorderInfo *borderRight_;
    PXBorderInfo *borderBottom_;
    PXBorderInfo *borderLeft_;
    PXPath *borderPathTop_;
    PXPath *borderPathRight_;
    PXPath *borderPathBottom_;
    PXPath *borderPathLeft_;
}

@synthesize bounds = _bounds;

#pragma mark - Initializers

- (id)init
{
    return [self initWithBounds:CGRectZero];
}

- (id)initWithBounds:(CGRect)bounds
{
    if (self = [super init])
    {
        _bounds = bounds;
        borderTop_ = [[PXBorderInfo alloc] init];
        borderRight_ = [[PXBorderInfo alloc] init];
        borderBottom_ = [[PXBorderInfo alloc] init];
        borderLeft_ = [[PXBorderInfo alloc] init];
    }

    return self;
}

#pragma mark - Getters

- (id<PXPaint>)borderTopPaint
{
    return borderTop_.paint;
}

- (PXBorderStyle)borderTopStyle
{
    return borderTop_.style;
}

- (CGFloat)borderTopWidth
{
    return borderTop_.width;
}

- (id<PXPaint>)borderRightPaint
{
    return borderRight_.paint;
}

- (PXBorderStyle)borderRightStyle
{
    return borderRight_.style;
}

- (CGFloat)borderRightWidth
{
    return borderRight_.width;
}

- (id<PXPaint>)borderBottomPaint
{
    return borderBottom_.paint;
}

- (PXBorderStyle)borderBottomStyle
{
    return borderBottom_.style;
}

- (CGFloat)borderBottomWidth
{
    return borderBottom_.width;
}

- (id<PXPaint>)borderLeftPaint
{
    return borderLeft_.paint;
}

- (PXBorderStyle)borderLeftStyle
{
    return borderLeft_.style;
}

- (CGFloat)borderLeftWidth
{
    return borderLeft_.width;
}

- (CGRect)borderBounds
{
    CGRect bounds = self.contentBounds;

    bounds.origin.x -= borderLeft_.width;
    bounds.origin.y -= borderTop_.width;
    bounds.size.width += borderLeft_.width + borderRight_.width;
    bounds.size.height += borderTop_.width + borderBottom_.width;

    return bounds;
}

- (CGRect)contentBounds
{
    return _bounds;
}

- (BOOL)hasCornerRadius
{
    return
        CGSizeEqualToSize(_radiusTopLeft, CGSizeZero) == NO
    ||  CGSizeEqualToSize(_radiusTopRight, CGSizeZero) == NO
    ||  CGSizeEqualToSize(_radiusBottomRight, CGSizeZero) == NO
    ||  CGSizeEqualToSize(_radiusBottomLeft, CGSizeZero) == NO;
}

- (BOOL)hasBorder
{
    return
        borderTop_.hasContent
    ||  borderRight_.hasContent
    ||  borderBottom_.hasContent
    ||  borderLeft_.hasContent;
}

- (BOOL)isOpaque
{
    return
        self.hasCornerRadius == NO
    &&  borderTop_.isOpaque
    &&  borderRight_.isOpaque
    &&  borderBottom_.isOpaque
    &&  borderLeft_.isOpaque;
}

#pragma mark - Setters

- (void)setBorderTopPaint:(id<PXPaint>)borderTopPaint
{
    borderTop_.paint = borderTopPaint;
    [self clearPath];
}

- (void)setBorderTopStyle:(PXBorderStyle)borderTopStyle
{
    borderTop_.style = borderTopStyle;
    [self clearPath];
}

- (void)setBorderTopWidth:(CGFloat)borderTopWidth
{
    borderTop_.width = borderTopWidth;
    [self clearPath];
}

- (void)setBorderRightPaint:(id<PXPaint>)borderRightPaint
{
    borderRight_.paint = borderRightPaint;
    [self clearPath];
}

- (void)setBorderRightStyle:(PXBorderStyle)borderRightStyle
{
    borderRight_.style = borderRightStyle;
    [self clearPath];
}

- (void)setBorderRightWidth:(CGFloat)borderRightWidth
{
    borderRight_.width = borderRightWidth;
    [self clearPath];
}

- (void)setBorderBottomPaint:(id<PXPaint>)borderBottomPaint
{
    borderBottom_.paint = borderBottomPaint;
    [self clearPath];
}

- (void)setBorderBottomStyle:(PXBorderStyle)borderBottomStyle
{
    borderBottom_.style = borderBottomStyle;
    [self clearPath];
}

- (void)setBorderBottomWidth:(CGFloat)borderBottomWidth
{
    borderBottom_.width = borderBottomWidth;
    [self clearPath];
}

- (void)setBorderLeftPaint:(id<PXPaint>)borderLeftPaint
{
    borderLeft_.paint = borderLeftPaint;
    [self clearPath];
}

- (void)setBorderLeftStyle:(PXBorderStyle)borderLeftStyle
{
    borderLeft_.style = borderLeftStyle;
    [self clearPath];
}

- (void)setBorderLeftWidth:(CGFloat)borderLeftWidth
{
    borderLeft_.width = borderLeftWidth;
    [self clearPath];
}

- (void)setBorderTopPaint:(id<PXPaint>)paint width:(CGFloat)width style:(PXBorderStyle)style
{
    [self setBorderTopPaint:paint];
    [self setBorderTopWidth:width];
    [self setBorderTopStyle:style];
}

- (void)setBorderRightPaint:(id<PXPaint>)paint width:(CGFloat)width style:(PXBorderStyle)style
{
    [self setBorderRightPaint:paint];
    [self setBorderRightWidth:width];
    [self setBorderRightStyle:style];
}

- (void)setBorderBottomPaint:(id<PXPaint>)paint width:(CGFloat)width style:(PXBorderStyle)style
{
    [self setBorderBottomPaint:paint];
    [self setBorderBottomWidth:width];
    [self setBorderBottomStyle:style];
}

- (void)setBorderLeftPaint:(id<PXPaint>)paint width:(CGFloat)width style:(PXBorderStyle)style
{
    [self setBorderLeftPaint:paint];
    [self setBorderLeftWidth:width];
    [self setBorderLeftStyle:style];
}

- (void)setBorderPaint:(id<PXPaint>)paint
{
    [self setBorderTopPaint:paint];
    [self setBorderRightPaint:paint];
    [self setBorderBottomPaint:paint];
    [self setBorderLeftPaint:paint];
}

- (void)setBorderWidth:(CGFloat)width
{
    [self setBorderTopWidth:width];
    [self setBorderRightWidth:width];
    [self setBorderBottomWidth:width];
    [self setBorderLeftWidth:width];
}

- (void)setBorderStyle:(PXBorderStyle)style
{
    [self setBorderTopStyle:style];
    [self setBorderRightStyle:style];
    [self setBorderBottomStyle:style];
    [self setBorderLeftStyle:style];
}

- (void)setBorderPaint:(id<PXPaint>)paint width:(CGFloat)width style:(PXBorderStyle)style
{
    [self setBorderTopPaint:paint width:width style:style];
    [self setBorderRightPaint:paint width:width style:style];
    [self setBorderBottomPaint:paint width:width style:style];
    [self setBorderLeftPaint:paint width:width style:style];
}

- (void)setRadiusTopLeft:(CGSize)radiusTopLeft
{
    _radiusTopLeft = radiusTopLeft;
    [self clearPath];
}

- (void)setRadiusTopRight:(CGSize)radiusTopRight
{
    _radiusTopRight = radiusTopRight;
    [self clearPath];
}

- (void)setRadiusBottomRight:(CGSize)radiusBottomRight
{
    _radiusBottomRight = radiusBottomRight;
    [self clearPath];
}

- (void)setRadiusBottomLeft:(CGSize)radiusBottomLeft
{
    _radiusBottomLeft = radiusBottomLeft;
    [self clearPath];
}

- (void)setCornerRadius:(CGFloat)radius
{
    [self setCornerRadii:CGSizeMake(radius, radius)];
}

- (void)setCornerRadii:(CGSize)radii
{
    self.radiusTopLeft = radii;
    self.radiusTopRight = radii;
    self.radiusBottomRight = radii;
    self.radiusBottomLeft = radii;
}

#pragma mark - Overrides

- (CGPathRef)newPath
{
    CGPathRef resultPath = nil;

    if (self.hasCornerRadius == NO)
    {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, self.borderBounds);

        resultPath = CGPathCreateCopy(path);

        CGPathRelease(path);

        // create borders
        [self createBorders];
    }

    return resultPath;
}

- (void)createBorders
{
    CGRect contentBounds = self.contentBounds;
    CGRect borderBounds = self.borderBounds;

    CGFloat borderLeft = borderBounds.origin.x;
    CGFloat borderRight = borderBounds.origin.x + borderBounds.size.width;
    CGFloat borderTop = borderBounds.origin.y;
    CGFloat borderBottom = borderBounds.origin.y + borderBounds.size.height;

    CGFloat contentLeft = contentBounds.origin.x;
    CGFloat contentRight = contentBounds.origin.x + contentBounds.size.width;
    CGFloat contentTop = contentBounds.origin.y;
    CGFloat contentBottom = contentBounds.origin.y + contentBounds.size.height;

    // reset borders
    borderPathTop_ = nil;
    borderPathRight_ = nil;
    borderPathBottom_ = nil;
    borderPathLeft_ = nil;

    // top
    if (borderTop_.hasContent)
    {
        borderPathTop_ = [[PXPath alloc] init];

        switch (borderTop_.style)
        {
            case PXBorderStyleSolid:
                [borderPathTop_ moveToX:borderLeft y:borderTop];
                [borderPathTop_ lineToX:borderRight y:borderTop];
                [borderPathTop_ lineToX:contentRight y:contentTop];
                [borderPathTop_ lineToX:contentLeft y:contentTop];
                [borderPathTop_ close];
                borderPathTop_.fill = borderTop_.paint;
                break;

            case PXBorderStyleDashed:
            {
                CGFloat y = (borderTop + contentTop) * 0.5f;
                CGFloat width = borderTop_.width;

                [borderPathTop_ moveToX:borderLeft y:y];
                [borderPathTop_ lineToX:borderRight y:y];

                PXStroke *stroke = [[PXStroke alloc] initWithStrokeWidth:width];
                stroke.color = borderTop_.paint;
                stroke.dashArray = [self dashArrayFromLength:borderRight - borderLeft width:2.0f * width];
                borderPathTop_.stroke = stroke;
                break;
            }

            case PXBorderStyleDotted:
            {
                CGFloat y = (borderTop + contentTop) * 0.5f;
                CGFloat width = borderTop_.width;

                [borderPathTop_ moveToX:borderLeft y:y];
                [borderPathTop_ lineToX:borderRight y:y];

                PXStroke *stroke = [[PXStroke alloc] initWithStrokeWidth:width];
                stroke.color = borderTop_.paint;
                stroke.dashArray = [self dashArrayFromLength:borderRight - borderLeft width:width];
                borderPathTop_.stroke = stroke;
                break;
            }

            case PXBorderStyleDouble:
                // TODO:
                break;

            case PXBorderStyleGroove:
            case PXBorderStyleInset:
            case PXBorderStyleOutset:
            case PXBorderStyleRidge:
                break;

            // NOTE: We should never hit these cases
            case PXBorderStyleNone:
            case PXBorderStyleHidden:
            default:
                break;
        }
    }

    // right
    if (borderRight_.hasContent)
    {
        borderPathRight_ = [[PXPath alloc] init];

        switch (borderRight_.style)
        {
            case PXBorderStyleSolid:
                [borderPathRight_ moveToX:borderRight y:borderTop];
                [borderPathRight_ lineToX:borderRight y:borderBottom];
                [borderPathRight_ lineToX:contentRight y:contentBottom];
                [borderPathRight_ lineToX:contentRight y:contentTop];
                [borderPathRight_ close];
                borderPathRight_.fill = borderRight_.paint;
                break;

            case PXBorderStyleDashed:
            {
                CGFloat x = (borderRight + contentRight) * 0.5f;
                CGFloat width = borderRight_.width;

                [borderPathRight_ moveToX:x y:borderTop];
                [borderPathRight_ lineToX:x y:borderBottom];

                PXStroke *stroke = [[PXStroke alloc] initWithStrokeWidth:width];
                stroke.color = borderRight_.paint;
                stroke.dashArray = [self dashArrayFromLength:borderBottom - borderTop width:2.0f * width];
                borderPathRight_.stroke = stroke;
                break;
            }

            case PXBorderStyleDotted:
            {
                CGFloat x = (borderRight + contentRight) * 0.5f;
                CGFloat width = borderRight_.width;

                [borderPathRight_ moveToX:x y:borderTop];
                [borderPathRight_ lineToX:x y:borderBottom];

                PXStroke *stroke = [[PXStroke alloc] initWithStrokeWidth:width];
                stroke.color = borderRight_.paint;
                stroke.dashArray = [self dashArrayFromLength:borderBottom - borderTop width:width];
                borderPathRight_.stroke = stroke;
                break;
            }

            case PXBorderStyleDouble:
            case PXBorderStyleGroove:
            case PXBorderStyleInset:
            case PXBorderStyleOutset:
            case PXBorderStyleRidge:
                break;

            // NOTE: We should never hit these cases
            case PXBorderStyleNone:
            case PXBorderStyleHidden:
            default:
                break;
        }
    }

    // bottom
    if (borderBottom_.hasContent)
    {
        borderPathBottom_ = [[PXPath alloc] init];

        switch (borderBottom_.style)
        {
            case PXBorderStyleSolid:
                [borderPathBottom_ moveToX:contentRight y:contentBottom];
                [borderPathBottom_ lineToX:borderRight y:borderBottom];
                [borderPathBottom_ lineToX:borderLeft y:borderBottom];
                [borderPathBottom_ lineToX:contentLeft y:contentBottom];
                [borderPathBottom_ close];
                borderPathBottom_.fill = borderBottom_.paint;
                break;

            case PXBorderStyleDashed:
            {
                CGFloat y = (borderBottom + contentBottom) * 0.5f;
                CGFloat width = borderBottom_.width;

                [borderPathBottom_ moveToX:borderLeft y:y];
                [borderPathBottom_ lineToX:borderRight y:y];

                PXStroke *stroke = [[PXStroke alloc] initWithStrokeWidth:width];
                stroke.color = borderBottom_.paint;
                stroke.dashArray = [self dashArrayFromLength:borderRight - borderLeft width:2.0f * width];
                borderPathBottom_.stroke = stroke;
                break;
            }

            case PXBorderStyleDotted:
            {
                CGFloat y = (borderBottom + contentBottom) * 0.5f;
                CGFloat width = borderBottom_.width;

                [borderPathBottom_ moveToX:borderLeft y:y];
                [borderPathBottom_ lineToX:borderRight y:y];

                PXStroke *stroke = [[PXStroke alloc] initWithStrokeWidth:width];
                stroke.color = borderBottom_.paint;
                stroke.dashArray = [self dashArrayFromLength:borderRight - borderLeft width:width];
                borderPathBottom_.stroke = stroke;
                break;
            }

            case PXBorderStyleDouble:
            case PXBorderStyleGroove:
            case PXBorderStyleInset:
            case PXBorderStyleOutset:
            case PXBorderStyleRidge:
                break;

            // NOTE: We should never hit these cases
            case PXBorderStyleNone:
            case PXBorderStyleHidden:
            default:
                break;
        }
    }

    // left
    if (borderLeft_.hasContent)
    {
        borderPathLeft_ = [[PXPath alloc] init];

        switch (borderLeft_.style)
        {
            case PXBorderStyleSolid:
                [borderPathLeft_ moveToX:contentLeft y:contentTop];
                [borderPathLeft_ lineToX:contentLeft y:contentBottom];
                [borderPathLeft_ lineToX:borderLeft y:borderBottom];
                [borderPathLeft_ lineToX:borderLeft y:borderTop];
                [borderPathLeft_ close];
                borderPathLeft_.fill = borderLeft_.paint;
                break;

            case PXBorderStyleDashed:
            {
                CGFloat x = (borderLeft + contentLeft) * 0.5f;
                CGFloat width = borderLeft_.width;

                [borderPathLeft_ moveToX:x y:borderTop];
                [borderPathLeft_ lineToX:x y:borderBottom];

                PXStroke *stroke = [[PXStroke alloc] initWithStrokeWidth:width];
                stroke.color = borderLeft_.paint;
                stroke.dashArray = [self dashArrayFromLength:borderBottom - borderTop width:2.0f * width];
                borderPathLeft_.stroke = stroke;
                break;
            }

            case PXBorderStyleDotted:
            {
                CGFloat x = (borderLeft + contentLeft) * 0.5f;
                CGFloat width = borderLeft_.width;

                [borderPathLeft_ moveToX:x y:borderTop];
                [borderPathLeft_ lineToX:x y:borderBottom];

                PXStroke *stroke = [[PXStroke alloc] initWithStrokeWidth:width];
                stroke.color = borderLeft_.paint;
                stroke.dashArray = [self dashArrayFromLength:borderBottom - borderTop width:width];
                borderPathLeft_.stroke = stroke;
                break;
            }

            case PXBorderStyleDouble:
            case PXBorderStyleGroove:
            case PXBorderStyleInset:
            case PXBorderStyleOutset:
            case PXBorderStyleRidge:
                break;

            // NOTE: We should never hit these cases
            case PXBorderStyleNone:
            case PXBorderStyleHidden:
            default:
                break;
        }
    }
}

- (NSArray *)dashArrayFromLength:(CGFloat)length width:(CGFloat)width;
{
    CGFloat minWidth = 1.75f * width;
    CGFloat count = (int) (length / minWidth);
    CGFloat spacing = (length - (count * width)) / (count - 1.0f);

    return @[@(width), @(spacing)];
}

- (void)renderChildren:(CGContextRef)context
{
    [borderPathTop_ render:context];
    [borderPathRight_ render:context];
    [borderPathBottom_ render:context];
    [borderPathLeft_ render:context];
}

@end
