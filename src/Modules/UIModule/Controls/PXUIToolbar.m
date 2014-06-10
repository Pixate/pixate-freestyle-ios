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
//  PXUIToolbar.m
//  Pixate
//
//  Created by Paul Colton on 10/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXUIToolbar.h"

#import "UIView+PXStyling.h"
#import "UIView+PXStyling-Private.h"
#import "PXStylingMacros.h"
#import "PXVirtualStyleableControl.h"
#import "UIBarButtonItem+PXStyling.h"
#import "UIBarButtonItem+PXStyling-Private.h"
#import "PXUtils.h"

#import "PXOpacityStyler.h"
#import "PXLayoutStyler.h"
#import "PXShapeStyler.h"
#import "PXFillStyler.h"
#import "PXBorderStyler.h"
#import "PXBoxShadowStyler.h"
#import "PXBarShadowStyler.h"
#import "PXAnimationStyler.h"
#import "PXGenericStyler.h"
#import "PXImageUtils.h"
#import "PXFontStyler.h"
#import "PXPaintStyler.h"

static const char STYLE_CHILDREN;
static NSDictionary *BUTTONS_PSEUDOCLASS_MAP;

@implementation PXUIToolbar

+ (void)initialize
{
    if (self != PXUIToolbar.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"toolbar"];
    
    BUTTONS_PSEUDOCLASS_MAP = @{
                                @"normal"      : @(UIControlStateNormal),
                                @"highlighted" : @(UIControlStateHighlighted),
                                @"disabled"    : @(UIControlStateDisabled)
                                };

}

- (NSArray *)pxStyleChildren
{
    // Get the children array
    NSArray *children = objc_getAssociatedObject(self, &STYLE_CHILDREN);
    
    if (!children)
    {
        //
        // button-appearance
        //
        
        PXVirtualStyleableControl *barButtons =
        [[PXVirtualStyleableControl alloc] initWithParent:self elementName:@"button-appearance"
                                    viewStyleUpdaterBlock:^(PXRuleSet *ruleSet, PXStylerContext *context)
         {
             [UIBarButtonItem UpdateStyleWithRuleSetHandler:ruleSet
                                                    context:context
                                                     target:[UIBarButtonItem appearanceWhenContainedIn:[UIToolbar class], nil]];
         }];
        
        barButtons.supportedPseudoClasses = BUTTONS_PSEUDOCLASS_MAP.allKeys;
        barButtons.defaultPseudoClass = @"normal";
        
        barButtons.viewStylers = @[
                                   PXOpacityStyler.sharedInstance,
                                   PXFillStyler.sharedInstance,
                                   PXBorderStyler.sharedInstance,
                                   PXShapeStyler.sharedInstance,
                                   PXBoxShadowStyler.sharedInstance,
                                   
                                   [[PXFontStyler alloc] initWithCompletionBlock:[UIBarButtonItem FontStylerCompletionBlock:[UIBarButtonItem appearanceWhenContainedIn:[UIToolbar class], nil]]],
                                   
                                   [[PXPaintStyler alloc] initWithCompletionBlock:[UIBarButtonItem PXPaintStylerCompletionBlock:[UIBarButtonItem appearanceWhenContainedIn:[UIToolbar class], nil]]],
                                   
                                   [[PXGenericStyler alloc] initWithHandlers: @{
                                        @"-ios-tint-color" : [UIBarButtonItem TintColorDeclarationHandlerBlock:[UIBarButtonItem appearanceWhenContainedIn:[UIToolbar class], nil]]
                                        }],
                                   ];
        children = @[ barButtons ];

        objc_setAssociatedObject(self, &STYLE_CHILDREN, children, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }

    for (UIBarButtonItem *item in self.items)
    {
        item.pxStyleParent = self;
    }
    
    // Add toolbar items
    NSMutableArray *allChildren = [[NSMutableArray alloc] initWithArray:[children arrayByAddingObjectsFromArray:self.items]];

    // Add any other subviews
    [allChildren addObjectsFromArray:self.subviews];
    
    return allChildren;
}

- (NSArray *)viewStylers
{
    static __strong NSArray *stylers = nil;
	static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        stylers = @[
            PXLayoutStyler.sharedInstance,

            [[PXOpacityStyler alloc] initWithCompletionBlock:^(PXUIToolbar *view, PXOpacityStyler *styler, PXStylerContext *context) {
                [view px_setTranslucent: (context.opacity < 1.0) ? YES : NO];
            }],

            PXShapeStyler.sharedInstance,
            PXFillStyler.sharedInstance,
            PXBorderStyler.sharedInstance,
            PXBoxShadowStyler.sharedInstance,

            // shadow-* image properties
            [[PXBarShadowStyler alloc] initWithCompletionBlock:^(PXUIToolbar *view, PXBarShadowStyler *styler, PXStylerContext *context) {
                // iOS 6.x property
                if ([PXUtils isIOS6OrGreater])
                {
                    if (context.shadowImage)
                    {
                        [view px_setShadowImage:context.shadowImage forToolbarPosition:UIToolbarPositionAny];
                    }
                    else
                    {
                        // 'fill' with a clear pixel
                        [view px_setShadowImage:PXImageUtils.clearPixel forToolbarPosition:UIToolbarPositionAny];
                    }
                }
                
            }],

            PXAnimationStyler.sharedInstance,
            
            [[PXGenericStyler alloc] initWithHandlers: @{
              @"-ios-tint-color" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXUIToolbar *view = (PXUIToolbar *)context.styleable;
                UIColor *color = declaration.colorValue;
                [view px_setTintColor:color];
            },
                                                         
                 @"color" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                    PXUIToolbar *view = (PXUIToolbar *)context.styleable;
                    UIColor *color = declaration.colorValue;
                    [view px_setTintColor:color];
                },
        }],
            
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
    if (context.color)
    {
        if([PXUtils isIOS7OrGreater])
        {
            [self px_setBarTintColor: context.color];
        }
        else
        {
            [self px_setTintColor: context.color];
        }
        
        [self px_setBackgroundImage:nil
                 forToolbarPosition:UIToolbarPositionAny
                         barMetrics:UIBarMetricsDefault];
    }
    
    if (context.usesImage)
    {
        [self px_setBackgroundColor: [UIColor clearColor]];
        [self px_setBackgroundImage:context.backgroundImage
                 forToolbarPosition:UIToolbarPositionAny
                         barMetrics:UIBarMetricsDefault];
    }
    
}

PX_LAYOUT_SUBVIEWS_OVERRIDE

PX_WRAP_1(setTintColor, color);
PX_WRAP_1(setBarTintColor, color);
PX_WRAP_1(setBackgroundColor, color);
PX_WRAP_1b(setTranslucent, flag);
PX_WRAP_2v(setShadowImage, image, forToolbarPosition, UIToolbarPosition, position);
PX_WRAP_3v(setBackgroundImage, image, forToolbarPosition, UIToolbarPosition, position, barMetrics, UIBarMetrics, metrics);

@end
