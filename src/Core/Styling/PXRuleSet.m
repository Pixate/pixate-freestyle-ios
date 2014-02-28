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
//  PXRuleSet.m
//  Pixate
//
//  Created by Kevin Lindsey on 7/3/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXRuleSet.h"
#import "PXSourceWriter.h"
#import "PXShapeView.h"
#import "PXFontRegistry.h"
#import "PXCombinator.h"

@implementation PXRuleSet
{
    NSMutableArray *selectors;
}

#pragma mark - Static initializers

+ (id)ruleSetWithMergedRuleSets:(NSArray *)ruleSets
{
    PXRuleSet *result = [[PXRuleSet alloc] init];

    if (ruleSets.count > 0)
    {
        // order rules by specificity
        NSArray *sortedRuleSets =
            [ruleSets sortedArrayUsingComparator:^NSComparisonResult(PXRuleSet *a, PXRuleSet *b)
             {
                 return [a.specificity compareSpecificity:b.specificity];
             }];

        for (PXRuleSet *ruleSet in [sortedRuleSets reverseObjectEnumerator])
        {
            // add selectors
            for (id<PXSelector> selector in ruleSet.selectors)
            {
                [result addSelector:selector];
            }

            // add declarations
            for (PXDeclaration *declaration in ruleSet.declarations)
            {
                if ([result hasDeclarationForName:declaration.name])
                {
                    if (declaration.important)
                    {
                        PXDeclaration *addedDeclaration = [result declarationForName:declaration.name];

                        if (addedDeclaration.important == NO)
                        {
                            // replace old with this !important one
                            [result removeDeclaration:addedDeclaration];
                            [result addDeclaration:declaration];
                        }
                    }
                }
                else
                {
                    [result addDeclaration:declaration];
                }
            }
        }
    }

    return result;
}

#pragma mark - Initializers

- (id)init
{
    if (self = [super init])
    {
        _specificity = [[PXSpecificity alloc] init];
    }

    return self;
}

#pragma mark - Getters

- (NSArray *)selectors
{
    NSArray *result = nil;

    if (selectors)
    {
        result = [NSArray arrayWithArray:selectors];
    }

    return result;
}

- (PXTypeSelector *)targetTypeSelector
{
    PXTypeSelector *result = nil;

    if (selectors.count > 0)
    {
        id candidate = [selectors objectAtIndex:0];

        if (candidate)
        {
            if ([candidate conformsToProtocol:@protocol(PXCombinator)])
            {
                id<PXCombinator> combinator = candidate;

                // NOTE: PXStylesheetParser grows expressions down and to the left. This guarantees that the top-most nodes
                // RHS will be a type selector, and will be the last in the expression
                result = combinator.rhs;
            }
            else if ([candidate isKindOfClass:[PXTypeSelector class]])
            {
                result = candidate;
            }
        }
    }

    return result;
}

#pragma mark - Methods

- (void)addSelector:(id<PXSelector>)selector
{
    if (selector)
    {
        if (!selectors)
        {
            selectors = [NSMutableArray array];
        }

        [selectors addObject:selector];

        [selector incrementSpecificity:_specificity];
    }
}

- (BOOL)matches:(id<PXStyleable>)element
{
    BOOL result = NO;

    if (element && selectors.count > 0)
    {
        result = YES;

        for (PXTypeSelector *selector in selectors)
        {
            if (![selector matches:element])
            {
                result = NO;
                break;
            }
        }
    }

    return result;
}

#pragma mark - Overrides

- (void)dealloc
{
    self->selectors = nil;
}

- (NSString *)description
{
    PXSourceWriter *writer = [[PXSourceWriter alloc] init];

    if (selectors)
    {
        for (id selector in selectors)
        {
            [writer print:[NSString stringWithFormat:@"%@ ", selector]];
        }
    }

    [writer printWithNewLine:@"{"];
    [writer increaseIndent];

    [writer printIndent];
    [writer print:@"// specificity = "];
    [writer printWithNewLine:_specificity.description];

    for (PXDeclaration *declaration in self.declarations)
    {
        [writer printIndent];
        [writer printWithNewLine:declaration.description];
    }

    [writer decreaseIndent];
    [writer print:@"}"];

    return writer.description;
}

@end
