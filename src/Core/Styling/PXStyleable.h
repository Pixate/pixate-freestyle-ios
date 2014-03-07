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
//  PXStyleable.h
//  Pixate
//
//  Created by Kevin Lindsey on 7/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  An enumeration indicating the styling mode
 */
typedef enum
{
    PXStylingUndefined = 0, // undefined
    PXStylingNormal,        // normal
    PXStylingNone           // none
    
} PXStylingMode;

@class PXRuleSet;

/**
 *  The PXStyleable protocol defines a set of properties and methods needed in order to style a given object.
 */
@protocol PXStyleable <NSObject>

@required

/**
 *  The ID for this styleable object. Ideally, this value should be unique within the context being styled.
 */
@property (nonatomic, copy) NSString *styleId;

/**
 *  The CSS classes associated with this styleable object. One or more classes may be specified by delimiting each with
 *  whitespace
 */
@property (nonatomic, copy) NSString *styleClass;

/**
*  Return an array of the styleClass separated by whitespace for faster performance
*/
@property (nonatomic, readonly) NSArray *styleClasses;

/**
 *  For support in cache, programing change style or class style
 */
@property (nonatomic) BOOL styleChangeable;

/**
 * The styling mode of the styleable as defined by the PXStylingMode enumeration.
 */
@property (nonatomic) PXStylingMode styleMode;

/**
 *  The element name to use when matching this styleable object against a selector
 */
@property (readonly, nonatomic, copy) NSString *pxStyleElementName;

/**
 *  The style parent that contains this object
 */
@property (readonly, nonatomic, weak) id pxStyleParent;

/**
 *  The style children owned by this object
 */
@property (readonly, nonatomic, copy) NSArray *pxStyleChildren;

/**
 *  The bounds of the item being styled
 */
@property (nonatomic) CGRect bounds;

/**
 *  The frame of the item being styled
 */
@property (nonatomic) CGRect frame;

/**
 *  Return a key used to classify this styleable
 */
- (NSString *)styleKey;

@optional

/**
 *  Update styles for this styleable and all of its descendant styleables
 */
- (void)updateStyles;

/**
 *  Update styles for this styleable only
 */
- (void)updateStylesNonRecursively;

/**
 *  Update styles for this styleable and all of its descendant styleables asynchronously
 */
- (void)updateStylesAsync;

/**
 *  Update styles for this styleable only asynchronously
 */
- (void)updateStylesNonRecursivelyAsync;

/**
 *  Inline styles to apply to this object
 */
@property (nonatomic, copy) NSString *styleCSS;


/**
 *  Return the namespace URI associated with this object
 */
@property (readonly, nonatomic, copy) NSString *pxStyleNamespace;

/**
 *  Return a list of pseudo-classes that are recognized by this object
 */
@property (readonly, nonatomic, copy) NSArray *supportedPseudoClasses;

/**
 *  Return the default pseudo-class associated with this object when none is specified in a selector
 */
@property (readonly, nonatomic, copy) NSString *defaultPseudoClass;

/**
 *  Return a boolean indicating if the styleable is able to style the specified pseudoClass. This is particularly
 *  helpful with styleables that define pseudo-states (for example, UITextField) where the styleable can only have a
 *  a given pseudoClass (state) applied to it if it is on that state already. Instances that do not implement this
 *  method will assume this method was called and it returned YES
 */
- (BOOL)canStylePseudoClass:(NSString *)pseudoClass;

/**
 *  Return a boolean indicating if this styleable should be excluded from styling. Instances that do not implement this
 *  method will assume this method was called and it returned NO
 */
- (BOOL)preventStyling;

/**
 *  Return a list of pseudo-elements that are recognized by this object
 */
@property (readonly, nonatomic, copy) NSArray *supportedPseudoElements;

/**
 *  Register any NSNotificationCenter notifications needed by this object
 */
- (void)registerNotifications;

/**
 *  Return a string value for the specified attribute name. If the name does not exist, a nil value should be returned
 *
 *  @param name The name of the attribute
 *  @param aNamespace The namespace of the attribute. This may be nil
 */
- (NSString *)attributeValueForName:(NSString *)name withNamespace:(NSString *)aNamespace;

/**
 *  Return the styleable associated with the given pseudo-element
 *
 *  @param pseudoElement The pseudo-element name
 */
- (id<PXStyleable>)styleableForPseudoElement:(NSString *)pseudoElement;

/**
 *  Return a dictionary for animatable properties
 */
- (NSDictionary *)animationPropertyHandlers;

@end
