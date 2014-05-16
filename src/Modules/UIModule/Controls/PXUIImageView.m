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
//  PXUIImageView.m
//  Pixate
//
//  Created by Paul Colton on 9/18/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXUIImageView.h"

#import "UIView+PXStyling.h"
#import "UIView+PXStyling-Private.h"
#import "PXStylingMacros.h"

#import "PXOpacityStyler.h"
#import "PXFillStyler.h"
#import "PXBorderStyler.h"
#import "PXBoxShadowStyler.h"
#import "PXLayoutStyler.h"
#import "PXTransformStyler.h"
#import "PXShapeStyler.h"
#import "PXBorderStyler.h"
#import "PXBoxShadowStyler.h"
#import "PXAnimationStyler.h"
#import "PXPaintStyler.h"
#import "PXGenericStyler.h"
#import "PXUtils.h"

static NSDictionary *PSEUDOCLASS_MAP;

@implementation PXUIImageView

+ (void)initialize
{
    if (self != PXUIImageView.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"image-view"];

    PSEUDOCLASS_MAP = @{
        @"normal"      : @(UIControlStateNormal),
        @"highlighted" : @(UIControlStateHighlighted),
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
            
            PXPaintStyler.sharedInstanceForTintColor,
            
            [[PXGenericStyler alloc] initWithHandlers: @{
                                                         
            @"-ios-rendering-mode" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                
                NSString *mode = [declaration.stringValue lowercaseString];
                
                if([mode isEqualToString:@"original"])
                {
                    [context setPropertyValue:@"original" forName:@"rendering-mode"];
                }
                else if([mode isEqualToString:@"template"])
                {
                    [context setPropertyValue:@"template" forName:@"rendering-mode"];
                }
                else
                {
                    [context setPropertyValue:@"automatic" forName:@"rendering-mode"];
                }
            }}],
            
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
    UIImage *image = context.backgroundImage;
    
    if([PXUtils isIOS7OrGreater])
    {
        NSString *renderingMode = [context propertyValueForName:@"rendering-mode"];
        
        if(renderingMode)
        {
            if([renderingMode isEqualToString:@"original"])
            {
                image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            }
            else if([renderingMode isEqualToString:@"template"])
            {
                image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            }
            else
            {
                image = [image imageWithRenderingMode:UIImageRenderingModeAutomatic];
            }
        }
    }

    if([context stateFromStateNameMap:PSEUDOCLASS_MAP] == UIControlStateHighlighted)
    {
        [self px_setHighlightedImage:image];
    }
    else if (context.usesImage)
    {
        [self px_setImage:image];
    }
    
    // TODO: support animated images
}

PX_WRAP_1(setImage, image);
PX_WRAP_1(setHighlightedImage, image);

PX_LAYOUT_SUBVIEWS_OVERRIDE

@end
