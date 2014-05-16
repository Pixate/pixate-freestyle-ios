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
//  PXUISlider.m
//  Pixate
//
//  Created by Paul Colton on 10/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXUISlider.h"

#import "UIView+PXStyling.h"
#import "UIView+PXStyling-Private.h"
#import "PXStylingMacros.h"
#import "PXVirtualStyleableControl.h"

#import "PXOpacityStyler.h"
#import "PXFillStyler.h"
#import "PXBorderStyler.h"
#import "PXLayoutStyler.h"
#import "PXTransformStyler.h"
#import "PXShapeStyler.h"
#import "PXFillStyler.h"
#import "PXBorderStyler.h"
#import "PXBoxShadowStyler.h"
#import "PXGenericStyler.h"
#import "PXAnimationStyler.h"

static const char STYLE_CHILDREN;
static NSDictionary *PSEUDOCLASS_MAP;

@implementation PXUISlider

#pragma mark - Static methods

+ (void)initialize
{
    if (self != PXUISlider.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"slider"];
    
    PSEUDOCLASS_MAP = @{
        @"normal"      : @(UIControlStateNormal),
        @"highlighted" : @(UIControlStateHighlighted),
        @"selected"    : @(UIControlStateSelected),
        @"disabled"    : @(UIControlStateDisabled)
    };
}

- (NSArray *)pxStyleChildren
{
    if (!objc_getAssociatedObject(self, &STYLE_CHILDREN))
    {
        __weak PXUISlider *weakSelf = self;
        
        // thumb
        PXVirtualStyleableControl *thumb = [[PXVirtualStyleableControl alloc] initWithParent:self elementName:@"thumb" viewStyleUpdaterBlock:^(PXRuleSet *ruleSet, PXStylerContext *context) {
            if (context.usesImage)
            {
                [weakSelf px_setThumbImage:context.backgroundImage
                              forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
            }
        }];

        thumb.viewStylers = @[
            PXShapeStyler.sharedInstance,
            PXFillStyler.sharedInstance,
            PXBorderStyler.sharedInstance,
            PXBoxShadowStyler.sharedInstance,
            [[PXGenericStyler alloc] initWithHandlers: @{
             @"color" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                [weakSelf px_setThumbTintColor: declaration.colorValue];
            },
            }],
        ];
        thumb.supportedPseudoClasses = PSEUDOCLASS_MAP.allKeys;
        thumb.defaultPseudoClass = @"normal";

        // min-track
        PXVirtualStyleableControl *minTrack = [[PXVirtualStyleableControl alloc] initWithParent:self elementName:@"min-track" viewStyleUpdaterBlock:^(PXRuleSet *ruleSet, PXStylerContext *context) {
            if (context.usesImage)
            {
                [weakSelf px_setMinimumTrackImage:context.backgroundImage
                                     forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
            }
        }];

        minTrack.viewStylers = @[
            PXFillStyler.sharedInstance,
            PXBorderStyler.sharedInstance,
            [[PXGenericStyler alloc] initWithHandlers: @{
             @"color" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                [weakSelf px_setMinimumTrackTintColor: declaration.colorValue];
            },
            }],
        ];
        minTrack.supportedPseudoClasses = PSEUDOCLASS_MAP.allKeys;
        minTrack.defaultPseudoClass = @"normal";

        // max-track
        PXVirtualStyleableControl *maxTrack = [[PXVirtualStyleableControl alloc] initWithParent:self elementName:@"max-track" viewStyleUpdaterBlock:^(PXRuleSet *ruleSet, PXStylerContext *context) {
            if (context.usesImage)
            {
                [weakSelf px_setMaximumTrackImage:context.backgroundImage forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
            }
        }];
        maxTrack.viewStylers = @[
            PXFillStyler.sharedInstance,
            PXBorderStyler.sharedInstance,
            [[PXGenericStyler alloc] initWithHandlers: @{
             @"color" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                [weakSelf px_setMaximumTrackTintColor: declaration.colorValue];
            },
            }],
        ];
        maxTrack.supportedPseudoClasses = PSEUDOCLASS_MAP.allKeys;
        maxTrack.defaultPseudoClass = @"normal";

        // min-value
        PXVirtualStyleableControl *minValue = [[PXVirtualStyleableControl alloc] initWithParent:self elementName:@"min-value" viewStyleUpdaterBlock:^(PXRuleSet *ruleSet, PXStylerContext *context) {
            if (context.usesImage)
            {
                [weakSelf px_setMinimumValueImage:context.backgroundImage];
            }

        }];
        minValue.viewStylers = @[
            PXShapeStyler.sharedInstance,
            PXFillStyler.sharedInstance,
            PXBorderStyler.sharedInstance,
            PXBoxShadowStyler.sharedInstance,
        ];
        
        // max-value
        PXVirtualStyleableControl *maxValue = [[PXVirtualStyleableControl alloc] initWithParent:self elementName:@"max-value" viewStyleUpdaterBlock:^(PXRuleSet *ruleSet, PXStylerContext *context) {
            if (context.usesImage)
            {
                [weakSelf px_setMaximumValueImage:context.backgroundImage];
            }
        }];
        maxValue.viewStylers = @[
            PXShapeStyler.sharedInstance,
            PXFillStyler.sharedInstance,
            PXBorderStyler.sharedInstance,
            PXBoxShadowStyler.sharedInstance,
        ];
        
        NSArray *styleChildren = @[ minTrack, maxTrack, thumb, minValue, maxValue ];

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
        [self px_setBackgroundColor: [UIColor colorWithPatternImage:context.backgroundImage]];
    }
}

PX_WRAP_1(setBackgroundColor, color);
PX_WRAP_1(setMinimumValueImage, image);
PX_WRAP_1(setMaximumValueImage, image);
PX_WRAP_1(setMaximumTrackTintColor, color);
PX_WRAP_1(setMinimumTrackTintColor, color);
PX_WRAP_1(setThumbTintColor, color);

PX_WRAP_2v(setMaximumTrackImage, image, forState, UIControlState, state);
PX_WRAP_2v(setMinimumTrackImage, image, forState, UIControlState, state);
PX_WRAP_2v(setThumbImage, image, forState, UIControlState, state);

PX_LAYOUT_SUBVIEWS_OVERRIDE

@end
