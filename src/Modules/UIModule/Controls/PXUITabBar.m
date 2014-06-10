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
//  PXUITabBar.m
//  Pixate
//
//  Created by Paul Colton on 10/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXUITabBar.h"
#import <QuartzCore/QuartzCore.h>

#import "UIView+PXStyling.h"
#import "UIView+PXStyling-Private.h"
#import "PXStylingMacros.h"
#import "UITabBarItem+PXStyling.h"
#import "PXUtils.h"

#import "PXLayoutStyler.h"
#import "PXTransformStyler.h"
#import "PXOpacityStyler.h"
#import "PXBarShadowStyler.h"
#import "PXShapeStyler.h"
#import "PXFillStyler.h"
#import "PXBorderStyler.h"
#import "PXBoxShadowStyler.h"
#import "PXVirtualStyleableControl.h"
#import "PXGenericStyler.h"
#import "PXAnimationStyler.h"
#import "PXImageUtils.h"

@implementation PXUITabBar

+ (void)initialize
{
    if (self != PXUITabBar.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"tab-bar"];
}

- (NSArray *)pxStyleChildren
{
    __weak id weakSelf = self;

    // selection
    PXVirtualStyleableControl *selection = [[PXVirtualStyleableControl alloc] initWithParent:self elementName:@"selection" viewStyleUpdaterBlock:^(PXRuleSet *ruleSet, PXStylerContext *context) {
        UIImage *image = context.backgroundImage;

        if (image)
        {
            [weakSelf px_setSelectionIndicatorImage: image];
        }
    }];

    selection.viewStylers = @[
        PXShapeStyler.sharedInstance,
        PXFillStyler.sharedInstance,
        PXBorderStyler.sharedInstance,
        PXBoxShadowStyler.sharedInstance,
    ];


    for (UITabBarItem *item in self.items)
    {
        item.pxStyleParent = self;
    }

    // Add all of the 'items' from the tabbar
    NSMutableArray *styleChildren = [[NSMutableArray alloc] initWithArray:self.items];
    
    // Add the virtual child
    [styleChildren addObject:selection];

    // Add any other subviews
    [styleChildren addObjectsFromArray:self.subviews];

    return styleChildren;
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

            // shadow-* image properties
            [[PXBarShadowStyler alloc] initWithCompletionBlock:^(PXUITabBar *view, PXBarShadowStyler *styler, PXStylerContext *context) {
                // iOS 6.x property
                if ([PXUtils isIOS6OrGreater])
                {
                    if (context.shadowImage)
                    {
                        [view px_setShadowImage:context.shadowImage];
                    }
                    else
                    {
                        // 'fill' with a clear pixel
                        [view px_setShadowImage:PXImageUtils.clearPixel];
                    }
                }
            }],

            [[PXGenericStyler alloc] initWithHandlers: @{
             @"-ios-tint-color" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXUITabBar *view = (PXUITabBar *)context.styleable;
                
                [view px_setTintColor: declaration.colorValue];
            },
             @"color" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXUITabBar *view = (PXUITabBar *)context.styleable;

                [view px_setTintColor: declaration.colorValue];
            },
             @"selected-color" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXUITabBar *view = (PXUITabBar *)context.styleable;

                [view px_setSelectedImageTintColor: declaration.colorValue];
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
    if (context.usesColorOnly || context.usesImage)
    {
        if (context.usesColorOnly && [PXUtils isIOS7OrGreater])
        {
            [self px_setBarTintColor:context.color];
        }
        else
        {
            [self px_setBackgroundImage: context.backgroundImage];
        }
    }
    else
    {
        [self px_setBackgroundImage: nil];
    }
}

PX_WRAP_1(setBarTintColor, color);
PX_WRAP_1(setTintColor, color);
PX_WRAP_1(setSelectedImageTintColor, color);
PX_WRAP_1(setBackgroundImage, image);
PX_WRAP_1(setShadowImage, image);
PX_WRAP_1(setSelectionIndicatorImage, image);


PX_LAYOUT_SUBVIEWS_OVERRIDE

@end
