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
//  PXUITableViewHeaderFooterView.m
//  Pixate
//
//  Created by Paul Colton on 11/1/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXUITableViewHeaderFooterView.h"
#import <QuartzCore/QuartzCore.h>

#import "UIView+PXStyling.h"
#import "UIView+PXStyling-Private.h"
#import "PXStylingMacros.h"
#import "PXVirtualStyleableControl.h"
#import "PXStyleUtils.h"

#import "PXOpacityStyler.h"
#import "PXTransformStyler.h"
#import "PXLayoutStyler.h"

#import "PXShapeStyler.h"
#import "PXFillStyler.h"
#import "PXBorderStyler.h"
#import "PXBoxShadowStyler.h"
#import "PXAnimationStyler.h"
#import "PXFontStyler.h"
#import "PXPaintStyler.h"
#import "PXTextContentStyler.h"
#import "PXGenericStyler.h"
#import "PXAttributedTextStyler.h"

static const char STYLE_CHILDREN;
static NSDictionary *LABEL_PSEUDOCLASS_MAP;

@implementation PXUITableViewHeaderFooterView

+ (void)initialize
{
    if (self != PXUITableViewHeaderFooterView.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"table-view-headerfooter-view"];
    
    LABEL_PSEUDOCLASS_MAP = @{
                              @"normal"      : @(UIControlStateNormal),
                              @"highlighted" : @(UIControlStateHighlighted),
                              };

}

#pragma mark - Children

