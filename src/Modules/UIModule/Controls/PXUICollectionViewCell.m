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
//  PXUICollectionViewCell.m
//  Pixate
//
//  Created by Paul Colton on 10/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXUICollectionViewCell.h"
#import <QuartzCore/QuartzCore.h>

#import "UIView+PXStyling.h"
#import "UIView+PXStyling-Private.h"
#import "PXStylingMacros.h"
#import "PXOpacityStyler.h"
#import "PXLayoutStyler.h"
#import "PXTransformStyler.h"
#import "PXStyleUtils.h"
#import "PXVirtualStyleableControl.h"
#import "PXStyleUtils.h"

#import "PXShapeStyler.h"
#import "PXFillStyler.h"
#import "PXBorderStyler.h"
#import "PXBoxShadowStyler.h"
#import "PXAnimationStyler.h"

static NSDictionary *PSEUDOCLASS_MAP;
static const char STYLE_CHILDREN;

@interface PXUIImageViewWrapper_UICollectionViewCell : UIImageView @end
@implementation PXUIImageViewWrapper_UICollectionViewCell @end

@implementation PXUICollectionViewCell

+ (void)initialize
{
    if (self != PXUICollectionViewCell.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"collection-view-cell"];

    PSEUDOCLASS_MAP = @{
                        @"normal"   : @(UIControlStateNormal),
                        @"selected" : @(UIControlStateSelected)
                        };
}

#pragma mark - Children

- (NSArray *)pxStyleChildren
{
    NSArray *styleChildren;
    PXVirtualStyleableControl *contentView;
    
    if (!objc_getAssociatedObject(self, &STYLE_CHILDREN))
    {
        __weak PXUICollectionViewCell *weakSelf = self;
        
        // content-view
        contentView = [[PXVirtualStyleableControl alloc] initWithParent:self elementName:@"content-view" viewStyleUpdaterBlock:^(PXRuleSet *ruleSet, PXStylerContext *context) {
            
            if (context.usesColorOnly)
            {
                [weakSelf.px_contentView setBackgroundColor: context.color];
            }
            else if (context.usesImage)
            {
                [weakSelf.px_contentView setBackgroundColor:
                 [UIColor colorWithPatternImage:[context backgroundImageWithBounds:weakSelf.px_contentView.bounds]]];
            }
            
        }];
        
        contentView.viewStylers = @[
                                    PXOpacityStyler.sharedInstance,
                                    PXShapeStyler.sharedInstance,
                                    PXFillStyler.sharedInstance,
                                    PXBorderStyler.sharedInstance,
                                    PXBoxShadowStyler.sharedInstance,
                                    ];
        
        styleChildren = @[ contentView ];
        
        objc_setAssociatedObject(self, &STYLE_CHILDREN, styleChildren, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    else
    {
        styleChildren = objc_getAssociatedObject(self, &STYLE_CHILDREN);
        contentView = styleChildren[0];
    }
    
    contentView.pxStyleChildren = self.contentView.subviews;

    return styleChildren;//return [styleChildren arrayByAddingObjectsFromArray:self.subviews];
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

            [[PXOpacityStyler alloc] initWithCompletionBlock:^(PXUICollectionViewCell *view, PXOpacityStyler *styler, PXStylerContext *context) {
                view.px_contentView.alpha = context.opacity;
            }],

            PXShapeStyler.sharedInstance,
            PXFillStyler.sharedInstance,
            PXBorderStyler.sharedInstance,
            PXBoxShadowStyler.sharedInstance,
            
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
    if ([context stateFromStateNameMap:PSEUDOCLASS_MAP] == UIControlStateNormal)
    {
        if(context.usesColorOnly)
        {
            if([context.color isEqual:[UIColor clearColor]])
            {
                [self px_setBackgroundView: nil];
                [self px_setBackgroundColor: [UIColor clearColor]];
            }
            else
            {
                [self px_setBackgroundView: nil];
                [self px_setBackgroundColor: context.color];
            }
        }
        else if (context.usesImage)
        {
            [self px_setBackgroundColor: [UIColor clearColor]];
            
            if([self.px_backgroundView isKindOfClass:[PXUIImageViewWrapper_UICollectionViewCell class]] == NO)
            {
                [self px_setBackgroundView: [[PXUIImageViewWrapper_UICollectionViewCell alloc] initWithImage:context.backgroundImage]];
            }
            else
            {
                PXUIImageViewWrapper_UICollectionViewCell *view = (PXUIImageViewWrapper_UICollectionViewCell *) self.backgroundView;
                view.image = context.backgroundImage;
            }
        }
    }
    else if ([context stateFromStateNameMap:PSEUDOCLASS_MAP] == UIControlStateSelected)
    {
        if(context.usesColorOnly && [context.color isEqual:[UIColor clearColor]])
        {
            [self px_setSelectedBackgroundView: nil];
        }
        else if(context.usesImage)
        {
            if([self.px_selectedBackgroundView isKindOfClass:[PXUIImageViewWrapper_UICollectionViewCell class]] == NO)
            {
                [self px_setSelectedBackgroundView: [[PXUIImageViewWrapper_UICollectionViewCell alloc] initWithImage:context.backgroundImage]];
            }
            else
            {
                PXUIImageViewWrapper_UICollectionViewCell *view = (PXUIImageViewWrapper_UICollectionViewCell *) self.px_selectedBackgroundView;
                view.image = context.backgroundImage;
            }
        }
    }
}

//
// Overrides
//

PX_LAYOUT_SUBVIEWS_OVERRIDE

- (void)prepareForReuse
{
    callSuper0(SUPER_PREFIX, _cmd);
    [PXStyleUtils invalidateStyleableAndDescendants:self];
}

//
// Wrappers
//

// Ti Wrapped
PX_WRAP_PROP(UIView, contentView);
PX_WRAP_PROP(UIView, backgroundView);
PX_WRAP_PROP(UIView, selectedBackgroundView);

PX_WRAP_1(setBackgroundColor, color);
PX_WRAP_1(setBackgroundView, view);
PX_WRAP_1(setSelectedBackgroundView, view);

@end
