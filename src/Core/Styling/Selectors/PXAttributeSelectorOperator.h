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
//  PXAttributeSelectorOperator.h
//  Pixate
//
//  Created by Kevin Lindsey on 9/1/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXSelector.h"
#import "PXAttributeSelector.h"

/**
 *  The PXAttributeSelectorOperatorType enumeration defines the operators available when matching the content of an
 *  attribute against a value.
 */
typedef enum
{
    kAttributeSelectorOperatorStartsWith,
    kAttributeSelectorOperatorEndsWith,
    kAttributeSelectorOperatorContains,
    kAttributeSelectorOperatorEqual,
    kAttributeSelectorOperatorListContains,
    kAttributeSelectorOperatorEqualWithHyphen
} PXAttributeSelectorOperatorType;

/**
 *  A PXAttributeSelectorOperator is used to determine if the given attribute matches a value, using a specific string
 *  matching operator.
 */
@interface PXAttributeSelectorOperator : NSObject <PXSelector>

/**
 *  The type of match to be performed on the attribute value
 */
@property (nonatomic, readonly) PXAttributeSelectorOperatorType operatorType;

/**
 *  The attribute to match
 */
@property (nonatomic, readonly, strong) PXAttributeSelector *attributeSelector;

/**
 *  The value to be used by the operator type during matching
 */
@property (nonatomic, readonly, strong) NSString *value;

/**
 *  Initialize a new instance using the specified lhs, operator, and rhs of the operator expression.
 *
 *  @param type The operator type
 *  @param attributeSelector The attribute selector to which the operator will be applied
 *  @param value The string value used by the operator when matching the matched attribute's value
 */
- (id)initWithOperatorType:(PXAttributeSelectorOperatorType)type
         attributeSelector:(PXAttributeSelector *)attributeSelector
               stringValue:(NSString *)value;

@end
