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
//  PXAttributeSelector.h
//  Pixate
//
//  Created by Kevin Lindsey on 9/1/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXSelector.h"

/**
 *  A PXAttributeSelector is used to determine if a given element has a specific attribute defined on it.
 */
@interface PXAttributeSelector : NSObject <PXSelector>

/**
 *  The attribute namespace URI to match. This value may be nil
 */
@property (readonly, nonatomic, strong) NSString *namespaceURI;

/**
 *  The attribute name to match. This value may be nil
 */
@property (readonly, nonatomic, strong) NSString *attributeName;

/**
 *  Initialize a new instance using the specified type name
 *
 *  @param name The attribute name to match
 */
- (id)initWithAttributeName:(NSString *)name;

/**
 *  Initialize a new instance using the specified namespace and name
 *
 *  @param uri The attribute namespace URI to match
 *  @param name The attribute name to match
 */
- (id)initWithNamespaceURI:(NSString *)uri attributeName:(NSString *)name;

@end