- (NSArray *)pxStyleChildren
{
    if (!objc_getAssociatedObject(self, &STYLE_CHILDREN))
    {
        __weak PXUITableViewHeaderFooterView *weakSelf = self;
        
        //
        // background-view
        //
        PXVirtualStyleableControl *backgroundView = [[PXVirtualStyleableControl alloc] initWithParent:self elementName:@"background-view" viewStyleUpdaterBlock:^(PXRuleSet *ruleSet, PXStylerContext *context) {
            
            if(context.usesColorOnly && [context.color isEqual:[UIColor clearColor]])
            {
                [weakSelf px_setBackgroundView: nil];
            }
            else
            {
                [weakSelf px_setBackgroundView: [[UIImageView alloc] initWithImage:context.backgroundImage]];
            }
        }];
        
        backgroundView.viewStylers = @[
                                       PXOpacityStyler.sharedInstance,
                                       PXShapeStyler.sharedInstance,
                                       PXFillStyler.sharedInstance,
                                       PXBorderStyler.sharedInstance,
                                       PXBoxShadowStyler.sharedInstance,
                                       ];
        
        //
        // textLabel
        //
        PXVirtualStyleableControl *textLabel = [[PXVirtualStyleableControl alloc] initWithParent:self elementName:@"text-label" viewStyleUpdaterBlock:^(PXRuleSet *ruleSet, PXStylerContext *context) {
            
            if (context.usesColorOnly)
            {
//                objc_setAssociatedObject(weakSelf, &TEXT_LABEL_BACKGROUND_SET, context.color, OBJC_ASSOCIATION_COPY_NONATOMIC);
                
                weakSelf.textLabel.backgroundColor = context.color;
            }
            else if (context.usesImage)
            {
                UIColor *color = [UIColor colorWithPatternImage:context.backgroundImage];
//                objc_setAssociatedObject(weakSelf, &TEXT_LABEL_BACKGROUND_SET, color, OBJC_ASSOCIATION_COPY_NONATOMIC);
                
                weakSelf.textLabel.backgroundColor = color;
            }
        }];
        
        textLabel.supportedPseudoClasses = LABEL_PSEUDOCLASS_MAP.allKeys;
        textLabel.defaultPseudoClass = @"normal";
        textLabel.layer = weakSelf.textLabel.layer;

        textLabel.viewStylers = @[
                                  
                                  PXTransformStyler.sharedInstance,
                                  PXLayoutStyler.sharedInstance,
                                  PXOpacityStyler.sharedInstance,
                                  
                                  PXShapeStyler.sharedInstance,
                                  PXFillStyler.sharedInstance,
                                  PXBorderStyler.sharedInstance,
                                  
                                  [[PXBoxShadowStyler alloc] initWithCompletionBlock:^(id control, PXBoxShadowStyler *styler, PXStylerContext *context) {
                                      PXShadowGroup *group = context.outerShadow;
                                      UILabel *view = weakSelf.textLabel;
                                      
                                      if (group.shadows.count > 0)
                                      {
                                          PXShadow *shadow = [[group shadows] objectAtIndex:0];
                                          
                                          [view setShadowColor: shadow.color];
                                          [view setShadowOffset: CGSizeMake(shadow.horizontalOffset, shadow.verticalOffset)];
                                      }
                                      else
                                      {
                                          [view setShadowColor: [UIColor clearColor]];
                                          [view setShadowOffset: CGSizeZero];
                                      }
                                  }],
                                  
                                  [[PXFontStyler alloc] initWithCompletionBlock:^(id control, PXFontStyler *styler, PXStylerContext *context) {
                                      UILabel *view = weakSelf.textLabel;
                                      [view setFont:context.font];
                                  }],
                                  
                                  [[PXPaintStyler alloc] initWithCompletionBlock:^(id control, PXPaintStyler *styler, PXStylerContext *context) {
                                      UIColor *color = (UIColor *)[context propertyValueForName:@"color"];
                                      UILabel *view = weakSelf.textLabel;
                                      
                                      if(color)
                                      {
                                          if([context stateFromStateNameMap:LABEL_PSEUDOCLASS_MAP] == UIControlStateHighlighted)
                                          {
                                              [view setHighlightedTextColor:color];
                                          }
                                          else
                                          {
                                              [view setTextColor:color];
                                          }
                                      }
                                  }],
                                  
                                  [[PXTextContentStyler alloc] initWithCompletionBlock:^(id control, PXTextContentStyler *styler, PXStylerContext *context) {
                                      UILabel *view = weakSelf.textLabel;
                                      [view setText:context.text];
                                  }],
                                  
                                  [[PXGenericStyler alloc] initWithHandlers: @{
                                                                               
                                   @"text-align" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                                      UILabel *view = weakSelf.textLabel;
                                      [view setTextAlignment:declaration.textAlignmentValue];
                                  },
                                   @"text-transform" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                                      UILabel *view = weakSelf.textLabel;
                                      [view setText:[PXStylerContext transformString:view.text usingAttribute:declaration.stringValue]];
                                  },
                                   @"text-overflow" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                                      UILabel *view = weakSelf.textLabel;
                                      [view setLineBreakMode:declaration.lineBreakModeValue];
                                  }
                                                                               }],
                                  PXAnimationStyler.sharedInstance
                                  ];

        
        // attributed text
        PXVirtualStyleableControl *attributedTextLabel =
        [[PXVirtualStyleableControl alloc] initWithParent:self
                                              elementName:@"attributed-text-label"
                                    viewStyleUpdaterBlock:^(PXRuleSet *ruleSet, PXStylerContext *context) {
                                        // nothing for now
                                    }];
        
        attributedTextLabel.supportedPseudoClasses = LABEL_PSEUDOCLASS_MAP.allKeys;
        attributedTextLabel.defaultPseudoClass = @"normal";
        
        attributedTextLabel.viewStylers = @[
            [[PXAttributedTextStyler alloc] initWithCompletionBlock:^(PXVirtualStyleableControl *styleable, PXAttributedTextStyler *styler, PXStylerContext *context) {

                UILabel *view = weakSelf.textLabel;
                UIControlState state = ([context stateFromStateNameMap:LABEL_PSEUDOCLASS_MAP]);
                
                UIColor *color = (UIColor *)[context propertyValueForName:@"color"];
                if(color)
                {
                    if(state == UIControlStateHighlighted)
                    {
                        [view setHighlightedTextColor:color];
                    }
                    else
                    {
                        [view setTextColor:color];
                    }
                }
                
                NSString *text = view.attributedText ? view.attributedText.string : view.text;
                
                NSMutableDictionary *dict = [context attributedTextAttributes:view withDefaultText:text andColor:color];
                
                NSMutableAttributedString *attrString = nil;
                if(context.transformedText)
                {
                    attrString = [[NSMutableAttributedString alloc] initWithString:context.transformedText attributes:dict];
                }
                
                [view setAttributedText:attrString];
            }]
        ];
        
        
        
        NSArray *styleChildren = @[ backgroundView, textLabel ];
        
        objc_setAssociatedObject(self, &STYLE_CHILDREN, styleChildren, OBJC_ASSOCIATION_COPY_NONATOMIC);
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

            [[PXOpacityStyler alloc] initWithCompletionBlock:^(PXUITableViewHeaderFooterView *view, PXOpacityStyler *styler, PXStylerContext *context) {
                view.px_contentView.alpha = context.opacity;
            }],

            PXShapeStyler.sharedInstance,
            PXFillStyler.sharedInstance,
            PXBorderStyler.sharedInstance,
            PXBoxShadowStyler.sharedInstance,

            PXAnimationStyler.sharedInstance,
            
            PXPaintStyler.sharedInstanceForTintColor,
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
        [self.px_contentView setBackgroundColor: context.color];
    }
    else if (context.usesImage)
    {
        [self.px_contentView setBackgroundColor:
         [UIColor colorWithPatternImage:[context backgroundImageWithBounds:self.px_contentView.bounds]]];
    }
}

//
// Overrides
//

// Invalidate outselves for styling when we get reused otherwise, we may not get restyled.
- (void)prepareForReuse
{
    callSuper0(SUPER_PREFIX, _cmd);
    [PXStyleUtils invalidateStyleableAndDescendants:self];
}

- (id)pxStyleParent
{
    UIView *parent = self.superview;
    
    while([parent isKindOfClass:[UITableView class]] == false)
    {
        if(parent == nil)
        {
            break;
        }
        parent = parent.superview;
    }
    
    return parent;
    
}

//
// Wrappers
//

PX_WRAP_PROP(UIView, contentView);
PX_WRAP_1(setBackgroundView, view);
PX_WRAP_1(setBackgroundColor, color);

@end
