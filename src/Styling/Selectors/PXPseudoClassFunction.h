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
//  PXPseudoClassFunction.h
//  Pixate
//
//  Created by Kevin Lindsey on 11/27/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXSelector.h"

/**
 *  The PXPseudoClassFunctionType enumeration specifies what nth-child function should be applied
 */
typedef enum
{
    PXPseudoClassFunctionNthChild,
    PXPseudoClassFunctionNthLastChild,
    PXPseudoClassFunctionNthOfType,
    PXPseudoClassFunctionNthLastOfType
} PXPseudoClassFunctionType;

/**
 *  A PXPseudoClassFunction is used to select styleables based on their positions or pattern of positions from the start
 *  or end of their list of siblings
 */
@interface PXPseudoClassFunction : NSObject <PXSelector>

/**
 *  Returns the type of nth-child operation that this selector will perform during matching
 */
@property (nonatomic, readonly) PXPseudoClassFunctionType functionType;

/**
 *  In the expression 'an + b', the modulus corresponds to the 'n' value
 */
@property (nonatomic, readonly) NSInteger modulus;

/**
 *  In the expression 'an + b', the remainder corresponds to the 'b' value
 */
@property (nonatomic, readonly) NSInteger remainder;

/**
 *  Initialize a newly allocation PXPseudoClassFunction
 *
 *  @param type The nth-child operator type
 *  @param modulus The modulus of the nth-child operation
 *  @param remainder The remainder of the nth-child operation
 */
- (id)initWithFunctionType:(PXPseudoClassFunctionType)type modulus:(NSInteger)modulus remainder:(NSInteger)remainder;

@end
