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
//  PXUINavigationBar.m
//  Pixate
//
//  Created by Paul Colton on 10/8/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXUINavigationBar.h"

#import "UIView+PXStyling.h"
#import "UIView+PXStyling-Private.h"
#import "PXStylingMacros.h"
#import "PXVirtualStyleableControl.h"
#import "NSObject+PXSubclass.h"
#import "PXUtils.h"
#import "PXImageUtils.h"

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
#import "PXTextContentStyler.h"
#import "UINavigationItem+PXStyling.h"
#import "UIBarButtonItem+PXStyling-Private.h"

static const char STYLE_CHILDREN;
static NSDictionary *PSEUDOCLASS_MAP;
static NSDictionary *BUTTONS_PSEUDOCLASS_MAP;

@implementation PXUINavigationBar

#pragma mark - Static methods

+ (void)initialize
{
    if (self != PXUINavigationBar.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"navigation-bar"];

    PSEUDOCLASS_MAP = @{
        @"default" : @(UIBarMetricsDefault),
        @"landscape-iphone" : @(UIBarMetricsLandscapePhone)
    };
    
    BUTTONS_PSEUDOCLASS_MAP = @{
                        @"normal"      : @(UIControlStateNormal),
                        @"highlighted" : @(UIControlStateHighlighted),
                        @"disabled"    : @(UIControlStateDisabled)
                        };

}

#pragma mark - Pseudo-class State

- (NSArray *)supportedPseudoClasses
{
    if (PXUtils.isIPhone)
    {
        return PSEUDOCLASS_MAP.allKeys;
    }
    else
    {
        return @[ @"default" ];
    }
}

- (NSString *)defaultPseudoClass
{
    if (PXUtils.isIPhone)
    {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];

        switch (orientation) {
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:
                return @"landscape-iphone";

            default:
                return @"default";
        }
    }
    else
    {
        return @"default";
    }
}

#pragma mark - Styling

