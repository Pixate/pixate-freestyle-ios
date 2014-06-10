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
//  PXUILabel.m
//  Pixate
//
//  Created by Paul Colton on 9/18/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXUILabel.h"

#import "UIView+PXStyling.h"
#import "UIView+PXStyling-Private.h"
#import "PXStylingMacros.h"
#import "PXViewUtils.h"
#import "PXStyleUtils.h"
#import "NSMutableDictionary+PXObject.h"
#import "NSDictionary+PXObject.h"
#import "PXUIView.h"

#import "PXOpacityStyler.h"
#import "PXFontStyler.h"
#import "PXPaintStyler.h"
#import "PXDeclaration.h"
#import "PXRuleSet.h"
#import "PXLayoutStyler.h"
#import "PXTransformStyler.h"
#import "PXTextContentStyler.h"
#import "PXGenericStyler.h"
#import "PXShapeStyler.h"
#import "PXFillStyler.h"
#import "PXBorderStyler.h"
#import "PXBoxShadowStyler.h"
#import "PXAnimationStyler.h"
#import "PXTextShadowStyler.h"
#import "PXAttributedTextStyler.h"
#import "PXVirtualStyleableControl.h"

static NSDictionary *PSEUDOCLASS_MAP;
static const char STYLE_CHILDREN;

NSString *const kDefaultCacheLabelShadowColor = @"label.shadowColor";
NSString *const kDefaultCacheLabelShadowOffset = @"label.shadowOffset";
NSString *const kDefaultCacheLabelFont = @"label.font";
NSString *const kDefaultCacheLabelHighlightTextColor = @"label.highightTextColor";
NSString *const kDefaultCacheLabelTextColor = @"label.textColor";
NSString *const kDefaultCacheLabelText = @"label.text";
NSString *const kDefaultCacheLabelTextAlignment = @"label.textAlignment";
NSString *const kDefaultCacheLabelLineBreakMode = @"label.lineBreakMode";

@implementation PXUILabel

+ (void)initialize
{
    if (self != PXUILabel.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"label"];

    PSEUDOCLASS_MAP = @{
        @"normal"      : @(UIControlStateNormal),
        @"highlighted" : @(UIControlStateHighlighted),
    };
}

#pragma mark - Child support

