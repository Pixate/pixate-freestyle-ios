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
//  PXUIPageControl.m
//  Pixate
//
//  Created by Paul Colton on 10/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXUIPageControl.h"
#import <QuartzCore/QuartzCore.h>

#import "UIView+PXStyling.h"
#import "UIView+PXStyling-Private.h"
#import "PXStylingMacros.h"
#import "PXUtils.h"

#import "PXOpacityStyler.h"
#import "PXLayoutStyler.h"
#import "PXTransformStyler.h"
#import "PXShapeStyler.h"
#import "PXFillStyler.h"
#import "PXBorderStyler.h"
#import "PXBoxShadowStyler.h"
#import "PXGenericStyler.h"
#import "PXAnimationStyler.h"

@implementation PXUIPageControl

+ (void)initialize
{
    if (self != PXUIPageControl.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"page-control"];
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
             @"color" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXUIPageControl *view = (PXUIPageControl *)context.styleable;

                if ([PXUtils isIOS6OrGreater])
                {
                    [view px_setPageIndicatorTintColor: declaration.colorValue];
                }
            },
             @"current-color" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXUIPageControl *view = (PXUIPageControl *)context.styleable;

                if ([PXUtils isIOS6OrGreater])
                {
                    [view px_setCurrentPageIndicatorTintColor: declaration.colorValue];
                }
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
        [self px_setBackgroundColor: context.color];
    }
    else if (context.usesImage)
    {
        [self px_setBackgroundColor: [UIColor clearColor]];
        self.px_layer.contents = (__bridge id)(context.backgroundImage.CGImage);
    }
}

// Px Wrapped Only
PX_PXWRAP_PROP(CALayer, layer);

// Ti Wrapped
PX_WRAP_1(setBackgroundColor, color);
PX_WRAP_1(setPageIndicatorTintColor, color);
PX_WRAP_1(setCurrentPageIndicatorTintColor, color);

PX_LAYOUT_SUBVIEWS_OVERRIDE

@end
