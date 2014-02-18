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
//  UINavigationItem+PXStyling.m
//  Pixate
//
//  Created by Paul Colton on 10/15/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "UINavigationItem+PXStyling.h"
#import <objc/runtime.h>
#import "PXStylingMacros.h"
#import "PXStyleUtils.h"
#import "PXUtils.h"
#import "PXVirtualStyleableControl.h"
#import "PXGenericStyler.h"
#import "PXTextContentStyler.h"
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

static const char STYLE_CLASS_KEY;
static const char STYLE_ID_KEY;
static const char STYLE_CSS_KEY;
static const char STYLE_PARENT_KEY;
static const char STYLE_BOUNDS_KEY;
static const char STYLE_FRAME_KEY;
static const char STYLE_MODE_KEY;
static const char STYLE_ELEMENT_NAME;
static const char STYLE_CHILDREN;


void PXForceLoadUINavigationItemPXStyling() {}

@implementation UINavigationItem (PXStyling)

- (NSString *)styleClass
{
    return objc_getAssociatedObject(self, &STYLE_CLASS_KEY);
}

- (NSString *)styleId
{
    return objc_getAssociatedObject(self, &STYLE_ID_KEY);
}

- (NSString *)styleCSS
{
    return objc_getAssociatedObject(self, &STYLE_CSS_KEY);
}

- (PXStylingMode)styleMode
{
    NSNumber *modeVal = objc_getAssociatedObject(self, &STYLE_MODE_KEY);
    
    if(modeVal)
    {
        return modeVal.intValue;
    }
    
    return PXStylingNormal; //PXStylingUndefined;
}

