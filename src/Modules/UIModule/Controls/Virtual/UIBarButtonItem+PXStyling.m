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
//  UIBarButtonItem+PXStyling.m
//  Pixate
//
//  Created by Kevin Lindsey on 12/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "UIBarButtonItem+PXStyling.h"
#import <objc/runtime.h>
#import "PXFillStyler.h"
#import "PXBorderStyler.h"
#import "PXTextContentStyler.h"
#import "PXStylingMacros.h"
#import "PXStyleUtils.h"
#import "PXShapeStyler.h"
#import "PXLayoutStyler.h"

#import "PXBarMetricsAdjustmentStyler.h"
#import "PXTransformStyler.h"
#import "PXOpacityStyler.h"
#import "PXFontStyler.h"
#import "PXPaintStyler.h"
#import "PXLayoutStyler.h"
#import "PXShapeStyler.h"
#import "PXFillStyler.h"
#import "PXBorderStyler.h"
#import "PXBoxShadowStyler.h"
#import "PXBarShadowStyler.h"
#import "PXAnimationStyler.h"
#import "PXTextShadowStyler.h"
#import "PXGenericStyler.h"
#import "PXAttributedTextStyler.h"

#import "PXUtils.h"
#import "PXVirtualStyleableControl.h"

#import "UIBarItem+PXStyling.h"

static const char STYLE_CHILDREN;
static NSDictionary *BUTTONS_PSEUDOCLASS_MAP;

void PXForceLoadUIBarButtonItemPXStyling() {}

@implementation UIBarButtonItem (PXStyling)

@dynamic isVirtualControl;
@dynamic pxStyleParent;

+ (void)initialize
{
    if (self != UIBarButtonItem.class)
        return;
    
    BUTTONS_PSEUDOCLASS_MAP = @{
                                @"normal"      : @(UIControlStateNormal),
                                @"highlighted" : @(UIControlStateHighlighted),
                                @"disabled"    : @(UIControlStateDisabled)
                                };
    
}

- (NSString *)pxStyleElementName
{
    return self.styleElementName == nil ? @"bar-button-item" : self.styleElementName;
}

- (void)setPxStyleElementName:(NSString *)pxStyleElementName
{
    self.styleElementName = pxStyleElementName;
}
- (NSArray *)supportedPseudoClasses
{
    return BUTTONS_PSEUDOCLASS_MAP.allKeys;
}
    
- (NSString *)defaultPseudoClass
{
    return @"normal";
}
    
- (NSArray *)pxStyleChildren
{
    if (!objc_getAssociatedObject(self, &STYLE_CHILDREN))
    {
        // Weak ref to self
        __weak UIBarButtonItem *weakSelf = self;
        
        //
        // Child controls
        //
        
        // icon
        
        PXVirtualStyleableControl *icon = [[PXVirtualStyleableControl alloc] initWithParent:self elementName:@"icon" viewStyleUpdaterBlock:^(PXRuleSet *ruleSet, PXStylerContext *context) {
            
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
            
            weakSelf.image = image;
        }];

        icon.viewStylers = @[
            PXOpacityStyler.sharedInstance,
            PXShapeStyler.sharedInstance,
            PXFillStyler.sharedInstance,
            PXBorderStyler.sharedInstance,
            PXBoxShadowStyler.sharedInstance,
            PXAnimationStyler.sharedInstance,

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
                }
               }],
            ];
                
                
        
        //
        // all the children
        //
        
        NSArray *styleChildren = @[ icon ];
        
        objc_setAssociatedObject(self, &STYLE_CHILDREN, styleChildren, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    
    NSArray *styleChildren = objc_getAssociatedObject(self, &STYLE_CHILDREN);
    
    return styleChildren;
}


