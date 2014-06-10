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
//  PXUIButton.m
//  Pixate
//
//  Created by Paul Colton on 9/13/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXUIButton.h"

#import "PixateFreestyle.h"
#import "PXStylingMacros.h"

#import "UIView+PXStyling.h"
#import "UIView+PXStyling-Private.h"
#import "NSDictionary+PXObject.h"
#import "NSMutableDictionary+PXObject.h"

#import "PXOpacityStyler.h"
#import "PXFontStyler.h"
#import "PXPaintStyler.h"
#import "PXTransformStyler.h"
#import "PXLayoutStyler.h"
#import "PXShapeStyler.h"
#import "PXFillStyler.h"
#import "PXBorderStyler.h"
#import "PXBoxShadowStyler.h"
#import "PXInsetStyler.h"
#import "PXTextContentStyler.h"
#import "PXGenericStyler.h"
#import "PXAnimationStyler.h"
#import "PXTextShadowStyler.h"

#import "PXDeclaration.h"
#import "PXRuleSet.h"
#import "PXVirtualStyleableControl.h"
#import <QuartzCore/QuartzCore.h>
#import "PXKeyframeAnimation.h"

#import "PXStyleUtils.h"
#import "PXUtils.h"
#import "NSMutableDictionary+PXObject.h"
#import "NSDictionary+PXObject.h"
#import "PXUIView.h"
#import "PXAnimationPropertyHandler.h"

#import "PXAttributedTextStyler.h"

static NSDictionary *PSEUDOCLASS_MAP;
static const char STYLE_CHILDREN;

@implementation PXUIButton

#pragma mark - Static methods

