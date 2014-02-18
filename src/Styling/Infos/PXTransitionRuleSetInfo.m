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
//  PXTransitionRuleSetInfo.m
//  Pixate
//
//  Created by Paul Colton on 2/28/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXTransitionRuleSetInfo.h"
#import "PXStylingMacros.h"
#import "PXStyleUtils.h"
#import "PXRuleSet.h"
#import "PXTransitionStyler.h"

@implementation PXTransitionRuleSetInfo

- (id)initWithStyleable:(id<PXStyleable>)styleable withStateName:(NSString *)stateName
{
    if (self = [super init])
    {
        // find matching rule sets, regardless of any supported or specified pseudo-classes
        _allMatchingRuleSets = [PXStyleUtils matchingRuleSetsForStyleable:styleable];

        // filter the list of rule sets to only those that specify the current state
        _ruleSetsForState = [PXStyleUtils filterRuleSets:_allMatchingRuleSets
                                            forStyleable:styleable
                                                 byState:stateName];

        // merge rule sets for this state into a single rule set, taking specificity into account
        _mergedRuleSet = [PXRuleSet ruleSetWithMergedRuleSets:_ruleSetsForState];

        // extract any transition delcarations we might have
        PXTransitionStyler *styler = [[PXTransitionStyler alloc] init];
        NSSet *stylerProperties = [[NSSet alloc] initWithArray:styler.supportedProperties];
        PXStylerContext *context = [[PXStylerContext alloc] init];
        context.styleable = styleable;
        context.activeStateName = stateName;

        for (PXDeclaration *declaration in _mergedRuleSet.declarations)
        {
            if ([stylerProperties containsObject:declaration.name])
            {
                [styler processDeclaration:declaration withContext:context];
            }
        }

        _transitions = context.transitionInfos;
        NSMutableSet *animationProperties = [[NSMutableSet alloc] init];

        for (PXAnimationInfo *info in _transitions)
        {
            [animationProperties addObject:info.animationName];
        }

        NSMutableArray *nonAnimatedRuleSets = [[NSMutableArray alloc] init];
        NSMutableArray *animatedRuleSets = [[NSMutableArray alloc] init];

        [_ruleSetsForState enumerateObjectsUsingBlock:^(PXRuleSet *ruleSet, NSUInteger idx, BOOL *stop) {
            PXRuleSet *nonAnimatedRuleSet = [[PXRuleSet alloc] init];
            PXRuleSet *animatedRuleSet = [[PXRuleSet alloc] init];

            // copy selectors over, for debugging purposes only
            [ruleSet.selectors enumerateObjectsUsingBlock:^(id sel, NSUInteger idx, BOOL *stop) {
                [nonAnimatedRuleSet addSelector:sel];
                [animatedRuleSet addSelector:sel];
            }];

            // divide declarations into animated and non-animated lists
            [ruleSet.declarations enumerateObjectsUsingBlock:^(PXDeclaration *declaration, NSUInteger idx, BOOL *stop) {
                if ([animationProperties containsObject:declaration.name])
                {
                    [animatedRuleSet addDeclaration:declaration];
                }
                else if ([stylerProperties containsObject:declaration.name] == NO)
                {
                    [nonAnimatedRuleSet addDeclaration:declaration];
                }
            }];

            // add non-animated rule set, if we found any non-animated declarations
            if (nonAnimatedRuleSet.declarations.count > 0)
            {
                [nonAnimatedRuleSets addObject:nonAnimatedRuleSet];
            }

            // add animated rule set, if we found any animated declarations
            if (animatedRuleSet.declarations.count > 0)
            {
                [animatedRuleSets addObject:animatedRuleSet];
            }
        }];

        // save reference to non-animated rule sets, if we found any
        if (nonAnimatedRuleSets.count > 0)
        {
            _nonAnimatingRuleSets = nonAnimatedRuleSets;
        }

        // save reference to animated rule sets, if we found any
        if (animatedRuleSets.count > 0)
        {
            _animatingRuleSets = animatedRuleSets;
        }
    }

    return self;
}

@end