- (NSArray *)viewStylers
{
    static __strong NSArray *stylers = nil;
	static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        stylers = @[
            PXOpacityStyler.sharedInstance,
            PXFillStyler.sharedInstance,
            PXBorderStyler.sharedInstance,
            PXShapeStyler.sharedInstance,
            PXBoxShadowStyler.sharedInstance,

            [[PXAttributedTextStyler alloc] initWithCompletionBlock:^(UIBarButtonItem *view, PXAttributedTextStyler *styler, PXStylerContext *context) {
                
                UIControlState state = ([context stateFromStateNameMap:BUTTONS_PSEUDOCLASS_MAP]) ? [context stateFromStateNameMap:BUTTONS_PSEUDOCLASS_MAP] : UIControlStateNormal;
                
                NSDictionary *attribs = [view titleTextAttributesForState:state];
                
                NSDictionary *mergedAttribs = [context mergeTextAttributes:attribs];
                
                [view setTitleTextAttributes:mergedAttribs
                                    forState:state];
            }],
            
            [[PXTextContentStyler alloc] initWithCompletionBlock:^(UIBarButtonItem *view, PXTextContentStyler *styler, PXStylerContext *context) {
                [view setTitle: context.text];
            }],
            

            [[PXGenericStyler alloc] initWithHandlers: @{
                @"-ios-tint-color" : [UIBarButtonItem TintColorDeclarationHandlerBlock:nil]
            }],
        ];
    });

	return stylers;
}

- (void)updateStyleWithRuleSet:(PXRuleSet *)ruleSet context:(PXStylerContext *)context
{
    [UIBarButtonItem UpdateStyleWithRuleSetHandler:ruleSet context:context target:self];
}
    
//
// Shared handlers and styler blocks to more easily support appearance api
//

+ (void) UpdateStyleWithRuleSetHandler:(PXRuleSet *)ruleSet context:(PXStylerContext *)context target:(UIBarButtonItem *)target
{
    if([PXUtils isBeforeIOS7O])
    {
        if (context.usesColorOnly)
        {
            [target setTintColor: context.color];
            return;
        }
    }
    
    if(context.usesImage && context.backgroundImage)
    {
        [target setBackgroundImage:context.backgroundImage
                        forState:[context stateFromStateNameMap:BUTTONS_PSEUDOCLASS_MAP]
                      barMetrics:UIBarMetricsDefault];
    }
}
    
+ (PXDeclarationHandlerBlock) TintColorDeclarationHandlerBlock:(UIBarButtonItem *)target
{
    return ^(PXDeclaration *declaration, PXStylerContext *context)
    {
        UIBarButtonItem *view = (target == nil ? (UIBarButtonItem *)context.styleable : target);
        [view setTintColor: declaration.colorValue];
    };
}
    
+ (PXStylerCompletionBlock) FontStylerCompletionBlock:(UIBarButtonItem *)target
{
    return ^(UIBarButtonItem *styleable, PXOpacityStyler *styler, PXStylerContext *context)
    {
        NSDictionary *attributes = [context propertyValueForName:[NSString stringWithFormat:@"textAttributes-%@", context.activeStateName]];
        NSMutableDictionary *currentTextAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
        [currentTextAttributes setObject:context.font forKey:NSFontAttributeName];
        [context setPropertyValue:currentTextAttributes forName:[NSString stringWithFormat:@"textAttributes-%@", context.activeStateName]];
        
        [(target == nil ? styleable : target) setTitleTextAttributes:currentTextAttributes
                                 forState:[context stateFromStateNameMap:BUTTONS_PSEUDOCLASS_MAP]];
    };
}
    
+ (PXStylerCompletionBlock) PXPaintStylerCompletionBlock:(UIBarButtonItem *)target
{
    return ^(UIBarButtonItem *styleable, PXOpacityStyler *styler, PXStylerContext *context)
    {
        
        NSDictionary *attributes = [context propertyValueForName:[NSString stringWithFormat:@"textAttributes-%@", context.activeStateName]];
        NSMutableDictionary *currentTextAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
        UIColor *color = (UIColor *)[context propertyValueForName:@"color"];
        if(color)
        {
            [currentTextAttributes setObject:color forKey:NSForegroundColorAttributeName];
            [context setPropertyValue:currentTextAttributes forName:[NSString stringWithFormat:@"textAttributes-%@", context.activeStateName]];
            [(target == nil ? styleable : target) setTitleTextAttributes:currentTextAttributes
                                     forState:[context stateFromStateNameMap:BUTTONS_PSEUDOCLASS_MAP]];
        }
    };
}



@end
