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
//  PXUISegmentedControl.m
//  Pixate
//
//  Created by Paul Colton on 10/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXUISegmentedControl.h"

#import "UIView+PXStyling.h"
#import "UIView+PXStyling-Private.h"
#import "PXStylingMacros.h"
#import "PXVirtualStyleableControl.h"

#import "PXOpacityStyler.h"
#import "PXLayoutStyler.h"
#import "PXPaintStyler.h"
#import "PXFontStyler.h"
#import "PXTransformStyler.h"
#import "PXShapeStyler.h"
#import "PXFillStyler.h"
#import "PXBorderStyler.h"
#import "PXBoxShadowStyler.h"
#import "PXAnimationStyler.h"
#import "PXTextShadowStyler.h"

static NSDictionary *PSEUDOCLASS_MAP;
static char const STYLE_CHILDREN;

@implementation PXUISegmentedControl

+ (void)initialize
{
    if (self != PXUISegmentedControl.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"segmented-control"];

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
            if (context.backgroundImage)
            {
                [weakSelf px_setDividerImage:context.backgroundImage
                  forLeftSegmentState:UIControlStateNormal
                    rightSegmentState:UIControlStateNormal
                           barMetrics:UIBarMetricsDefault];
            }
        }];

        divider.viewStylers = @[
            PXShapeStyler.sharedInstance,
            PXFillStyler.sharedInstance,
            PXBorderStyler.sharedInstance,
            PXBoxShadowStyler.sharedInstance,
        ];

        NSArray *styleChildren = @[ divider ];

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

            [[PXTextShadowStyler alloc] initWithCompletionBlock:^(PXUISegmentedControl *view, PXTextShadowStyler *styler, PXStylerContext *context) {
                PXShadow *shadow = context.textShadow;
                NSMutableDictionary *currentTextAttributes = [NSMutableDictionary dictionaryWithDictionary:[view titleTextAttributesForState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]]];

                NSShadow *nsShadow = [[NSShadow alloc] init];
                
                nsShadow.shadowColor = shadow.color;
                nsShadow.shadowOffset = CGSizeMake(shadow.horizontalOffset, shadow.verticalOffset);
                nsShadow.shadowBlurRadius = shadow.blurDistance;
                
                [currentTextAttributes setObject:nsShadow forKey:NSShadowAttributeName];

                [view px_setTitleTextAttributes:currentTextAttributes forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
            }],

            [[PXFontStyler alloc] initWithCompletionBlock:^(PXUISegmentedControl *view, PXFontStyler *styler, PXStylerContext *context) {

                NSMutableDictionary *currentTextAttributes = [NSMutableDictionary
                                                              dictionaryWithDictionary:[view titleTextAttributesForState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]]];

                [currentTextAttributes setObject:context.font forKey:NSFontAttributeName];

                [view px_setTitleTextAttributes:currentTextAttributes
                                       forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
            }],

            [[PXPaintStyler alloc] initWithCompletionBlock:^(PXUISegmentedControl *view, PXPaintStyler *styler, PXStylerContext *context) {

                NSMutableDictionary *currentTextAttributes = [NSMutableDictionary
                                                              dictionaryWithDictionary:[view titleTextAttributesForState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]]];
                UIColor *color = (UIColor *)[context propertyValueForName:@"color"];

                if(color)
                {
                    [currentTextAttributes setObject:color forKey:NSForegroundColorAttributeName];

                    [view px_setTitleTextAttributes:currentTextAttributes
                                           forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
                }
                
                // Check for tint-color
                color = (UIColor *)[context propertyValueForName:@"-ios-tint-color"];
                if(color)
                {
                    [view px_setTintColor:color];
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
        [self px_setTintColor: context.color];
    }
    else if (context.usesImage)
    {
        [self px_setTintColor: nil];
        [self px_setBackgroundImage:context.backgroundImage
                        forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]
                      barMetrics:UIBarMetricsDefault];
    }
}

PX_WRAP_1(setTintColor, color);

PX_WRAP_2v(setBackgroundImage, image, forState, UIControlState, state);
PX_WRAP_2v(setTitleTextAttributes, attribs, forState, UIControlState, state);

PX_WRAP_3v(setBackgroundImage, image, forState, UIControlState, state, barMetrics, UIBarMetrics, metrics);

PX_WRAP_4v(setDividerImage, image, forLeftSegmentState, UIControlState, lstate, rightSegmentState, UIControlState, rstate,barMetrics, UIBarMetrics, metrics);


PX_LAYOUT_SUBVIEWS_OVERRIDE

@end
