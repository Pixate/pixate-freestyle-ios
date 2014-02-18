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
//  PXBorderStyler.m
//  Pixate
//
//  Created by Kevin Lindsey on 12/18/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXBorderStyler.h"
#import "PXPaint.h"
#import "PXStroke.h"
#import "PXRectangle.h"
#import "PXValue.h"

@implementation PXBorderStyler

#pragma mark - Static Methods

+ (PXBorderStyler *)sharedInstance
{
	static __strong PXBorderStyler *sharedInstance = nil;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		sharedInstance = [[PXBorderStyler alloc] init];
	});

	return sharedInstance;
}

#pragma mark - Overrides

- (NSDictionary *)declarationHandlers
{
    static __strong NSDictionary *handlers = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        handlers = @{
            @"border" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXBorderInfo *settings = declaration.borderValue;

                [context.boxModel setBorderWidth:settings.width];
                [context.boxModel setBorderStyle:settings.style];
                [context.boxModel setBorderPaint:settings.paint];
            },
            @"border-top" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXBorderInfo *settings = declaration.borderValue;

                [context.boxModel setBorderTopWidth:settings.width];
                [context.boxModel setBorderTopStyle:settings.style];
                [context.boxModel setBorderTopPaint:settings.paint];
            },
            @"border-right" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXBorderInfo *settings = declaration.borderValue;

                [context.boxModel setBorderRightWidth:settings.width];
                [context.boxModel setBorderRightStyle:settings.style];
                [context.boxModel setBorderRightPaint:settings.paint];
            },
            @"border-bottom" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXBorderInfo *settings = declaration.borderValue;

                [context.boxModel setBorderBottomWidth:settings.width];
                [context.boxModel setBorderBottomStyle:settings.style];
                [context.boxModel setBorderBottomPaint:settings.paint];
            },
            @"border-left" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXBorderInfo *settings = declaration.borderValue;

                [context.boxModel setBorderLeftWidth:settings.width];
                [context.boxModel setBorderLeftStyle:settings.style];
                [context.boxModel setBorderLeftPaint:settings.paint];
            },

            @"border-radius" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                NSArray *radii = declaration.borderRadiiList;

                context.boxModel.radiusTopLeft = [(NSValue *)[radii objectAtIndex:0] CGSizeValue];
                context.boxModel.radiusTopRight = [(NSValue *)[radii objectAtIndex:1] CGSizeValue];
                context.boxModel.radiusBottomRight = [(NSValue *)[radii objectAtIndex:2] CGSizeValue];
                context.boxModel.radiusBottomLeft = [(NSValue *)[radii objectAtIndex:3] CGSizeValue];
            },
            @"border-top-left-radius" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                context.boxModel.radiusTopLeft = declaration.sizeValue;
            },
            @"border-top-right-radius" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                context.boxModel.radiusTopRight = declaration.sizeValue;
            },
            @"border-bottom-right-radius" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                context.boxModel.radiusBottomRight = declaration.sizeValue;
            },
            @"border-bottom-left-radius" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                context.boxModel.radiusBottomLeft = declaration.sizeValue;
            },

            @"border-width" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXOffsets *widths = declaration.offsetsValue;

                context.boxModel.borderTopWidth = widths.top;
                context.boxModel.borderRightWidth = widths.right;
                context.boxModel.borderBottomWidth = widths.bottom;
                context.boxModel.borderLeftWidth = widths.left;
            },
            @"border-top-width" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                CGFloat width = declaration.floatValue;

                context.boxModel.borderTopWidth = width;
            },
            @"border-right-width" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                CGFloat width = declaration.floatValue;

                context.boxModel.borderRightWidth = width;
            },
            @"border-bottom-width" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                CGFloat width = declaration.floatValue;

                context.boxModel.borderBottomWidth = width;
            },
            @"border-left-width" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                CGFloat width = declaration.floatValue;

                context.boxModel.borderLeftWidth = width;
            },

            @"border-color" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                NSArray *paints = declaration.paintList;

                context.boxModel.borderTopPaint = [paints objectAtIndex:0];
                context.boxModel.borderRightPaint = [paints objectAtIndex:1];
                context.boxModel.borderBottomPaint = [paints objectAtIndex:2];
                context.boxModel.borderLeftPaint = [paints objectAtIndex:3];
            },
            @"border-top-color" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                id<PXPaint> paint = declaration.paintValue;

                context.boxModel.borderTopPaint = paint;
            },
            @"border-right-color" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                id<PXPaint> paint = declaration.paintValue;

                context.boxModel.borderRightPaint = paint;
            },
            @"border-bottom-color" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                id<PXPaint> paint = declaration.paintValue;

                context.boxModel.borderBottomPaint = paint;
            },
            @"border-left-color" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                id<PXPaint> paint = declaration.paintValue;

                context.boxModel.borderLeftPaint = paint;
            },

            @"border-style" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                NSArray *styles = declaration.borderStyleList;

                context.boxModel.borderTopStyle = [(PXValue *)[styles objectAtIndex:0] PXBorderStyleValue];
                context.boxModel.borderRightStyle = [(PXValue *)[styles objectAtIndex:1] PXBorderStyleValue];
                context.boxModel.borderBottomStyle = [(PXValue *)[styles objectAtIndex:2] PXBorderStyleValue];
                context.boxModel.borderLeftStyle = [(PXValue *)[styles objectAtIndex:3] PXBorderStyleValue];
            },
            @"border-top-style" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXBorderStyle style = declaration.borderStyleValue;

                context.boxModel.borderTopStyle = style;
            },
            @"border-right-style" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXBorderStyle style = declaration.borderStyleValue;

                context.boxModel.borderRightStyle = style;
            },
            @"border-bottom-style" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXBorderStyle style = declaration.borderStyleValue;

                context.boxModel.borderBottomStyle = style;
            },
            @"border-left-style" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXBorderStyle style = declaration.borderStyleValue;

                context.boxModel.borderLeftStyle = style;
            },
        };
    });

    return handlers;
}

@end
