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
//  PXStyler.h
//  Pixate
//
//  Created by Paul Colton on 10/9/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXRuleSet.h"
#import "PXStylerContext.h"

/**
 *  The PXStyler protocol is a collection of methods used to apply styles defined in a PXRuleSet to a PXStyleable
 *  object. Stylers have four phases:
 *
 *  1. setup
 *  2. compute styles
 *  3. apply styles
 *  4. clean up
 *
 *  The setup and cleanup stages are optional and only need to be used if state needs to be initialized before computing
 *  style information or if that state needs to be cleared once styling has completed.
 *
 *  The compute styles phase extracts information from a ruleSet and may use the view to be styled when performing those
 *  calcuations.
 *
 *  The apply styles phase creates any instances needed for styling and applies these to the PXStyleable instance.
 */
@protocol PXStyler <NSObject>

@required

/**
 *  The list of properties supported by this styler
 */
@property (nonatomic, readonly) NSArray *supportedProperties;

/**
 *  Calcuate styling information using the specified declaration. This will be called once for each property name
 *  supported by the styler.
 *
 *  @param declaration The declaration to process
 *  @param context The styler context
 */
- (void)processDeclaration:(PXDeclaration *)declaration withContext:(PXStylerContext *)context;

/**
 *  Apply the computed styles to the specified view. Note that it is expected that computeStylesForView:withRuleSet: has
 *  already been called.
 *
 *  @param context The styler context
 */
- (void)applyStylesWithContext:(PXStylerContext *)context;

@end