- (NSArray *)pxStyleChildren
{
    // Get the children array
    NSArray *children = objc_getAssociatedObject(self, &STYLE_CHILDREN);

    if (!children)
    {
        // Weak ref to self
        __weak PXUINavigationBar *weakSelf = self;

        //
        // Child controls
        //
        
        /// back-indicator
        
        PXVirtualStyleableControl *backIndicator = [[PXVirtualStyleableControl alloc] initWithParent:self elementName:@"back-indicator" viewStyleUpdaterBlock:^(PXRuleSet *ruleSet, PXStylerContext *context) {
            
            if([PXUtils isIOS7OrGreater])
            {
                UIImage *image = context.backgroundImage;
            
                weakSelf.backIndicatorImage = image;
                
                if(weakSelf.backIndicatorTransitionMaskImage == nil)
                {
                    weakSelf.backIndicatorTransitionMaskImage = image;
                }
            }
        }];

        backIndicator.viewStylers = @[
                                      PXOpacityStyler.sharedInstance,
                                      PXShapeStyler.sharedInstance,
                                      PXFillStyler.sharedInstance,
                                      PXBorderStyler.sharedInstance,
                                      PXBoxShadowStyler.sharedInstance
                                      ];
        
        /// back-indicator-mask
        
        PXVirtualStyleableControl *backIndicatorMask = [[PXVirtualStyleableControl alloc] initWithParent:self elementName:@"back-indicator-mask" viewStyleUpdaterBlock:^(PXRuleSet *ruleSet, PXStylerContext *context) {
            
            if([PXUtils isIOS7OrGreater])
            {
                UIImage *image = context.backgroundImage;
                
                weakSelf.backIndicatorTransitionMaskImage = image;
            }
        }];
        
        backIndicatorMask.viewStylers = @[
                             PXOpacityStyler.sharedInstance,
                             PXShapeStyler.sharedInstance,
                             PXFillStyler.sharedInstance,
                             PXBorderStyler.sharedInstance,
                             PXBoxShadowStyler.sharedInstance
                             ];

        /// title

        PXVirtualStyleableControl *title = [[PXVirtualStyleableControl alloc] initWithParent:self elementName:@"title"];
        
        title.viewStylers = @[
                              
            [[PXTextShadowStyler alloc] initWithCompletionBlock:^(PXVirtualStyleableControl *view, PXTextShadowStyler *styler, PXStylerContext *context) {
               PXShadow *shadow = context.textShadow;
               NSMutableDictionary *currentTextAttributes = [NSMutableDictionary dictionaryWithDictionary:weakSelf.titleTextAttributes];
               
                NSShadow *nsShadow = [[NSShadow alloc] init];
                
                nsShadow.shadowColor = shadow.color;
                nsShadow.shadowOffset = CGSizeMake(shadow.horizontalOffset, shadow.verticalOffset);
                nsShadow.shadowBlurRadius = shadow.blurDistance;
                
                [currentTextAttributes setObject:nsShadow forKey:NSShadowAttributeName];
               
               [weakSelf px_setTitleTextAttributes:currentTextAttributes];
            }],

            [[PXFontStyler alloc] initWithCompletionBlock:^(PXVirtualStyleableControl *view, PXFontStyler *styler, PXStylerContext *context) {
               NSMutableDictionary *currentTextAttributes = [NSMutableDictionary dictionaryWithDictionary:weakSelf.titleTextAttributes];
               
               [currentTextAttributes setObject:context.font
                                         forKey:NSFontAttributeName];
               
               [weakSelf px_setTitleTextAttributes:currentTextAttributes];
                
                if([PXUtils isBeforeIOS7O])
                {
                    [weakSelf setNeedsLayout];
                }
            }],

            [[PXPaintStyler alloc] initWithCompletionBlock:^(PXVirtualStyleableControl *view, PXPaintStyler *styler, PXStylerContext *context) {
                
               NSMutableDictionary *currentTextAttributes = [NSMutableDictionary dictionaryWithDictionary:weakSelf.titleTextAttributes];
               
               UIColor *color = (UIColor *)[context propertyValueForName:@"color"];
               
                if(color)
                {
                   [currentTextAttributes setObject:color
                                             forKey:NSForegroundColorAttributeName];
                   
                   [weakSelf px_setTitleTextAttributes:currentTextAttributes];
                }
            }],
            
        ];
        
        //
        // button-appearance
        //
        
        PXVirtualStyleableControl *barButtons =
        [[PXVirtualStyleableControl alloc] initWithParent:self elementName:@"button-appearance"
                                    viewStyleUpdaterBlock:^(PXRuleSet *ruleSet, PXStylerContext *context)
         {
             [UIBarButtonItem UpdateStyleWithRuleSetHandler:ruleSet
                                                    context:context
                                                     target:[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]];
         }];
        
        barButtons.supportedPseudoClasses = BUTTONS_PSEUDOCLASS_MAP.allKeys;
        barButtons.defaultPseudoClass = @"normal";
        
        barButtons.viewStylers = @[
            PXOpacityStyler.sharedInstance,
            PXFillStyler.sharedInstance,
            PXBorderStyler.sharedInstance,
            PXShapeStyler.sharedInstance,
            PXBoxShadowStyler.sharedInstance,

            [[PXFontStyler alloc] initWithCompletionBlock:[UIBarButtonItem FontStylerCompletionBlock:[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]]],
            
            [[PXPaintStyler alloc] initWithCompletionBlock:[UIBarButtonItem PXPaintStylerCompletionBlock:[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]]],

            [[PXGenericStyler alloc] initWithHandlers: @{
                @"-ios-tint-color" : [UIBarButtonItem TintColorDeclarationHandlerBlock:[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]]
                }],
            ];
        
        
        //
        // back-button-appearance
        //
        
        PXVirtualStyleableControl *backBarButtons =
        [[PXVirtualStyleableControl alloc] initWithParent:self elementName:@"back-button-appearance"
                                    viewStyleUpdaterBlock:^(PXRuleSet *ruleSet, PXStylerContext *context)
         {
             if (context.usesImage && context.backgroundImage)
             {
                 UIImage *image = context.backgroundImage;
                 
                 [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
                      setBackButtonBackgroundImage:image
                      forState:[context stateFromStateNameMap:BUTTONS_PSEUDOCLASS_MAP]
                      barMetrics:UIBarMetricsDefault];
             }
         }];
        
        backBarButtons.supportedPseudoClasses = BUTTONS_PSEUDOCLASS_MAP.allKeys;
        backBarButtons.defaultPseudoClass = @"normal";
        
        backBarButtons.viewStylers = @[
                                       PXOpacityStyler.sharedInstance,
                                       PXShapeStyler.sharedInstance,
                                       PXFillStyler.sharedInstance,
                                       PXBorderStyler.sharedInstance,
                                       PXBoxShadowStyler.sharedInstance
                                       ];
        
        children = @[ title, backIndicator, backIndicatorMask, barButtons, backBarButtons ];
        
        objc_setAssociatedObject(self, &STYLE_CHILDREN, children, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    
    //
    // Collect all of this views children, real and virtual
    //

    // Add the subviews
    NSMutableArray *allChildren = [[NSMutableArray alloc]
                                   initWithArray:[children arrayByAddingObjectsFromArray:self.subviews]];

    // Add the top navigation item
    if(self.topItem)
    {
        self.topItem.pxStyleParent = self;
        [allChildren addObject:self.topItem];
    }

    return allChildren;
}

- (NSArray *)viewStylers
{
    static __strong NSArray *stylers = nil;
	static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        
        stylers = @[
            PXTransformStyler.sharedInstance,
            PXLayoutStyler.sharedInstance,

            [[PXOpacityStyler alloc] initWithCompletionBlock:^(PXUINavigationBar *view, PXOpacityStyler *styler, PXStylerContext *context) {
                [view px_setTranslucent:(context.opacity < 1.0) ? YES : NO];
            }],

            PXShapeStyler.sharedInstance,
            PXFillStyler.sharedInstance,
            PXBorderStyler.sharedInstance,
            PXBoxShadowStyler.sharedInstance,
            
            [[PXBarMetricsAdjustmentStyler alloc] initWithCompletionBlock:^(PXUINavigationBar *view, PXBarMetricsAdjustmentStyler *styler, PXStylerContext *context) {
                PXDimension *offset = context.barMetricsVerticalOffset;
                CGFloat value = (offset) ? [offset points].number : 0.0f;
                
                [view px_setTitleVerticalPositionAdjustment:value forBarMetrics:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
            }],

            [[PXPaintStyler alloc] initWithCompletionBlock:^(PXUINavigationBar *view, PXPaintStyler *styler, PXStylerContext *context) {
                
                if([PXUtils isIOS7OrGreater])
                {
                    UIColor *color = (UIColor *)[context propertyValueForName:@"color"];
                    if(color)
                    {
                        [view px_setTintColor:color];
                    }
                }
                else // @deprecated in 1.1 (this else statement only)
                {
                    NSMutableDictionary *currentTextAttributes = [NSMutableDictionary dictionaryWithDictionary:view.titleTextAttributes];
                    
                    UIColor *color = (UIColor *)[context propertyValueForName:@"color"];
                    
                    if(color)
                    {
                        [currentTextAttributes setObject:color
                                                  forKey:NSForegroundColorAttributeName];
                        
                        [view px_setTitleTextAttributes:currentTextAttributes];
                    }
                }
                
                // check for tint-color
                UIColor *color = (UIColor *)[context propertyValueForName:@"-ios-tint-color"];
                if(color)
                {
                    [view px_setTintColor:color];
                }
            }],
            
            // @deprecated in 1.1
            [[PXTextShadowStyler alloc] initWithCompletionBlock:^(PXUINavigationBar *view, PXTextShadowStyler *styler, PXStylerContext *context) {
                PXShadow *shadow = context.textShadow;
                NSMutableDictionary *currentTextAttributes = [NSMutableDictionary dictionaryWithDictionary:view.titleTextAttributes];
                
                NSShadow *nsShadow = [[NSShadow alloc] init];
                
                nsShadow.shadowColor = shadow.color;
                nsShadow.shadowOffset = CGSizeMake(shadow.horizontalOffset, shadow.verticalOffset);
                nsShadow.shadowBlurRadius = shadow.blurDistance;
                
                [currentTextAttributes setObject:nsShadow forKey:NSShadowAttributeName];
                
                [view px_setTitleTextAttributes:currentTextAttributes];
            }],
            
            // @deprecated in 1.1
            [[PXFontStyler alloc] initWithCompletionBlock:^(PXUINavigationBar *view, PXFontStyler *styler, PXStylerContext *context) {
                NSMutableDictionary *currentTextAttributes = [NSMutableDictionary dictionaryWithDictionary:view.titleTextAttributes];
                
                [currentTextAttributes setObject:context.font
                                          forKey:NSFontAttributeName];
                
                [view px_setTitleTextAttributes:currentTextAttributes];
                
                if([PXUtils isBeforeIOS7O])
                {
                    [view setNeedsLayout];
                }
            }],

            // shadow-* image properties
            [[PXBarShadowStyler alloc] initWithCompletionBlock:^(PXUINavigationBar *view, PXBarShadowStyler *styler, PXStylerContext *context) {
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

            PXAnimationStyler.sharedInstance,
            
            /*
             *  - background-position: any | bottom | top | top-attached;
             *
            [[PXGenericStyler alloc] initWithHandlers: @{
                @"background-position" : ^(PXDeclaration *declaration, PXStylerContext *context)
                {
                    NSString *position = [declaration.stringValue lowercaseString];
                    [context setPropertyValue:position forName:@"background-position"];
                }
            }],
             */
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
    //
    // Set the background-color....
    //
    if (context.usesColorOnly)
    {
        if([PXUtils isIOS7OrGreater])
        {
            [self px_setBarTintColor:context.color];
        }
        else
        {
            [self px_setTintColor:context.color];
        }
        
        [self px_setBackgroundImage:nil
                      forBarMetrics:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
    }
    else if (context.usesImage)
    {
        /*
        if([PXUtils isIOS7OrGreater])
        {
            UIBarPosition position = UIBarPositionAny;
            NSString *backgroundPosition = [context propertyValueForName:@"background-position"];
            
            if([backgroundPosition isEqualToString:@"bottom"])
            {
                position = UIBarPositionBottom;
            }
            else if([backgroundPosition isEqualToString:@"top"])
            {
                position = UIBarPositionTop;
            }
            else if([backgroundPosition isEqualToString:@"top-attached"])
            {
                position = UIBarPositionTopAttached;
            }
            
            // TODO: use a macro here
            [self setBackgroundImage:context.backgroundImage
                      forBarPosition:position
                          barMetrics:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
            
            
        }
        else
        {
         */
        [self px_setBackgroundColor:[UIColor clearColor]];
        [self px_setBackgroundImage:context.backgroundImage
                      forBarMetrics:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
//        }
    }

}

// Overrides
PX_LAYOUT_SUBVIEWS_OVERRIDE

// This will allow for the dynamically added content to style, like the UINavigationItems
-(void)addSubview:(UIView *)view
{
    callSuper1(SUPER_PREFIX, _cmd, view);
    
    // invalidate the navbar when new views get added (primarily to catch new top level views sliding in)
    [PXStyleUtils invalidateStyleableAndDescendants:self];
    
    // update styles for this newly added view
    [self updateStyles];
}

// Ti Wrapped
PX_WRAP_1(setTintColor, color);
PX_WRAP_1(setBarTintColor, color);
PX_WRAP_1(setBackgroundColor, color);
PX_WRAP_1(setShadowImage, image);
PX_WRAP_1(setTitleTextAttributes, attribs);
PX_WRAP_1b(setTranslucent, flag);
//BUSTED:PX_WRAP_3v(setBackgroundImage, image, forBarPosition, UIBarPosition, position, barMetrics, UIBarMetrics, metrics);
PX_WRAP_2v(setBackgroundImage, image, forBarMetrics, UIBarMetrics, metrics);
PX_WRAP_2vv(setTitleVerticalPositionAdjustment, CGFloat, adjustment, forBarMetrics, UIBarMetrics, metrics);

@end

