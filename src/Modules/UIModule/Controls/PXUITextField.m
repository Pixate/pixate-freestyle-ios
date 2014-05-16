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
//  PXUITextField.m
//  Pixate
//
//  Created by Kevin Lindsey on 10/10/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXUITextField.h"
#import <QuartzCore/QuartzCore.h>

#import "UIView+PXStyling.h"
#import "UIView+PXStyling-Private.h"
#import "PXStylingMacros.h"
#import "PXStyleUtils.h"
#import "PXTransitionRuleSetInfo.h"
#import "PXNotificationManager.h"

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
#import "PXStyleInfo.h"
#import "PXTextShadowStyler.h"
#import "PXPaintStyler.h"
#import "PXVirtualStyleableControl.h"
#import "PXAttributedTextStyler.h"

// if on ARM64, then we can't/don't need to use 'objc_msgSendSuper_stret'
#if defined(__arm64__)
    #define objc_msgSendSuper_stret objc_msgSendSuper
#endif

static const char STYLE_CHILDREN;
static const char STATE_KEY;

// Private PX_PositionCursorDelegate class
@interface PX_PositionCursorDelegate : NSObject
- (id) initWithTextField:(UITextField *)textField;
@end

@implementation PX_PositionCursorDelegate
{
    UITextField *textField_;
}

- (id) initWithTextField:(UITextField *)textField
{
    if(self = [super init])
    {
        textField_ = textField;
    }

    return self;
}

- (void)animationDidStart:(CAAnimation *)theAnimation
{
    UITextRange *currentPos = textField_.selectedTextRange;

    [textField_ setSelectedTextRange:[textField_ textRangeFromPosition:[textField_ beginningOfDocument]
                                                            toPosition:[textField_ beginningOfDocument]]];
    [textField_ setSelectedTextRange:currentPos];
}
@end
// End PX_PositionCursorDelegate Private class

static char PADDING;

@implementation PXUITextField

static NSDictionary *PSEUDOCLASS_MAP;

