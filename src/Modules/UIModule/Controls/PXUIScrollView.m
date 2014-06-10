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
//  PXUIScrollView.m
//  Pixate
//
//  Created by Paul Colton on 10/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXUIScrollView.h"
#import <QuartzCore/QuartzCore.h>

#import "UIView+PXStyling.h"
#import "UIView+PXStyling-Private.h"
#import "PXStylingMacros.h"

#import "PXOpacityStyler.h"
#import "PXLayoutStyler.h"
#import "PXTransformStyler.h"
#import "PXShapeStyler.h"
#import "PXFillStyler.h"
#import "PXBorderStyler.h"
#import "PXBoxShadowStyler.h"
#import "PXGenericStyler.h"
#import "PXAnimationStyler.h"

@implementation PXUIScrollView

+ (void)initialize
{
    if (self != PXUIScrollView.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"scroll-view"];
}

- (NSArray *)viewStylers
{
    static __strong NSArray *stylers = nil;
	static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        stylers = @[
            PXTransformStyler.sharedInstance,
            PXLayoutStyler.sharedInstance,
            PXOpacityStyler.sharedInstance,

            PXShapeStyler.sharedInstance,
            PXFillStyler.sharedInstance,
            PXBorderStyler.sharedInstance,
            PXBoxShadowStyler.sharedInstance,

            [[PXGenericStyler alloc] initWithHandlers: @{
             @"content-offset" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXUIScrollView *view = (PXUIScrollView *)context.styleable;
                CGSize point = declaration.sizeValue;

                [view px_setContentOffset: CGPointMake(point.width, point.height)];
            },
             @"content-size" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXUIScrollView *view = (PXUIScrollView *)context.styleable;
                CGSize size = declaration.sizeValue;

                [view px_setContentSize: size];
            },
             @"content-inset" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXUIScrollView *view = (PXUIScrollView *)context.styleable;
                UIEdgeInsets insets = declaration.insetsValue;

                [view px_setContentInset: insets];
            },
            }],

            PXAnimationStyler.sharedInstance,
        ];
    });

	return stylers;
}

- (NSDictionary *)viewStylersByProperty
{
    static NSDictionary *map = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        map = [PXStyleUtils viewStylerPropertyMapForStyleable:self];
    });

    return map;
}

- (void)updateStyleWithRuleSet:(PXRuleSet *)ruleSet context:(PXStylerContext *)context
{
    if (context.usesColorOnly)
    {
        [self setBackgroundColor: context.color];
        self.px_layer.contents = nil;
    }
    else if (context.usesImage)
    {
        [self setBackgroundColor: [UIColor clearColor]];
        self.px_layer.contents = (__bridge id)(context.backgroundImage.CGImage);
    }
}

// Px Wrapped Only
PX_PXWRAP_PROP(CALayer, layer);

// Ti Wrapped
PX_WRAP_1(setBackgroundColor, color);
PX_WRAP_1s(setContentSize,   CGSize,       size);
PX_WRAP_1s(setContentOffset, CGPoint,      size);
PX_WRAP_1s(setContentInset,  UIEdgeInsets, insets);

// Styling
PX_LAYOUT_SUBVIEWS_OVERRIDE

@end