- (NSArray *)pxStyleChildren
{
    if (!objc_getAssociatedObject(self, &STYLE_CHILDREN))
    {
        __weak PXUILabel *weakSelf = self;
        
        // attributed text
        PXVirtualStyleableControl *attributedText =
                [[PXVirtualStyleableControl alloc] initWithParent:self
                                                      elementName:@"attributed-text"
                                            viewStyleUpdaterBlock:^(PXRuleSet *ruleSet, PXStylerContext *context) {
                // nothing for now
        }];
        
        attributedText.defaultPseudoClass = @"normal";
        attributedText.supportedPseudoClasses = PSEUDOCLASS_MAP.allKeys;
        
        attributedText.viewStylers = @[
                                       
            [[PXAttributedTextStyler alloc] initWithCompletionBlock:^(PXVirtualStyleableControl *styleable, PXAttributedTextStyler *styler, PXStylerContext *context) {
                
                UIControlState state = ([context stateFromStateNameMap:PSEUDOCLASS_MAP]) ?
                    [context stateFromStateNameMap:PSEUDOCLASS_MAP] : UIControlStateNormal;
                
                NSString *text = weakSelf.text;
                UIColor *stateColor = state == UIControlStateHighlighted ? weakSelf.highlightedTextColor :weakSelf.textColor;
                
                NSMutableDictionary *dict = [context attributedTextAttributes:weakSelf withDefaultText:text andColor:stateColor];
                 
                 NSMutableAttributedString *attrString = nil; 
                
                 if(context.transformedText)
                 {
                     attrString = [[NSMutableAttributedString alloc] initWithString:context.transformedText attributes:dict];
                 }
                 
                 [weakSelf setAttributedText:attrString];
            }]
        ];
        
        NSArray *styleChildren = @[ attributedText ];
        
        objc_setAssociatedObject(self, &STYLE_CHILDREN, styleChildren, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return objc_getAssociatedObject(self, &STYLE_CHILDREN);
}

#pragma mark - Attributed text stuff

- (NSMutableDictionary *)getAttributedTextDictionary
{
    //NSString *text = self.text;
    //UIColor *color = self.textColor;
    //UIColor *backColor = self.backgroundColor;
    //const CGFloat fontSize = _testLabel.font.pointSize;
    //CTFontRef fontRef = (__bridge CTFontRef)_testLabel.font;
    //CTFontSymbolicTraits symbolicTraits = CTFontGetSymbolicTraits(fontRef);
    //BOOL isBold = (symbolicTraits & kCTFontBoldTrait);
    //BOOL isItalic = (symbolicTraits & kCTFontItalicTrait);
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                  self.font, NSFontAttributeName,
                  self.textColor, NSForegroundColorAttributeName,
                  self.backgroundColor, NSBackgroundColorAttributeName,
                  @1, NSKernAttributeName,
                  nil];
    
    return attributes;
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

#pragma mark - Stylers

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

            [[PXTextShadowStyler alloc] initWithCompletionBlock:^(PXUILabel *view, PXTextShadowStyler *styler, PXStylerContext *context) {
                PXShadow *shadow = context.textShadow;

                [view px_setShadowColor: shadow.color];
                [view px_setShadowOffset: CGSizeMake(shadow.horizontalOffset, shadow.verticalOffset)];
            }],
            
            [[PXFontStyler alloc] initWithCompletionBlock:^(PXUILabel *view, PXFontStyler *styler, PXStylerContext *context) {
                [view px_setFont:context.font];
            }],
            
            [[PXPaintStyler alloc] initWithCompletionBlock:^(PXUILabel *view, PXPaintStyler *styler, PXStylerContext *context) {
                UIColor *color = (UIColor *)[context propertyValueForName:@"color"];
                
                if(color)
                {
                    if([context stateFromStateNameMap:PSEUDOCLASS_MAP] == UIControlStateHighlighted)
                    {
                        [view px_setHighlightedTextColor:color];
                    }
                    else
                    {
                        [view px_setTextColor:color];
                    }
                }
            }],
            
            [[PXTextContentStyler alloc] initWithCompletionBlock:^(PXUILabel *view, PXTextContentStyler *styler, PXStylerContext *context) {
                [view px_setText:context.text];
            }],
                
            [[PXGenericStyler alloc] initWithHandlers: @{
                 @"text-transform" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                    PXUILabel *view = (PXUILabel *)context.styleable;
                    
                    [view px_setText:[declaration transformString:view.text]];
                },
                 @"text-align" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                    PXUILabel *view = (PXUILabel *)context.styleable;

                    [view px_setTextAlignment:declaration.textAlignmentValue];
                },
                 @"text-overflow" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                    PXUILabel *view = (PXUILabel *)context.styleable;

                    [view px_setLineBreakMode:declaration.lineBreakModeValue];
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
    }
    else if (context.usesImage)
    {
        [self px_setBackgroundColor:[UIColor colorWithPatternImage:context.backgroundImage]];
    }
}

- (BOOL)preventStyling
{
    return [[self pxStyleParent] isKindOfClass:[UIButton class]]
        || ([[self pxStyleParent] class] == NSClassFromString(@"UINavigationItemButtonView"))
        ;
}

//
// Overrides
//

-(void)setText:(NSString *)text
{
    callSuper1(SUPER_PREFIX, _cmd, text);
    
    if([self preventStyling] == NO)
    {
        [PXStyleUtils invalidateStyleableAndDescendants:self];
        [self updateStylesNonRecursively];
    }
}

-(void)setAttributedText:(NSAttributedString *)attributedText
{
    callSuper1(SUPER_PREFIX, _cmd, attributedText);
    
    if([self preventStyling] == NO)
    {
        [PXStyleUtils invalidateStyleableAndDescendants:self];
        [self updateStylesNonRecursively];
    }
}

// Px Wrapped Only
PX_PXWRAP_1(setText, text);

// Ti Wrapped Also
PX_WRAP_1(setShadowColor, color);
PX_WRAP_1(setFont, font);
PX_WRAP_1(setTextColor, color);
PX_WRAP_1(setHighlightedTextColor, color);
PX_WRAP_1(setBackgroundColor, color);
PX_WRAP_1s(setShadowOffset, CGSize, offset);
PX_WRAP_1v(setTextAlignment, NSTextAlignment, alignment);
PX_WRAP_1v(setLineBreakMode, NSLineBreakMode, mode);

PX_LAYOUT_SUBVIEWS_OVERRIDE

@end