+ (void)initialize
{
    if (self != PXUITextField.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"text-field"];

    PSEUDOCLASS_MAP = @{
                        @"normal"      : UITextFieldTextDidEndEditingNotification,
                        @"highlighted" : UITextFieldTextDidBeginEditingNotification,
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

- (BOOL)canStylePseudoClass:(NSString *)pseudoClass
{
    return [[self pxState] isEqualToString:pseudoClass];
}

- (void)registerNotifications
{
    __weak PXUITextField *weakSelf = self;

    [PXNotificationManager.sharedInstance registerObserver:self forNotification:UITextFieldTextDidBeginEditingNotification withBlock:^{
        [weakSelf px_TransitionTextField:weakSelf forState:@"highlighted"];
    }];
    [PXNotificationManager.sharedInstance registerObserver:self forNotification:UITextFieldTextDidEndEditingNotification withBlock:^{
        [weakSelf px_TransitionTextField:weakSelf forState:@"normal"];
    }];
}

- (void)dealloc
{
    [PXNotificationManager.sharedInstance unregisterObserver:self forNotification:UITextFieldTextDidBeginEditingNotification];
    [PXNotificationManager.sharedInstance unregisterObserver:self forNotification:UITextFieldTextDidEndEditingNotification];
}

- (void)setPxState:(NSString *)stateName
{
    objc_setAssociatedObject(self, &STATE_KEY, stateName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)pxState
{
    NSString *result = objc_getAssociatedObject(self, &STATE_KEY);

    return result ? result : self.defaultPseudoClass;
}

#pragma mark - Stylers

- (NSArray *)pxStyleChildren
{
    if (!objc_getAssociatedObject(self, &STYLE_CHILDREN))
    {
        __weak PXUITextField *weakSelf = self;
        
        // placeholder
        PXVirtualStyleableControl *placeholder = [[PXVirtualStyleableControl alloc] initWithParent:self elementName:@"placeholder" viewStyleUpdaterBlock:^(PXRuleSet *ruleSet, PXStylerContext *context) {

            // Style placeholder
            NSMutableDictionary *currentPlaceholderTextAttributes = [context propertyValueForName:@"text-attributes"];
            if(currentPlaceholderTextAttributes)
            {
                NSString *placeholderText = [context propertyValueForName:@"text-value"];
                
                if(!placeholderText)
                {
                    if(weakSelf.placeholder)
                    {
                        placeholderText = weakSelf.placeholder;
                    }
                    else
                    {
                        placeholderText = @"";
                    }
                }
                
                [weakSelf px_setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:placeholderText
                                                                                      attributes:currentPlaceholderTextAttributes]];
            }
        }];
        
        placeholder.viewStylers = @[
             [[PXTextShadowStyler alloc] initWithCompletionBlock:^(PXUITextField *view, PXTextShadowStyler *styler, PXStylerContext *context) {
                 PXShadow *shadow = context.textShadow;
                 
                 // Get attributes from context, if any
                 NSMutableDictionary *currentTextAttributes = [context propertyValueForName:@"text-attributes"];
                 if(!currentTextAttributes)
                 {
                     currentTextAttributes = [[NSMutableDictionary alloc] initWithCapacity:5];
                     [context setPropertyValue:currentTextAttributes forName:@"text-attributes"];
                 }
                 
                 NSShadow *nsShadow = [[NSShadow alloc] init];
                 
                 nsShadow.shadowColor = shadow.color;
                 nsShadow.shadowOffset = CGSizeMake(shadow.horizontalOffset, shadow.verticalOffset);
                 nsShadow.shadowBlurRadius = shadow.blurDistance;
                 
                 [currentTextAttributes setObject:nsShadow forKey:NSShadowAttributeName];
             }],
             
             [[PXFontStyler alloc] initWithCompletionBlock:^(PXUITextField *view, PXFontStyler *styler, PXStylerContext *context) {
                 
                 // Get attributes from context, if any
                 NSMutableDictionary *currentTextAttributes = [context propertyValueForName:@"text-attributes"];
                 if(!currentTextAttributes)
                 {
                     currentTextAttributes = [[NSMutableDictionary alloc] initWithCapacity:5];
                     [context setPropertyValue:currentTextAttributes forName:@"text-attributes"];
                 }
                 
                 [currentTextAttributes setObject:context.font
                                           forKey:NSFontAttributeName];
                 
             }],
             
             [[PXPaintStyler alloc] initWithCompletionBlock:^(PXUITextField *view, PXPaintStyler *styler, PXStylerContext *context) {
                 
                 // Get attributes from context, if any
                 NSMutableDictionary *currentTextAttributes = [context propertyValueForName:@"text-attributes"];
                 if(!currentTextAttributes)
                 {
                     currentTextAttributes = [[NSMutableDictionary alloc] initWithCapacity:5];
                     [context setPropertyValue:currentTextAttributes forName:@"text-attributes"];
                 }
                 
                 UIColor *color = (UIColor *)[context propertyValueForName:@"color"];
                 
                 if(color)
                 {
                     [currentTextAttributes setObject:color
                                               forKey:NSForegroundColorAttributeName];
                 }
             }],
             
             [[PXTextContentStyler alloc] initWithCompletionBlock:^(PXUITextField *view, PXTextContentStyler *styler, PXStylerContext *context) {

                 [context setPropertyValue:context.text forName:@"text-value"];
             }],
             
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
        
        attributedText.viewStylers =
        @[
          [[PXAttributedTextStyler alloc] initWithCompletionBlock:^(PXVirtualStyleableControl *styleable, PXAttributedTextStyler *styler, PXStylerContext *context) {
              
              NSMutableDictionary *dict = [context attributedTextAttributes:weakSelf
                                                            withDefaultText:weakSelf.text
                                                                   andColor:weakSelf.textColor];              
              
              NSMutableAttributedString *attrString = nil;
              if(context.transformedText)
              {
                  attrString = [[NSMutableAttributedString alloc] initWithString:context.transformedText attributes:dict];
              }
              
              [weakSelf px_setAttributedText:attrString];
          }]
          ];
        
        NSArray *styleChildren = @[ placeholder, attributedText ];
        
        objc_setAssociatedObject(self, &STYLE_CHILDREN, styleChildren, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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

            [[PXFontStyler alloc] initWithCompletionBlock:^(PXUITextField *view, PXFontStyler *styler, PXStylerContext *context) {
                UIFont *font = context.font;

                if (font)
                {
                    [view px_setFont: font];
                }

            }],

            [[PXColorStyler alloc] initWithCompletionBlock:^(PXUITextField *view, PXColorStyler *styler, PXStylerContext *context) {
                UIColor *color = (UIColor *) [context propertyValueForName:@"color"];
                
                if(color)
                {
                    [view px_setTextColor: color];
                }
            }],

            [[PXTextContentStyler alloc] initWithCompletionBlock:^(PXUITextField *view, PXTextContentStyler *styler, PXStylerContext *context) {
                [view px_setText: context.text];
            }],

            [[PXGenericStyler alloc] initWithHandlers: @{
             @"text-align" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXUITextField *view = (PXUITextField *)context.styleable;

                [view px_setTextAlignment: declaration.textAlignmentValue];
             },
             @"-ios-border-style" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXUITextField *view = (PXUITextField *)context.styleable;

                [view px_setBorderStyle:declaration.textBorderStyleValue];
            },
             @"padding" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXUITextField *view = (PXUITextField *)context.styleable;

                view.padding = declaration.offsetsValue;
            },
             @"padding-top" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXUITextField *view = (PXUITextField *)context.styleable;
                PXOffsets *padding = view.padding;
                CGFloat value = declaration.floatValue;

                view.padding = [[PXOffsets alloc] initWithTop:value right:padding.right bottom:padding.bottom left:padding.left];
            },
             @"padding-right" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXUITextField *view = (PXUITextField *)context.styleable;
                PXOffsets *padding = view.padding;
                CGFloat value = declaration.floatValue;

                view.padding = [[PXOffsets alloc] initWithTop:padding.top right:value bottom:padding.bottom left:padding.left];
            },
             @"padding-bottom" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXUITextField *view = (PXUITextField *)context.styleable;
                PXOffsets *padding = view.padding;
                CGFloat value = declaration.floatValue;

                view.padding = [[PXOffsets alloc] initWithTop:padding.top right:padding.right bottom:value left:padding.left];
            },
             @"padding-left" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                PXUITextField *view = (PXUITextField *)context.styleable;
                PXOffsets *padding = view.padding;
                CGFloat value = declaration.floatValue;

                view.padding = [[PXOffsets alloc] initWithTop:padding.top right:padding.right bottom:padding.bottom left:value];
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
    if (context.usesColorOnly)
    {
        [self px_setBackgroundColor: context.color];
    }
    else if (context.usesImage)
    {
        [self px_setBackgroundColor: [UIColor colorWithPatternImage:context.backgroundImage]];
    }
}

//
// Wrappers
//

PX_PXWRAP_1(setText, text);
PX_PXWRAP_1(setPlaceholder, text);
PX_PXWRAP_1(setAttributedText, text);
PX_PXWRAP_1(setAttributedPlaceholder, text);

PX_WRAP_1(setTextColor, color);
PX_WRAP_1(setFont, font);
PX_WRAP_1(setBackgroundColor, color);

PX_WRAP_1v(setTextAlignment, NSTextAlignment, alignment);
PX_WRAP_1v(setBorderStyle, UITextBorderStyle, style);

#pragma mark - Getters

- (PXOffsets *)padding
{
    return objc_getAssociatedObject(self, &PADDING);
}

#pragma mark - Setters

- (void)setPadding:(PXOffsets *)padding
{
    objc_setAssociatedObject(self, &PADDING, padding, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//
// Overrides
//

PX_LAYOUT_SUBVIEWS_OVERRIDE

-(void)setText:(NSString *)text
{
    callSuper1(SUPER_PREFIX, _cmd, text);
    [PXStyleUtils invalidateStyleableAndDescendants:self];
    [self updateStylesNonRecursively];
}

-(void)setAttributedText:(NSAttributedString *)attributedText
{
    callSuper1(SUPER_PREFIX, _cmd, attributedText);
    [PXStyleUtils invalidateStyleableAndDescendants:self];
    [self updateStylesNonRecursively];
}

-(void)setPlaceholder:(NSString *)placeholder
{
    callSuper1(SUPER_PREFIX, _cmd, placeholder);
    [PXStyleUtils invalidateStyleableAndDescendants:self];
    [self updateStylesNonRecursively];
}

-(void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder
{
    callSuper1(SUPER_PREFIX, _cmd, attributedPlaceholder);
    [PXStyleUtils invalidateStyleableAndDescendants:self];
    [self updateStylesNonRecursively];
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    Class _superClass = [self pxClass];
	struct objc_super mysuper;
	mysuper.receiver = self;
	mysuper.super_class = _superClass;

    CGRect result = ((CGRect(*)(struct objc_super*, SEL, CGRect))objc_msgSendSuper_stret)(&mysuper, @selector(textRectForBounds:), bounds);

    PXOffsets *padding = self.padding;
    result.origin.x = result.origin.x + padding.left;
    result.origin.y = result.origin.y + padding.top;
    result.size.width = result.size.width - (padding.left + padding.right);
    result.size.height = result.size.height - (padding.top + padding.bottom);
    
    return result;
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    Class _superClass = [self pxClass];
	struct objc_super mysuper;
	mysuper.receiver = self;
	mysuper.super_class = _superClass;
    
    CGRect result = ((CGRect(*)(struct objc_super*, SEL, CGRect))objc_msgSendSuper_stret)(&mysuper, @selector(editingRectForBounds:), bounds);

    PXOffsets *padding = self.padding;
    result.origin.x = result.origin.x + padding.left;
    result.origin.y = result.origin.y + padding.top;
    result.size.width = result.size.width - (padding.left + padding.right);
    result.size.height = result.size.height - (padding.top + padding.bottom);
    
    return result;
}

// Notification handlers

- (void)px_TransitionTextField:(UITextField *)textField forState:(NSString *)stateName
{
    [self setPxState:stateName];

    PXTransitionRuleSetInfo *ruleSetInfo = [[PXTransitionRuleSetInfo alloc] initWithStyleable:textField
                                                                             withStateName:stateName];

    if (ruleSetInfo.nonAnimatingRuleSets.count > 0)
    {
        PXStyleInfo *styleInfo = [[PXStyleInfo alloc] initWithStyleKey:textField.styleKey];
        [PXStyleInfo setStyleInfo:styleInfo withRuleSets:ruleSetInfo.nonAnimatingRuleSets styleable:textField stateName:stateName];
        styleInfo.forceInvalidation = YES;
        [styleInfo applyToStyleable:textField];
    }

    if (ruleSetInfo.animatingRuleSets.count > 0)
    {
        PXAnimationInfo *info = (ruleSetInfo.transitions.count > 0) ? [ruleSetInfo.transitions objectAtIndex:0] : nil;

        if (info != nil)
        {
            CATransition* trans = [CATransition animation];

            trans.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            trans.duration = info.animationDuration;
            trans.type = kCATransitionFade;
            trans.subtype = kCATransitionFromTop;
            trans.removedOnCompletion = YES;
            trans.delegate = [[PX_PositionCursorDelegate alloc] initWithTextField:textField];

            [textField.layer removeAllAnimations];
            [textField.layer addAnimation:trans forKey:@"transition"];

            PXStyleInfo *styleInfo = [[PXStyleInfo alloc] initWithStyleKey:textField.styleKey];
            [PXStyleInfo setStyleInfo:styleInfo withRuleSets:ruleSetInfo.ruleSetsForState styleable:textField stateName:stateName];
            [styleInfo applyToStyleable:textField];
        }
    }
}

@end

