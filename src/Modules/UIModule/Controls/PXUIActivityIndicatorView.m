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
//  PXUIActivityIndicatorView.m
//  Pixate
//
//  Created by Paul Colton on 10/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXUIActivityIndicatorView.h"
#import <QuartzCore/QuartzCore.h>

#import "UIView+PXStyling.h"
#import "UIView+PXStyling-Private.h"
#import "PXStylingMacros.h"
#import "PXOpacityStyler.h"
#import "PXShapeStyler.h"
#import "PXFillStyler.h"
#import "PXBorderStyler.h"
#import "PXBoxShadowStyler.h"
#import "PXLayoutStyler.h"
#import "PXTransformStyler.h"
#import "PXGenericStyler.h"
#import "PXAnimationStyler.h"

@implementation PXUIActivityIndicatorView

+ (void)initialize
{
    if (self != PXUIActivityIndicatorView.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"activity-indicator-view"];
}

- (NSArray *)viewStylers
{
    static __strong NSArray *stylers = nil;
	static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        stylers = @[
            PXTransformStyler.sharedInstance,
            PXOpacityStyler.sharedInstance,
            PXLayoutStyler.sharedInstance,

            PXShapeStyler.sharedInstance,
            PXFillStyler.sharedInstance,
            PXBorderStyler.sharedInstance,
            PXBoxShadowStyler.sharedInstance,

            [[PXGenericStyler alloc] initWithHandlers: @{
             @"color" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXUIActivityIndicatorView *view = (PXUIActivityIndicatorView *)context.styleable;

                [view px_setColor:declaration.colorValue];
            },
             @"style" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXUIActivityIndicatorView *view = (PXUIActivityIndicatorView *)context.styleable;
                NSString *style = [declaration.stringValue lowercaseString];

                if ([style isEqualToString:@"large"])
                {
                    [view px_setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
                }
                else if ([style isEqualToString:@"small-gray"])
                {
                    [view px_setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
                }
                else //default: if([style isEqualToString:@"small"])
                {
                    [view px_setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
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
        [self px_setBackgroundColor:context.color];
        self.px_layer.contents = nil;
    }
    else if (context.usesImage)
    {
        [self px_setBackgroundColor:[UIColor clearColor]];
        self.px_layer.contents = (__bridge id)(context.backgroundImage.CGImage);
    }
}


// Px Wrapped Only
PX_PXWRAP_PROP(CALayer, layer);

// Ti Wrapped
PX_WRAP_1(setColor, color);
PX_WRAP_1(setBackgroundColor, color);
PX_WRAP_1v(setActivityIndicatorViewStyle, UIActivityIndicatorViewStyle, style);

PX_LAYOUT_SUBVIEWS_OVERRIDE

@end
