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
//  PXUITextView.m
//  Pixate
//
//  Created by Kevin Lindsey on 10/10/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXUITextView.h"
#import <QuartzCore/QuartzCore.h>

#import "UIView+PXStyling.h"
#import "UIView+PXStyling-Private.h"
#import "PXStylingMacros.h"

#import "PXOpacityStyler.h"
#import "PXFontStyler.h"
#import "PXColorStyler.h"
#import "PXLayoutStyler.h"
#import "PXTransformStyler.h"
#import "PXShapeStyler.h"
#import "PXFillStyler.h"
#import "PXBorderStyler.h"
#import "PXBoxShadowStyler.h"
#import "PXTextContentStyler.h"
#import "PXGenericStyler.h"
#import "PXAnimationStyler.h"
#import "PXVirtualStyleableControl.h"
#import "PXAttributedTextStyler.h"

static const char STYLE_CHILDREN;

@implementation PXUITextView

+ (void)initialize
{
    if (self != PXUITextView.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"text-view"];
}

- (NSArray *)pxStyleChildren
{
    if (!objc_getAssociatedObject(self, &STYLE_CHILDREN))
    {
        __weak PXUITextView *weakSelf = self;
        
        // attributed text
        PXVirtualStyleableControl *attributedText =
        [[PXVirtualStyleableControl alloc] initWithParent:self
                                              elementName:@"attributed-text"
                                    viewStyleUpdaterBlock:^(PXRuleSet *ruleSet, PXStylerContext *context) {
                                        // nothing for now
                                    }];
        
        attributedText.viewStylers = @[
                                       
                                       [[PXAttributedTextStyler alloc] initWithCompletionBlock:^(PXVirtualStyleableControl *styleable, PXAttributedTextStyler *styler, PXStylerContext *context) {
                                           
                                           NSMutableDictionary *dict = [context attributedTextAttributes:weakSelf withDefaultText:weakSelf.text andColor:weakSelf.textColor];
                                           
                                           NSMutableAttributedString *attrString = nil;                                           
                                           if(context.transformedText)
                                           {
                                               attrString = [[NSMutableAttributedString alloc] initWithString:context.transformedText attributes:dict];
                                           }
                                           
                                           [weakSelf px_setAttributedText:attrString];
                                       }]
                                       ];
        
        NSArray *styleChildren = @[ attributedText ];
        
        objc_setAssociatedObject(self, &STYLE_CHILDREN, styleChildren, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return objc_getAssociatedObject(self, &STYLE_CHILDREN);
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

            [[PXFontStyler alloc] initWithCompletionBlock:^(PXUITextView *view, PXFontStyler *styler, PXStylerContext *context) {
                [view px_setFont: context.font];
            }],

            [[PXColorStyler alloc] initWithCompletionBlock:^(PXUITextView *view, PXColorStyler *styler, PXStylerContext *context) {
                [view px_setTextColor: (UIColor *) [context propertyValueForName:@"color"]];
            }],

            [[PXTextContentStyler alloc] initWithCompletionBlock:^(PXUITextView *view, PXTextContentStyler *styler, PXStylerContext *context) {
                [view px_setText: context.text];
            }],

            [[PXGenericStyler alloc] initWithHandlers: @{
             @"text-align" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXUITextView *view = (PXUITextView *)context.styleable;

                [view px_setTextAlignment: declaration.textAlignmentValue];
            },
             @"content-offset" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXUITextView *view = (PXUITextView *)context.styleable;
                CGSize point = declaration.sizeValue;
                
                [view px_setContentOffset: CGPointMake(point.width, point.height)];
            },
             @"content-size" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXUITextView *view = (PXUITextView *)context.styleable;
                CGSize size = declaration.sizeValue;
                
                [view px_setContentSize: size];
            },
             @"content-inset" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXUITextView *view = (PXUITextView *)context.styleable;
                UIEdgeInsets insets = declaration.insetsValue;
                
                [view px_setContentInset: insets];
            },
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
    if (context.color)
    {
        [self px_setBackgroundColor: context.color];
    }
    else if (context.usesImage)
    {
        //[self px_setBackgroundColor: [UIColor colorWithPatternImage:context.backgroundImage]];
        self.px_layer.contents = (__bridge id)(context.backgroundImage.CGImage);
    }
}

//
// Overrides
//

-(void)setText:(NSString *)text
{
    [self px_setText:text];
    [PXStyleUtils invalidateStyleableAndDescendants:self];
    [self updateStylesNonRecursively];
}

-(void)setAttributedText:(NSAttributedString *)attributedText
{
    [self px_setAttributedText:attributedText];
    [PXStyleUtils invalidateStyleableAndDescendants:self];
    [self updateStylesNonRecursively];
}

// Px Wrapped Only
PX_PXWRAP_PROP(CALayer, layer);
PX_PXWRAP_1(setText, text);
PX_PXWRAP_1(setAttributedText, text);

// Ti Wrapped
PX_WRAP_1(setTextColor, color);
PX_WRAP_1(setFont, font);
PX_WRAP_1(setBackgroundColor, color);
PX_WRAP_1v(setTextAlignment, NSTextAlignment, alignment);

PX_WRAP_1s(setContentSize,   CGSize,       size);
PX_WRAP_1s(setContentOffset, CGPoint,      size);
PX_WRAP_1s(setContentInset,  UIEdgeInsets, insets);

@end
