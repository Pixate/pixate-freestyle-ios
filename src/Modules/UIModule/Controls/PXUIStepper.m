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
//  PXUIStepper.m
//  Pixate
//
//  Created by Paul Colton on 10/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXUIStepper.h"

#import "PXUtils.h"
#import "UIView+PXStyling.h"
#import "UIView+PXStyling-Private.h"
#import "PXStylingMacros.h"
#import "PXVirtualStyleableControl.h"

#import "PXOpacityStyler.h"
#import "PXLayoutStyler.h"
#import "PXTransformStyler.h"
#import "PXPaintStyler.h"
#import "PXShapeStyler.h"
#import "PXFillStyler.h"
#import "PXBorderStyler.h"
#import "PXBoxShadowStyler.h"
#import "PXAnimationStyler.h"

static NSDictionary *PSEUDOCLASS_MAP;
static char const STYLE_CHILDREN;

@implementation PXUIStepper

+ (void)initialize
{
    if (self != PXUIStepper.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"stepper"];
    
    PSEUDOCLASS_MAP = @{
        @"normal"      : @(UIControlStateNormal),
        @"highlighted" : @(UIControlStateHighlighted),
        @"selected"    : @(UIControlStateSelected),
        @"disabled"    : @(UIControlStateDisabled)
    };
}

#pragma mark - Pseudo-class State

- (NSArray *)supportedPseudoClasses
{
    return PSEUDOCLASS_MAP.allKeys;
}

- (NSString *)defaultPseudoClass
{
    return @"normal";
}

#pragma mark - Styling

- (NSArray *)pxStyleChildren
{
    if (!objc_getAssociatedObject(self, &STYLE_CHILDREN))
    {
        __weak id weakSelf = self;

        // divider
        PXVirtualStyleableControl *divider = [[PXVirtualStyleableControl alloc] initWithParent:self elementName:@"divider" viewStyleUpdaterBlock:^(PXRuleSet *ruleSet, PXStylerContext *context) {

            if ([PXUtils isIOS6OrGreater] && context.backgroundImage)
            {
                [weakSelf px_setDividerImage:context.backgroundImage
                  forLeftSegmentState:UIControlStateNormal
                    rightSegmentState:UIControlStateNormal];
            }
        }];
        
        divider.viewStylers = @[
            PXShapeStyler.sharedInstance,
            PXFillStyler.sharedInstance,
            PXBorderStyler.sharedInstance,
            PXBoxShadowStyler.sharedInstance,
        ];
        
        // increment
        PXVirtualStyleableControl *increment = [[PXVirtualStyleableControl alloc] initWithParent:self elementName:@"increment" viewStyleUpdaterBlock:^(PXRuleSet *ruleSet, PXStylerContext *context) {
            
            if ([PXUtils isIOS6OrGreater] && context.backgroundImage)
            {
                [weakSelf px_setIncrementImage:context.backgroundImage
                               forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
            }
        }];
        
        increment.viewStylers = @[
            PXShapeStyler.sharedInstance,
            PXFillStyler.sharedInstance,
            PXBorderStyler.sharedInstance,
            PXBoxShadowStyler.sharedInstance,
        ];

        
        // decrement
        PXVirtualStyleableControl *decrement = [[PXVirtualStyleableControl alloc] initWithParent:self elementName:@"decrement" viewStyleUpdaterBlock:^(PXRuleSet *ruleSet, PXStylerContext *context) {
            
            if ([PXUtils isIOS6OrGreater] && context.backgroundImage)
            {
                [weakSelf px_setDecrementImage:context.backgroundImage
                               forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
            }
        }];
        
        decrement.viewStylers = @[
            PXShapeStyler.sharedInstance,
            PXFillStyler.sharedInstance,
            PXBorderStyler.sharedInstance,
            PXBoxShadowStyler.sharedInstance,
        ];

        NSArray *styleChildren = @[ divider, increment, decrement ];
        
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

            [[PXPaintStyler alloc] initWithCompletionBlock:^(PXUIStepper *view, PXPaintStyler *styler, PXStylerContext *context) {
                
                if ([PXUtils isIOS6OrGreater])
                {
                    UIColor *color = (UIColor *)[context propertyValueForName:@"color"];
                    
                    if(color == nil)
                    {
                        color = (UIColor *)[context propertyValueForName:@"-ios-tint-color"];
                    }
                    
                    if(color)
                    {
                        [view px_setTintColor:color];
                    }
                }
            }],

            PXShapeStyler.sharedInstance,
            PXFillStyler.sharedInstance,
            PXBorderStyler.sharedInstance,
            PXBoxShadowStyler.sharedInstance,

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
    if ([PXUtils isIOS6OrGreater])
    {
        if(context.usesColorOnly || context.usesImage)
        {
            [self px_setTintColor: nil];
            [self px_setBackgroundImage:context.backgroundImage
                            forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
        }
    }

}

PX_WRAP_1(setTintColor, color);

PX_WRAP_2v(setIncrementImage, image, forState, UIControlState, state);
PX_WRAP_2v(setDecrementImage, image, forState, UIControlState, state);
PX_WRAP_2v(setBackgroundImage, image, forState, UIControlState, state);

PX_WRAP_3v(setDividerImage, image, forLeftSegmentState, UIControlState, lstate, rightSegmentState, UIControlState, rstate);


PX_LAYOUT_SUBVIEWS_OVERRIDE

@end
