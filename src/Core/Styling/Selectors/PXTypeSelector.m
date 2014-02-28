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
//  PXTypeSelector.m
//  Pixate
//
//  Created by Kevin Lindsey on 7/9/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXTypeSelector.h"
#import "PXPseudoClassSelector.h"
#import "PXStyleUtils.h"
#import "PXIdSelector.h"
#import "PXClassSelector.h"

@implementation PXTypeSelector
{
    NSMutableArray *attributeExpressions;
}

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

- (id)init
{
    return [self initWithNamespaceURI:@"*" typeName:@"*"];
}

- (id)initWithTypeName:(NSString *)type
{
    return [self initWithNamespaceURI:@"*" typeName:type];
}

- (id)initWithNamespaceURI:(NSString *)uri typeName:(NSString *)type
{
    if (self = [super init])
    {
        _namespaceURI = uri;
        _typeName = type;
    }

    return self;
}

#pragma mark - Getters

- (BOOL)hasUniversalNamespace
{
    return [@"*" isEqualToString:_namespaceURI];
}

- (BOOL)hasUniversalType
{
    return [@"*" isEqualToString:_typeName];
}

- (NSArray *)attributeExpressions
{
    return [NSArray arrayWithArray:attributeExpressions];
}

- (BOOL)hasPseudoClasses
{
    BOOL result = NO;

    for (id selector in attributeExpressions)
    {
        if ([selector isKindOfClass:[PXPseudoClassSelector class]])
        {
            result = YES;
            break;
        }
    }

    return result;
}

- (NSString *)styleId
{
    NSString *result = nil;

    for (id<PXSelector> expression in attributeExpressions)
    {
        if ([expression isKindOfClass:[PXIdSelector class]])
        {
            PXIdSelector *idSelector = (PXIdSelector *)expression;
            result = idSelector.idValue;
            break;
        }
    }

    return result;
}

- (NSArray *)styleClasses
{
    NSMutableArray *result = nil;

    for (id<PXSelector> expression in attributeExpressions)
    {
        if ([expression isKindOfClass:[PXClassSelector class]])
        {
            PXClassSelector *classSelector = (PXClassSelector *)expression;

            if (result == nil)
            {
                result = [NSMutableArray array];
            }

            [result addObject:classSelector.className];
        }
    }

    return (result != nil) ? [NSArray arrayWithArray:result] : nil;
}

#pragma mark - Methods

- (void)addAttributeExpression:(id<PXSelector>)expression
{
    if (expression)
    {
        if (!attributeExpressions)
        {
            attributeExpressions = [NSMutableArray array];
        }

        [attributeExpressions addObject:expression];
    }
}

- (void)incrementSpecificity:(PXSpecificity *)specificity
{
    if (!self.hasUniversalType)
    {
        [specificity incrementSpecifity:kSpecificityTypeElement];
    }

    if (self.pseudoElement.length > 0)
    {
        [specificity incrementSpecifity:kSpecificityTypeElement];
    }

    for (PXIdSelector *expr in attributeExpressions)
    {
        [expr incrementSpecificity:specificity];
    }
}

- (BOOL)matches:(id<PXStyleable>)element
{
    BOOL result = NO;

    // filter by namespace
    if (self.hasUniversalNamespace)
    {
        result = YES;
    }
    else
    {
        if ([element respondsToSelector:@selector(pxStyleNamespace)])
        {
            NSString *elementNamespace = element.pxStyleNamespace;

            if (_namespaceURI == nil)
            {
                // there should be namespace on the element
                result = (elementNamespace.length == 0);
            }
            else
            {
                // the URIs should match
                result = [_namespaceURI isEqualToString:element.pxStyleNamespace];
            }
        }
    }

    // filter by type name
    if (result)
    {
        if (self.hasUniversalType == NO)
        {
            result = ([_typeName isEqualToString:element.pxStyleElementName]);
        }
    }

    // filter by attribute expresssion
    if (result)
    {
        for (id<PXSelector> expression in attributeExpressions)
        {
            if (![expression matches:element])
            {
                result = NO;
                break;
            }
        }
    }

    // filter by pseudo-element
    if (result)
    {
        if (self.pseudoElement.length > 0)
        {
            if ([element respondsToSelector:@selector(supportedPseudoElements)])
            {
                result = ([[element supportedPseudoElements] indexOfObject:self.pseudoElement] != NSNotFound);
            }
            else
            {
                result = NO;
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

- (BOOL)hasPseudoClass:(NSString *)className
{
    BOOL result = NO;

    for (id<PXSelector> selector in attributeExpressions)
    {
        if ([selector isKindOfClass:[PXPseudoClassSelector class]])
        {
            PXPseudoClassSelector *pseudoClass = selector;

            if ([pseudoClass.className isEqualToString:className])
            {
                result = YES;
                break;
            }
        }
    }

    return result;
}

#pragma mark - PXSourceEmitter Methods

- (NSString *)source
{
    PXSourceWriter *writer = [[PXSourceWriter alloc] init];

    [self sourceWithSourceWriter:writer];

    return writer.description;
}

- (void)sourceWithSourceWriter:(id)writer
{
    // TODO: support namespace
    [writer printIndent];
    [writer print:@"("];

    if (self.hasUniversalType)
    {
        [writer print:@"*"];
    }
    else
    {
        [writer print:self.typeName];
    }

    if (attributeExpressions.count > 0)
    {
        [writer increaseIndent];

        for (id<PXSelector> expr in attributeExpressions)
        {
            [writer printNewLine];
            [expr sourceWithSourceWriter:writer];
        }

        [writer decreaseIndent];
    }

    if (self.pseudoElement.length > 0)
    {
        [writer increaseIndent];

        [writer printNewLine];
        [writer printIndent];
        [writer print:@"(PSEUDO_ELEMENT "];
        [writer print:self.pseudoElement];
        [writer print:@")"];

        [writer decreaseIndent];
    }

    [writer print:@")"];
}

#pragma mark - Overrides

- (NSString *)description
{
    NSMutableArray *parts = [NSMutableArray array];

    if ([self hasUniversalNamespace])
    {
        [parts addObject:@"*"];
    }
    else
    {
        if (_namespaceURI)
        {
            [parts addObject:_namespaceURI];
        }
    }

    [parts addObject:@"|"];

    if ([self hasUniversalType])
    {
        [parts addObject:@"*"];
    }
    else
    {
        [parts addObject:_typeName];
    }

    for (id expr in attributeExpressions)
    {
        [parts addObject:[NSString stringWithFormat:@"%@", expr]];
    }

    if (self.pseudoElement.length > 0)
    {
        [parts addObject:[NSString stringWithFormat:@"::%@", self.pseudoElement]];
    }

    return [parts componentsJoinedByString:@""];
}

@end
