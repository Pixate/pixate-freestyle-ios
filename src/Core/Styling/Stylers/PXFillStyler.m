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
//  PXFillStyler.m
//  Pixate
//
//  Created by Kevin Lindsey on 12/18/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXFillStyler.h"
#import "PXPaintGroup.h"
#import "NSArray+Reverse.h"

@implementation PXFillStyler

#pragma mark - Static Methods

+ (PXFillStyler *)sharedInstance
{
	static __strong PXFillStyler *sharedInstance = nil;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		sharedInstance = [[PXFillStyler alloc] init];
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
            @"background-color" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                context.fill = declaration.paintValue;
            },
            @"background-size" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                context.imageSize = declaration.sizeValue;
            },
            @"background-inset" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                context.insets = declaration.insetsValue;
            },
            @"background-inset-top" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                UIEdgeInsets insets = context.insets;
                CGFloat value = declaration.floatValue;

                context.insets = UIEdgeInsetsMake(value, insets.left, insets.bottom, insets.right);
            },
            @"background-inset-right" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                UIEdgeInsets insets = context.insets;
                CGFloat value = declaration.floatValue;

                context.insets = UIEdgeInsetsMake(insets.top, insets.left, insets.bottom, value);
            },
            @"background-inset-bottom" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                UIEdgeInsets insets = context.insets;
                CGFloat value = declaration.floatValue;

                context.insets = UIEdgeInsetsMake(insets.top, insets.left, value, insets.right);
            },
            @"background-inset-left" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                UIEdgeInsets insets = context.insets;
                CGFloat value = declaration.floatValue;

                context.insets = UIEdgeInsetsMake(insets.top, value, insets.bottom, insets.right);
            },
            @"background-image" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                id<PXPaint> paint = declaration.paintValue;

                if ([paint isKindOfClass:[PXPaintGroup class]])
                {
                    PXPaintGroup *group = (PXPaintGroup *) paint;

                    context.imageFill = [[PXPaintGroup alloc] initWithPaints:[group.paints reversedArray]];
                }
                else
                {
                    context.imageFill = declaration.paintValue;
                }
            },
            @"background-padding" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                context.padding = declaration.offsetsValue;
            },
            @"background-top-padding" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXOffsets *padding = [self paddingFromContext:context];
                CGFloat value = declaration.floatValue;

                context.padding = [[PXOffsets alloc] initWithTop:value right:padding.right bottom:padding.bottom left:padding.left];
            },
            @"background-right-padding" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXOffsets *padding = [self paddingFromContext:context];
                CGFloat value = declaration.floatValue;

                context.padding = [[PXOffsets alloc] initWithTop:padding.top right:value bottom:padding.bottom left:padding.left];
            },
            @"background-bottom-padding" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXOffsets *padding = [self paddingFromContext:context];
                CGFloat value = declaration.floatValue;

                context.padding = [[PXOffsets alloc] initWithTop:padding.top right:padding.right bottom:value left:padding.left];
            },
            @"background-left-padding" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXOffsets *padding = [self paddingFromContext:context];
                CGFloat value = declaration.floatValue;

                context.padding = [[PXOffsets alloc] initWithTop:padding.top right:padding.right bottom:padding.bottom left:value];
            },
        };
    });

    return handlers;
}

- (PXOffsets *)paddingFromContext:(PXStylerContext *)context
{
    PXOffsets *result = context.padding;

    if (!result)
    {
        result = [[PXOffsets alloc] init];
    }

    return result;
}

@end
