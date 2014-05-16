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
//  UITabBarItem+PXStyling.m
//  Pixate
//
//  Created by Kevin Lindsey on 10/31/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "UITabBarItem+PXStyling.h"
#import <objc/runtime.h>
#import "PXShapeStyler.h"
#import "PXFillStyler.h"
#import "PXBorderStyler.h"
#import "PXBoxShadowStyler.h"
#import "PXFontStyler.h"
#import "PXColorStyler.h"
#import "PXTextContentStyler.h"
#import "PXStyleUtils.h"
#import "PXStylingMacros.h"
#import "UIBarItem+PXStyling.h"
#import "PXAttributedTextStyler.h"

void PXForceLoadUITabBarItemPXStyling() {}

@implementation UITabBarItem (PXStyling)

@dynamic isVirtualControl;
@dynamic pxStyleParent;

static NSDictionary *PSEUDOCLASS_MAP;

+ (void)initialize
{
    if (self != UITabBarItem.class)
        return;
    
    PSEUDOCLASS_MAP = @{
        @"normal" : @(UIControlStateNormal),
        @"selected" : @(UIControlStateHighlighted),
        @"unselected" : @(UIControlStateNormal)
    };
}

- (NSString *)pxStyleElementName
{
    return self.styleElementName == nil ? @"tab-bar-item" : self.styleElementName;
}
    
- (void)setPxStyleElementName:(NSString *)pxStyleElementName
{
    self.styleElementName = pxStyleElementName;
}
    
- (NSArray *)pxStyleChildren
{
    return nil;
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

- (NSArray *)viewStylers
{
    static __strong NSArray *stylers = nil;
	static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        stylers = @[

            PXShapeStyler.sharedInstance,
            PXFillStyler.sharedInstance,
            PXBorderStyler.sharedInstance,
            PXBoxShadowStyler.sharedInstance,

            [[PXAttributedTextStyler alloc] initWithCompletionBlock:^(UIBarButtonItem *view, PXAttributedTextStyler *styler, PXStylerContext *context) {
                
                UIControlState state = ([context stateFromStateNameMap:PSEUDOCLASS_MAP]) ? [context stateFromStateNameMap:PSEUDOCLASS_MAP] : UIControlStateNormal;
                
                NSDictionary *attribs = [view titleTextAttributesForState:state];
                
                NSDictionary *mergedAttribs = [context mergeTextAttributes:attribs];
                
                [view setTitleTextAttributes:mergedAttribs
                                    forState:state];
            }],
            
            [[PXTextContentStyler alloc] initWithCompletionBlock:^(UIBarButtonItem *view, PXTextContentStyler *styler, PXStylerContext *context) {
                [view setTitle: context.text];
            }],
        ];
    });

	return stylers;
}

- (void)updateStyleWithRuleSet:(PXRuleSet *)ruleSet context:(PXStylerContext *)context
{
    if([context.activeStateName isEqualToString:@"normal"])
    {
        if (context.usesImage)
        {
            [self setImage:context.backgroundImage];
        }
    }
    else if([context.activeStateName isEqualToString:@"selected"])
    {
        if (context.usesImage)
        {
            self.selectedImage = context.backgroundImage;
        }
    }
    else if([context.activeStateName isEqualToString:@"unselected"])
    {
        if (context.usesImage)
        {
            self.image = context.backgroundImage;
        }
    }
}

@end
