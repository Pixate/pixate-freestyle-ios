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
//  PXCombinatorBase.h
//  Pixate
//
//  Created by Kevin Lindsey on 9/25/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXCombinator.h"

/**
 *  The PXCombinatorBase is an abstract base class used to capture the common functionality of all combinators in one
 *  place. Instances of this class should not be created.
 */
@interface PXCombinatorBase : NSObject <PXCombinator>

/**
 *  A text representation of this combinator used for debugging and testing
 */
@property (nonatomic, readonly, strong) NSString *displayName;

/**
 *  Initialize a new instance with the specified left- and right-side selectors
 *
 *  @param lhs The selector to the left of this combinator
 *  @param rhs The selector to the right of this combinator
 */
- (id)initWithLHS:(id<PXSelector>)lhs RHS:(id<PXSelector>)rhs;

@end
