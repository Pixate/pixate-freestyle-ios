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
//  PXStylerContext.h
//  Pixate
//
//  Created by Kevin Lindsey on 11/15/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXStyleable.h"
#import "PXShape.h"
#import "PXPaint.h"
#import "PXShadowPaint.h"
#import "PXShadowGroup.h"
#import "PXOffsets.h"
#import "PXDimension.h"
#import "PXAnimationInfo.h"
#import "PXBoxModel.h"

@protocol PXStyler;

@interface PXStylerContext : NSObject

@property (nonatomic, strong) id<PXStyleable> styleable;
@property (nonatomic, strong) NSString *activeStateName;
@property (nonatomic) NSUInteger styleHash;

@property (nonatomic, strong) PXShape *shape;

// This group of properties is for PXLayoutStyler
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGRect bounds;

@property (nonatomic, strong) PXOffsets *padding;
@property (nonatomic) CGAffineTransform transform;

@property (nonatomic, strong) PXBoxModel *boxModel;

@property (nonatomic, strong) id<PXPaint> fill;
@property (nonatomic, strong) id<PXPaint> imageFill;

@property (nonatomic, strong) id<PXShadowPaint> shadow;
@property (nonatomic, strong) id<PXShadowPaint> textShadow;
@property (nonatomic, readonly, strong) PXShadowGroup *innerShadow;
@property (nonatomic, readonly, strong) PXShadowGroup *outerShadow;
@property (nonatomic) CGFloat opacity;

@property (nonatomic, readonly, strong) UIImage *backgroundImage;
@property (nonatomic) CGSize imageSize;
@property (nonatomic) UIEdgeInsets insets;

@property (nonatomic, strong) PXDimension *barMetricsVerticalOffset;

@property (nonatomic, strong) NSString *fontName;
@property (nonatomic, strong) NSString *fontStyle;
@property (nonatomic, strong) NSString *fontWeight;
@property (nonatomic, strong) NSString *fontStretch;
@property (nonatomic) CGFloat fontSize;
@property (nonatomic, readonly, strong) UIFont *font;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *transformedText;
@property (nonatomic) PXDimension *letterSpacing;
@property (nonatomic, strong) NSString *textTransform;
@property (nonatomic, strong) NSString *textDecoration;

// This group of properties is for PXBarShadowStyler
@property (nonatomic) CGRect shadowBounds;
@property (nonatomic) NSURL *shadowUrl;
@property (nonatomic) UIImage *shadowImage;
@property (nonatomic) UIEdgeInsets shadowInsets;
@property (nonatomic) CGFloat shadowPadding;

// This group of properties is for PXAnimationStyler
@property (nonatomic, strong) NSMutableArray *animationInfos;

// This group of properties is for PXTransitionStyler
@property (nonatomic, strong) NSMutableArray *transitionInfos;

/*
 * The background color, if specified
 */
@property (nonatomic, readonly, strong) UIColor *color;

/*
 *  Determine if this styler can use only a color for its styling
 */
@property (nonatomic, readonly) BOOL usesColorOnly;

/*
 *  Determine if this styler needs to use an image for its styling
 */
@property (nonatomic, readonly) BOOL usesImage;

/*
 *  Return the property value for the specifified property name
 *
 *  @param name The name of the property
 */
- (id)propertyValueForName:(NSString *)name;

/*
 *  Set the property value for the specified property name
 *
 *  @param value The new value
 *  @param name The property name
 */
- (void)setPropertyValue:(id)value forName:(NSString *)name;

/*
 *  Return the integer represenation of the current state name, using the specified name->int map
 *
 *  @param map The name-to-NSNumber map
 */
- (int)stateFromStateNameMap:(NSDictionary *)map;

/*
 *  Apply the current outer shadow value to the specified layer
 *
 *  @param layer The CALayer
 */
- (void)applyOuterShadowToLayer:(CALayer *)layer;

/*
 * Return the background image with the specified bounds
 *
 * @param bounds The bounds to size the image to
 */
- (UIImage *)backgroundImageWithBounds:(CGRect) bounds;

/**
 * Transform a string to uppercase, lowercase, or capitalize based on the css selector value.
 * @param value String value to transform
 @ @param attribute CSS selector attribute.
 */
+ (NSString *)transformString:(NSString *)value usingAttribute:(NSString *)attribute;

/**
 * Returns the kern value converted to points (from ems, %, or a lenght measurment).
 */
+ (NSNumber *)kernPointsFrom:(PXDimension *) dimension usingFont:(UIFont *) font;

/**
 * Add decoration attribute to attributed text attributes dictionary based on CSS decoration value (strike-through, underline).
 * @param decoration CSS decoration value (for text-decoration)
 @ @param attribute attributedString attributes dictionary.
 */
+ (void)addDecoration:(NSString *)decoration toAttributes:(NSMutableDictionary *)attributes;

/**
 * Appends or overwrites the appropriate attributes into an attributedTest styles dictionary.
 *  @originalAttributes existing text attributes;
 */
- (NSDictionary *) mergeTextAttributes:(NSDictionary *)originalAttributes;

/**
 * Generates the appropriate attributes in an attributedTest styles dictionary.
 *  @view The text container that attributed text is applied to (must implement font, text);
 *  @param defaultText The text to be used if there is no text set in the css (the source of this can vary on states and components)
 *  @param defaultColor The color to be used if there is no color set in the css (the source of this can vary on states and components)
 */
- (NSMutableDictionary *) attributedTextAttributes:(UIView *)view withDefaultText:(NSString *)text andColor:(UIColor *)defaultColor;

@end
