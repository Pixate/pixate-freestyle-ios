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
//  PXBoxModel.h
//  Pixate
//
//  Created by Kevin Lindsey on 3/25/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXShape.h"
#import "PXBoundable.h"
#import "PXBorderInfo.h"

typedef enum {
    PXBoxSizingContentBox,
    PXBoxSizingPaddingBox,
    PXBoxSizingBorderBox
} PXBoxSizing;

@interface PXBoxModel : PXShape <PXBoundable>

@property (nonatomic) id<PXPaint> borderTopPaint;
@property (nonatomic) CGFloat borderTopWidth;
@property (nonatomic) PXBorderStyle borderTopStyle;

@property (nonatomic) id<PXPaint> borderRightPaint;
@property (nonatomic) CGFloat borderRightWidth;
@property (nonatomic) PXBorderStyle borderRightStyle;

@property (nonatomic) id<PXPaint> borderBottomPaint;
@property (nonatomic) CGFloat borderBottomWidth;
@property (nonatomic) PXBorderStyle borderBottomStyle;

@property (nonatomic) id<PXPaint> borderLeftPaint;
@property (nonatomic) CGFloat borderLeftWidth;
@property (nonatomic) PXBorderStyle borderLeftStyle;

@property (nonatomic) CGSize radiusTopLeft;
@property (nonatomic) CGSize radiusTopRight;
@property (nonatomic) CGSize radiusBottomRight;
@property (nonatomic) CGSize radiusBottomLeft;

@property (nonatomic, readonly) CGRect borderBounds;
@property (nonatomic, readonly) CGRect contentBounds;

@property (nonatomic) PXOffsets *padding;
@property (nonatomic) PXBoxSizing boxSizing;

- (id)initWithBounds:(CGRect)bounds;

- (BOOL)hasBorder;

- (BOOL)hasCornerRadius;

- (BOOL)isOpaque;

/**
 *  Set the corner radius of all corners to the specified value
 *
 *  @param radius A corner radius
 */
- (void)setCornerRadius:(CGFloat)radius;

/**
 *  Set the corner radius of all corners to the specified value
 *
 *  @param radii The x and y radii
 */
- (void)setCornerRadii:(CGSize)radii;

- (void)setBorderPaint:(id<PXPaint>)paint;
- (void)setBorderWidth:(CGFloat)width;
- (void)setBorderStyle:(PXBorderStyle)style;
- (void)setBorderPaint:(id<PXPaint>)paint width:(CGFloat)width style:(PXBorderStyle)style;

- (void)setBorderTopPaint:(id<PXPaint>)paint width:(CGFloat)width style:(PXBorderStyle)style;
- (void)setBorderRightPaint:(id<PXPaint>)paint width:(CGFloat)width style:(PXBorderStyle)style;
- (void)setBorderBottomPaint:(id<PXPaint>)paint width:(CGFloat)width style:(PXBorderStyle)style;
- (void)setBorderLeftPaint:(id<PXPaint>)paint width:(CGFloat)width style:(PXBorderStyle)style;

@end