- (void)setStyleElementName:(NSString *)elementName
{
    objc_setAssociatedObject(self, &STYLE_ELEMENT_NAME, elementName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)styleElementName
{
    return objc_getAssociatedObject(self, &STYLE_ELEMENT_NAME);
}

- (id)pxStyleParent
{
    return objc_getAssociatedObject(self, &STYLE_PARENT_KEY);
}

- (NSString *)styleKey
{
    return [PXStyleUtils selectorFromStyleable:self];
}

- (CGRect)bounds
{
    NSValue *value = objc_getAssociatedObject(self, &STYLE_BOUNDS_KEY);
    
    return value ? value.CGRectValue : CGRectZero;
}

- (CGRect)frame
{
    NSValue *value = objc_getAssociatedObject(self, &STYLE_FRAME_KEY);
    
    return value ? value.CGRectValue : CGRectZero;
}

- (BOOL)isVirtualControl
{
    return YES;
}

- (void)setStyleClass:(NSString *)aClass
{
    // make sure we have a string - needed to filter bad input from IB
    aClass = [aClass description];

    // trim leading and trailing whitespace
    aClass = [aClass stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    objc_setAssociatedObject(self, &STYLE_CLASS_KEY, aClass, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    [self updateStylesNonRecursively];
}

- (void)setStyleId:(NSString *)anId
{
    // make sure we have a string - needed to filter bad input from IB
    anId = [anId description];

    // trim leading and trailing whitespace
    anId = [anId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    objc_setAssociatedObject(self, &STYLE_ID_KEY, anId, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    [self updateStylesNonRecursively];
}

- (void)setStyleCSS:(NSString *)aCSS
{
    // make sure we have a string - needed to filter bad input from IB
    aCSS = [aCSS description];

    objc_setAssociatedObject(self, &STYLE_CSS_KEY, aCSS, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    [self updateStylesNonRecursively];
}

- (void)setStyleMode:(PXStylingMode) mode
{
    //
    // Set the styling mode value on the object
    //
    objc_setAssociatedObject(self, &STYLE_MODE_KEY, [NSNumber numberWithInt:mode], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setPxStyleParent:(id)parent
{
    objc_setAssociatedObject(self, &STYLE_PARENT_KEY, parent, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setBounds:(CGRect)bounds
{
    NSValue *value = [NSValue valueWithCGRect:bounds];
    
    objc_setAssociatedObject(self, &STYLE_BOUNDS_KEY, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setFrame:(CGRect)frame
{
    NSValue *value = [NSValue valueWithCGRect:frame];
    
    objc_setAssociatedObject(self, &STYLE_FRAME_KEY, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)updateStyles
{
    [PXStyleUtils updateStylesForStyleable:self andDescendants:YES];
}

- (void)updateStylesNonRecursively
{
    [PXStyleUtils updateStylesForStyleable:self andDescendants:NO];
}

- (void)updateStylesAsync
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateStyles];
    });
}

-(void)updateStylesNonRecursivelyAsync
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateStylesNonRecursively];
    });
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

//
// main stuff
//

static NSDictionary *PSEUDOCLASS_MAP;

- (NSString *)pxStyleElementName
{
    return self.styleElementName == nil ? @"navigation-item" : self.styleElementName;
}

- (void)setPxStyleElementName:(NSString *)pxStyleElementName
{
    self.styleElementName = pxStyleElementName;
}

- (NSArray *)pxStyleChildren
{
    // Get the children array
    NSArray *children = objc_getAssociatedObject(self, &STYLE_CHILDREN);
    
    if (!children)
    {
        children = @[ ];
        
        objc_setAssociatedObject(self, &STYLE_CHILDREN, children, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }

    //
    // Collect all of this views children, real and virtual
    //
    
    NSMutableArray *allChildren = [[NSMutableArray alloc] initWithArray:children];
    
    // Is there a back button
    if(self.backBarButtonItem)
    {
        self.backBarButtonItem.pxStyleParent = self;
        self.backBarButtonItem.pxStyleElementName = @"back-bar-button";
        [allChildren addObject:self.backBarButtonItem];
    }
    
    // If there are any available left bar buttons, then let's add those too
    if(self.leftBarButtonItems)
    {
        for (id item in self.leftBarButtonItems)
        {
            if([item isKindOfClass:[UIBarButtonItem class]])
            {
                ((UIBarButtonItem *)item).pxStyleParent = self;
                ((UIBarButtonItem *)item).pxStyleElementName = @"left-bar-button";
                [allChildren addObject:item];
            }
        }
    }
    
    // If there are any available right bar buttons, then let's add those too
    if(self.rightBarButtonItems)
    {
        for (id item in self.rightBarButtonItems)
        {
            if([item isKindOfClass:[UIBarButtonItem class]])
            {
                ((UIBarButtonItem *)item).pxStyleParent = self;
                ((UIBarButtonItem *)item).pxStyleElementName = @"right-bar-button";
                [allChildren addObject:item];
            }
        }
    }

    // If there's a titleView, add it as a child, but it will be accessible via the
    // navigation bar, not this navigation item (i.e. navigation-bar title { ... })
    if(self.titleView)
    {
        [allChildren addObject:self.titleView];
    }
    
    return allChildren;
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
                    PXBoxShadowStyler.sharedInstance,

                    [[PXTextContentStyler alloc] initWithCompletionBlock:^(UINavigationItem *item, id<PXStyler> styler, PXStylerContext *context) {
                        item.title = context.text;
                    }],

                    [[PXGenericStyler alloc] initWithHandlers: @{
                         @"text-transform" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                            [context setPropertyValue:declaration.stringValue forName:@"transform"];
                         },
                         } completionBlock:^(UINavigationItem *item, id<PXStyler> styler, PXStylerContext *context) {
                             
                             NSString *transform = [context propertyValueForName:@"transform"];
                             NSString *value = item.title;
                             
                             if ([@"uppercase" isEqualToString:transform])
                             {
                                 item.title = [value uppercaseString];
                             }
                             else if ([@"lowercase" isEqualToString:transform])
                             {
                                 item.title = [value lowercaseString];
                             }
                             else if ([@"capitalize" isEqualToString:transform])
                             {
                                 item.title = [value capitalizedString];
                             }
                         }],
        ];
    });
    
	return stylers;
}

- (void)updateStyleWithRuleSet:(PXRuleSet *)ruleSet context:(PXStylerContext *)context
{
    if (context.usesImage)
    {
        if(self.titleView && [self.titleView isKindOfClass:[UIImageView class]])
        {
            ((UIImageView *) self.titleView).image = context.backgroundImage;
        }
        else
        {
            self.titleView = [[UIImageView alloc] initWithImage:context.backgroundImage];
        }
    }
}

@end
