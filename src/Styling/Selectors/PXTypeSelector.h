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
//  PXTypeSelector.h
//  Pixate
//
//  Created by Kevin Lindsey on 7/9/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXStyleable.h"
#import "PXSelector.h"
#import "PXSpecificity.h"

/**
 *  A PXTypeSelector is reponsible for matching an element by namespace (optional) and name.
 */
@interface PXTypeSelector : NSObject <PXSelector>

/**
 *  The element/type namespace URI to match. This value may be nil
 */
@property (readonly, nonatomic, strong) NSString *namespaceURI;

/**
 *  The element/type namespace prefix to match. This value may be nil
 */
@property (readonly, nonatomic, strong) NSString *typeName;

/**
 *  The selector uses a universal namespace
 */
@property (readonly, nonatomic) BOOL hasUniversalNamespace;

/**
 *  The selector uses a universal type
 */
@property (readonly, nonatomic) BOOL hasUniversalType;

/**
 *  A unmutable list of attribute expressions associated with this selector
 */
@property (readonly, nonatomic, strong) NSArray *attributeExpressions;

/**
 *  Determine if this selector contains any pseudo-classes
 */
@property (readonly, nonatomic) BOOL hasPseudoClasses;

/**
 *  The pseudo-element associated with this selector. This value may be nil
 */
@property (nonatomic, strong) NSString *pseudoElement;

/**
 *  The style ID associated with this selector. This value may be nil
 */
@property (readonly, nonatomic) NSString *styleId;

/**
 *  The style classes associated with this selector. This may be nil
 */
@property (readonly, nonatomic) NSArray *styleClasses;

/**
 *  Initialize a new instance with the specified element name
 *
 *  @param type The element name to match
 */
- (id)initWithTypeName:(NSString *)type;

/**
 *  Initializer a new instance with the specified element namespace and name
 *
 *  @param uri The element namespace URI to match
 *  @param type The element name to match
 */
- (id)initWithNamespaceURI:(NSString *)uri typeName:(NSString *)type;

/**
 *  Add an attribute expression to this selector. This selector matches only if it and it's attribute expressions all
 *  match
 *
 *  @param expression The expression to add to this selector
 */
- (void)addAttributeExpression:(id<PXSelector>)expression;

/**
 *  Determine if this selector contains a pseudo-class for the given type
 *
 *  @param className The pseudo-class name
 */
- (BOOL)hasPseudoClass:(NSString *)className;

@end
