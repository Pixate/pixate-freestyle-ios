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
//  PXPseudoClassPredicate.h
//  Pixate
//
//  Created by Kevin Lindsey on 11/26/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXSelector.h"

/**
 *  The PXPseudoClassPredicateType enumeration specifies what test should be performed during a match operation
 */
typedef enum
{
    PXPseudoClassPredicateRoot,
    PXPseudoClassPredicateFirstChild,
    PXPseudoClassPredicateLastChild,
    PXPseudoClassPredicateFirstOfType,
    PXPseudoClassPredicateLastOfType,
    PXPseudoClassPredicateOnlyChild,
    PXPseudoClassPredicateOnlyOfType,
    PXPseudoClassPredicateEmpty
} PXPseudoClassPredicateType;

/**
 *  A PXPseudoClassPredicate is a selector that asks a true or false question of the styleable attempting to be matched.
 *  These questions, or predicates, determine position of the element among its siblings, whether this is the root
 *  view, or if it has no children
 */
@interface PXPseudoClassPredicate : NSObject <PXSelector>

/**
 *  This indicates what type of predicate will be performed during a match operation
 */
@property (nonatomic, readonly) PXPseudoClassPredicateType predicateType;

/**
 *  Initialize a newly allocated instance, setting its operation type
 *
 *  @param type The predicate type
 */
- (id)initWithPredicateType:(PXPseudoClassPredicateType)type;

@end
