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
//  PXAttributeSelectorOperator.m
//  Pixate
//
//  Created by Kevin Lindsey on 9/1/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXAttributeSelectorOperator.h"
#import "PXStyleable.h"
#import "PXSpecificity.h"
#import "PXStyleUtils.h"

@implementation PXAttributeSelectorOperator

@synthesize operatorType = _operatorType;
@synthesize attributeSelector = _attributeSelector;
@synthesize value = _value;

#ifdef PX_LOGGING
static int ddLogLevel = LOG_LEVEL_WARN;

+ (int)ddLogLevel
{
    return ddLogLevel;
}

+ (void)ddSetLogLevel:(int)logLevel
{
    ddLogLevel = logLevel;
}
#endif

#pragma mark - Initializers

- (id)initWithOperatorType:(PXAttributeSelectorOperatorType)type
         attributeSelector:(PXAttributeSelector *)attributeSelector
               stringValue:(NSString *)value
{
    if (self = [super init])
    {
        self->_operatorType = type;
        self->_attributeSelector = attributeSelector;
        self->_value = value;
    }

    return self;
}

#pragma mark - PXAttributeMatcher Implementation

- (void)incrementSpecificity:(PXSpecificity *)specificity
{
    [specificity incrementSpecifity:kSpecificityTypeClassOrAttribute];
}

- (BOOL)matches:(id<PXStyleable>)element
{
    BOOL result = NO;

    if ([element respondsToSelector:@selector(attributeValueForName:withNamespace:)])
    {
        NSString *value = [element attributeValueForName:_attributeSelector.attributeName withNamespace:_attributeSelector.namespaceURI];

        switch (_operatorType)
        {
            case kAttributeSelectorOperatorStartsWith:
                result = [value hasPrefix:_value];
                break;

            case kAttributeSelectorOperatorEndsWith:
                result = [value hasSuffix:_value];
                break;

            case kAttributeSelectorOperatorContains:
                result = (value && [value rangeOfString:_value].location != NSNotFound);
                break;

            case kAttributeSelectorOperatorEqual:
                result = [_value isEqualToString:value];
                break;

            case kAttributeSelectorOperatorListContains:
            {
                NSArray *components = [value componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

                result = [components containsObject:_value];
                break;
            }

            case kAttributeSelectorOperatorEqualWithHyphen:
            {
                result = [_value isEqualToString:value];

                if (!result)
                {
                    NSString *hypenatedValue = [NSString stringWithFormat:@"%@-", _value];

                    result = [value hasPrefix:hypenatedValue];
                }
                break;
            }
        }
    }

    if (result)
    {
        DDLogVerbose(@"%@ matched %@", self.description, [PXStyleUtils descriptionForStyleable:element]);
    }
    else
    {
        DDLogVerbose(@"%@ did not match %@", self.description, [PXStyleUtils descriptionForStyleable:element]);
    }

    return result;
}

#pragma mark - Overrides

- (NSString *)description
{
    NSString *operator;

    switch (_operatorType)
    {
        case kAttributeSelectorOperatorContains: operator = @"*="; break;
        case kAttributeSelectorOperatorEndsWith: operator = @"$="; break;
        case kAttributeSelectorOperatorEqual: operator = @"="; break;
        case kAttributeSelectorOperatorEqualWithHyphen: operator = @"|="; break;
        case kAttributeSelectorOperatorListContains: operator = @"~="; break;
        case kAttributeSelectorOperatorStartsWith: operator = @"^="; break;
    }

    if (_attributeSelector.namespaceURI)
    {
        return [NSString stringWithFormat:@"%@|%@%@%@", _attributeSelector.namespaceURI, _attributeSelector.attributeName, operator, _value];
    }
    else
    {
        return [NSString stringWithFormat:@"*|%@%@%@", _attributeSelector.attributeName, operator, _value];
    }
}

@end
