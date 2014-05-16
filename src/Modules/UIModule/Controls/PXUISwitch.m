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
//  PXUISwitch.m
//  Pixate
//
//  Created by Paul Colton on 10/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXUISwitch.h"
#import <QuartzCore/QuartzCore.h>

#import "UIView+PXStyling.h"
#import "UIView+PXStyling-Private.h"
#import "PXStylingMacros.h"
#import "PXDeclaration.h"
#import "PXVirtualStyleableControl.h"
#import "PXUtils.h"
#import "PXRuleSet.h"

#import "PXOpacityStyler.h"
#import "PXLayoutStyler.h"
#import "PXTransformStyler.h"
#import "PXShapeStyler.h"
#import "PXFillStyler.h"
#import "PXBorderStyler.h"
#import "PXBoxShadowStyler.h"
#import "PXGenericStyler.h"
#import "PXAnimationStyler.h"

static char const STYLE_CHILDREN;

@implementation PXUISwitch

+ (void)initialize
{
    if (self != PXUISwitch.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"switch"];
}

- (NSArray *)pxStyleChildren
{
    if (!objc_getAssociatedObject(self, &STYLE_CHILDREN))
    {
        __weak id weakSelf = self;

        // thumb
        PXVirtualStyleableControl *thumb = [[PXVirtualStyleableControl alloc] initWithParent:self elementName:@"thumb"];
        thumb.viewStylers = @[
            [[PXGenericStyler alloc] initWithHandlers: @{
             @"color" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                if ([PXUtils isIOS6OrGreater])
                {
                    [weakSelf px_setThumbTintColor: declaration.colorValue];
                }
            },
            }],
        ];

        // on
        PXVirtualStyleableControl *on = [[PXVirtualStyleableControl alloc] initWithParent:self elementName:@"on" viewStyleUpdaterBlock:^(PXRuleSet *ruleSet, PXStylerContext *context) {

            if ([PXUtils isIOS6OrGreater] && context.backgroundImage)
            {
                [weakSelf px_setOnImage: context.backgroundImage];
            }
        }];
        on.viewStylers = @[
            PXShapeStyler.sharedInstance,
            PXFillStyler.sharedInstance,
            PXBorderStyler.sharedInstance,
            PXBoxShadowStyler.sharedInstance,
        ];

        // off
        PXVirtualStyleableControl *off = [[PXVirtualStyleableControl alloc] initWithParent:self elementName:@"off" viewStyleUpdaterBlock:^(PXRuleSet *ruleSet, PXStylerContext *context) {

            if ([PXUtils isIOS6OrGreater] && context.backgroundImage)
            {
                [weakSelf px_setOffImage: context.backgroundImage];
            }
        }];
        off.viewStylers = @[
            PXShapeStyler.sharedInstance,
            PXFillStyler.sharedInstance,
            PXBorderStyler.sharedInstance,
            PXBoxShadowStyler.sharedInstance,
        ];

        NSArray *styleChildren = @[ thumb, on, off ];

        objc_setAssociatedObject(self, &STYLE_CHILDREN, styleChildren, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    
    return [objc_getAssociatedObject(self, &STYLE_CHILDREN) arrayByAddingObjectsFromArray:self.subviews];
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
             @"-ios-tint-color" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXUISwitch *view = (PXUISwitch *)context.styleable;
                
                [view px_setTintColor: declaration.colorValue];
            },
             @"color" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXUISwitch *view = (PXUISwitch *)context.styleable;

                [view px_setOnTintColor: declaration.colorValue];
            },
             @"off-color" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXUISwitch *view = (PXUISwitch *)context.styleable;

                // iOS 6+
                if ([PXUtils isIOS6OrGreater])
                {
                    [view px_setTintColor: declaration.colorValue];
                }
            }
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
        //self.backgroundColor = [UIColor colorWithPatternImage:context.backgroundImage];
        self.px_layer.contents = (__bridge id)(context.backgroundImage.CGImage);
    }
}

// Px Wrapped Only
PX_PXWRAP_PROP(CALayer, layer);

// Ti Wrapped
PX_WRAP_1(setOnImage, image);
PX_WRAP_1(setOffImage, image);
PX_WRAP_1(setTintColor, color);
PX_WRAP_1(setThumbTintColor, color);
PX_WRAP_1(setOnTintColor, color);
PX_WRAP_1(setBackgroundColor, color);

// Styling
PX_LAYOUT_SUBVIEWS_OVERRIDE

@end