+ (void)initialize
{
    if (self != PXUIButton.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"button"];

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
        __weak PXUIButton *weakSelf = self;

        //
        // icon child
        //
        PXVirtualStyleableControl *icon = [[PXVirtualStyleableControl alloc] initWithParent:self elementName:@"icon" viewStyleUpdaterBlock:^(PXRuleSet *ruleSet, PXStylerContext *context) {
            UIImage *image = context.backgroundImage;

            if (image)
            {
                [weakSelf px_setImage:image forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
            }
        }];

        icon.defaultPseudoClass = @"normal";
        icon.supportedPseudoClasses = PSEUDOCLASS_MAP.allKeys;

        icon.viewStylers = @[
            PXShapeStyler.sharedInstance,
            PXFillStyler.sharedInstance,
            PXBorderStyler.sharedInstance,
            PXBoxShadowStyler.sharedInstance,
            ];
        
        //
        // attributed text child
        //
        PXVirtualStyleableControl *attributedText =
        [[PXVirtualStyleableControl alloc] initWithParent:self
                                              elementName:@"attributed-text"
                                    viewStyleUpdaterBlock:^(PXRuleSet *ruleSet, PXStylerContext *context) {
                                        // nothing for now
                                    }];
        
        attributedText.defaultPseudoClass = @"normal";
        attributedText.supportedPseudoClasses = PSEUDOCLASS_MAP.allKeys;
        
        attributedText.viewStylers =
        @[
            [[PXAttributedTextStyler alloc] initWithCompletionBlock:^(PXVirtualStyleableControl *styleable, PXAttributedTextStyler *styler, PXStylerContext *context) {

                UIControlState state = ([context stateFromStateNameMap:PSEUDOCLASS_MAP]);
                
                NSAttributedString *stateTextAttr = [weakSelf attributedTitleForState:state];
                NSString *stateText = stateTextAttr ? stateTextAttr.string : [weakSelf titleForState:state];
                
                UIColor *stateColor = [weakSelf titleColorForState:state];
                
                NSMutableDictionary *dict = [context attributedTextAttributes:weakSelf
                                                              withDefaultText:stateText
                                                                     andColor:stateColor];
               
                
               NSMutableAttributedString *attrString = nil;               
               if(context.transformedText)
               {
                   attrString = [[NSMutableAttributedString alloc] initWithString:context.transformedText attributes:dict];
               }
               
               [weakSelf px_setAttributedTitle:attrString forState:state];
            }]
        ];

        NSArray *styleChildren = @[ icon, attributedText ];

        objc_setAssociatedObject(self, &STYLE_CHILDREN, styleChildren, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    return [objc_getAssociatedObject(self, &STYLE_CHILDREN) arrayByAddingObjectsFromArray:self.subviews];
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

            [[PXTextShadowStyler alloc] initWithCompletionBlock:^(PXUIButton *view, PXTextShadowStyler *styler, PXStylerContext *context) {
                PXShadow *shadow = context.textShadow;

                if (shadow)
                {
                    [view px_setTitleShadowColor: shadow.color forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
                    view.px_titleLabel.shadowOffset = CGSizeMake(shadow.horizontalOffset, shadow.verticalOffset);

                    /*
                    NSMutableDictionary *attrs = [[NSMutableDictionary alloc] init];

                    [attrs setObject:shadow.color forKey:UITextAttributeTextShadowColor];
                    [attrs setObject:[NSValue valueWithCGSize:CGSizeMake(shadow.horizontalOffset, shadow.verticalOffset)] forKey:UITextAttributeTextShadowOffset];

                    NSAttributedString *oldString = [view attributedTitleForState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
                    NSMutableAttributedString *attrString = (oldString)
                        ?   [[NSMutableAttributedString alloc] initWithAttributedString:oldString]
                        :   [[NSMutableAttributedString alloc] initWithString:[view titleForState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]]];

                    [attrString setAttributes:attrs range:NSMakeRange(0, attrString.length)];

                    [view px_setAttributedTitle:attrString forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
                    */
                }
            }],

            [[PXFontStyler alloc] initWithCompletionBlock:^(PXUIButton *view, PXFontStyler *styler, PXStylerContext *context) {
                view.px_titleLabel.font = context.font;
            }],

            [[PXPaintStyler alloc] initWithCompletionBlock:^(PXUIButton *view, PXPaintStyler *styler, PXStylerContext *context) {
                UIColor *color = (UIColor *)[context propertyValueForName:@"color"];
                if(color)
                {
                    [view px_setTitleColor:color forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
                }
                
                color = (UIColor *)[context propertyValueForName:@"-ios-tint-color"];
                if(color)
                {
                    [view px_setTintColor:color];
                }
            }],

            [[PXInsetStyler alloc] initWithBaseName:@"content-edge" completionBlock:^(PXUIButton *view, PXInsetStyler *styler, PXStylerContext *context) {
                [view px_setContentEdgeInsets:styler.insets];
            }],
            [[PXInsetStyler alloc] initWithBaseName:@"title-edge" completionBlock:^(PXUIButton *view, PXInsetStyler *styler, PXStylerContext *context) {
                [view px_setTitleEdgeInsets:styler.insets];
            }],
            [[PXInsetStyler alloc] initWithBaseName:@"image-edge" completionBlock:^(PXUIButton *view, PXInsetStyler *styler, PXStylerContext *context) {
                [view px_setImageEdgeInsets:styler.insets];
            }],

            [[PXTextContentStyler alloc] initWithCompletionBlock:^(PXUIButton *view, PXTextContentStyler *styler, PXStylerContext *context) {
                [view px_setTitle:context.text forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
            }],

            [[PXGenericStyler alloc] initWithHandlers: @{
             @"text-transform" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXUIButton *view = (PXUIButton *)context.styleable;
                NSString *newTitle = [declaration transformString:[view titleForState:UIControlStateNormal]];

                [view px_setTitle:newTitle forState:UIControlStateNormal];
            },
             @"text-overflow" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXUIButton *view = (PXUIButton *)context.styleable;

                view.px_titleLabel.lineBreakMode = declaration.lineBreakModeValue;
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

//- (void)PX_UIControlEventTouchDown_Dummy {}

- (void)updateStyleWithRuleSet:(PXRuleSet *)ruleSet context:(PXStylerContext *)context
{
//    [self addTarget:self action:@selector(PX_UIControlEventTouchDown_Dummy) forControlEvents:UIControlEventTouchDown];
//    [self addTarget:self action:@selector(PX_UIControlEventTouchDown_Dummy) forControlEvents:UIControlEventTouchUpInside];

    //- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents

    // Solid colors are only supported for normal state, so we'll use images otherwise
    if (context.usesColorOnly)
    {
        if ([context stateFromStateNameMap:PSEUDOCLASS_MAP] == UIControlStateNormal && self.buttonType != UIButtonTypeRoundedRect)
        {
            [self px_setBackgroundColor:context.color];
        }
        else
        {
            //[self px_setBackgroundColor:[UIColor clearColor]];
            [self px_setBackgroundImage:context.backgroundImage
                               forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];

        }
    }
    else if (context.usesImage)
    {
        //[self px_setBackgroundColor:[UIColor clearColor]];
        [self px_setBackgroundImage:context.backgroundImage
                           forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
    }
}


- (CGSize) intrinsicContentSize
{
    CGSize result = [super intrinsicContentSize]; 

    if ([PXUtils isBeforeIOS7O])
    {
        Class roundedButton = NSClassFromString(@"UIRoundedRectButton");

        if (roundedButton && [self isKindOfClass:roundedButton]) {
            result.width  -= 24;
            result.height -= 16;
        }
    }

    return result;
}


//
// Overrides
//

-(void)setTitle:(NSString *)title forState:(UIControlState)state
{
    [self px_setTitle:title forState:state];
    [PXStyleUtils invalidateStyleableAndDescendants:self];
    [self updateStylesNonRecursively];
}

-(void)setAttributedTitle:(NSAttributedString *)title forState:(UIControlState)state
{
    [self px_setAttributedTitle:title forState:state];
    [PXStyleUtils invalidateStyleableAndDescendants:self];
    [self updateStylesNonRecursively];
}

// Px Wrapped Only
PX_PXWRAP_PROP(UILabel, titleLabel);
PX_PXWRAP_1s(setTransform, CGAffineTransform, transform);
PX_PXWRAP_1s(setAlpha, CGFloat, alpha);
PX_PXWRAP_1s(setBounds, CGRect, rect);
PX_PXWRAP_1s(setFrame,  CGRect, rect);
PX_PXWRAP_2v(setTitle, title, forState, UIControlState, state);
PX_PXWRAP_2v(setAttributedTitle, string, forState, UIControlState, state);

// Ti Wrapped as well
PX_WRAP_1(setTintColor, color);
PX_WRAP_1(setBackgroundColor, color);
PX_WRAP_1s(setContentEdgeInsets, UIEdgeInsets, insets);
PX_WRAP_1s(setTitleEdgeInsets,   UIEdgeInsets, insets);
PX_WRAP_1s(setImageEdgeInsets,   UIEdgeInsets, insets);
PX_WRAP_2v(setImage, image, forState, UIControlState, state);
PX_WRAP_2v(setBackgroundImage, image, forState, UIControlState, state);
PX_WRAP_2v(setTitleColor,      color, forState, UIControlState, state);
PX_WRAP_2v(setTitleShadowColor, color, forState, UIControlState, state);

// Styling overrides
PX_LAYOUT_SUBVIEWS_OVERRIDE

/* HOLD
-(void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    //get the string indicating the action called
    NSString *actionString = NSStringFromSelector(action);

    //get the string for the action that you want to check for
    NSString *UIControlEventTouchDownName = [[self actionsForTarget:target forControlEvent:UIControlEventTouchDown] lastObject];

    if ([UIControlEventTouchDownName isEqualToString:actionString]){

        [UIView transitionWithView:self duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [super sendAction:action to:target forEvent:event];
        } completion:^(BOOL finished) {
        }];

    } else {
        //not an event we are interested in, allow it pass through with no additional action
        [super sendAction:action to:target forEvent:event];
    }
}
*/


@end
