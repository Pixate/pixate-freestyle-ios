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
//  PXMediaGroup.m
//  Pixate
//
//  Created by Kevin Lindsey on 1/9/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXMediaGroup.h"

@implementation PXMediaGroup
{
    NSMutableArray *ruleSets_;
    NSMutableDictionary *ruleSetsByElementName_;
    NSMutableDictionary *ruleSetsById_;
    NSMutableDictionary *ruleSetsByClass_;
    NSMutableArray *uncategorizedRuleSets_;
}

#pragma mark - Initializers

- (id)initWithQuery:(id<PXMediaExpression>)query origin:(PXStylesheetOrigin)origin
{
    if (self = [super init])
    {
        _query = query;
        _origin = origin;
    }

    return self;
}

#pragma mark - Getters

- (NSArray *)ruleSets
{
    return (ruleSets_) ? [NSArray arrayWithArray:ruleSets_] : nil;
}

- (NSArray *)ruleSetsForStyleable:(id<PXStyleable>)styleable
{
    NSMutableArray *result = [NSMutableArray array];
    NSMutableSet *items = [NSMutableSet set];

    // gather keys
    NSString *elementName = styleable.pxStyleElementName;
    NSString *styleId = styleable.styleId;
    NSString *styleClass = styleable.styleClass;

    // find relevant ruleSets by element name
    if (elementName.length > 0)
    {
        for (PXRuleSet *ruleSet in [ruleSetsByElementName_ objectForKey:elementName])
        {
            if ([items containsObject:ruleSet] == NO)
            {
                [result addObject:ruleSet];
                [items addObject:ruleSet];
            }
        }
    }

    // find relevant ruleSets by id
    if (styleId.length > 0)
    {
        for (PXRuleSet *ruleSet in [ruleSetsById_ objectForKey:styleId])
        {
            if ([items containsObject:ruleSet] == NO)
            {
                [result addObject:ruleSet];
                [items addObject:ruleSet];
            }
        }
    }

    // find relevant ruleSets by class
    if (styleClass.length > 0)
    {
        NSArray *styleClasses = [styleClass componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        for (NSString *aClass in styleClasses)
        {
            for (PXRuleSet *ruleSet in [ruleSetsByClass_ objectForKey:aClass])
            {
                if ([items containsObject:ruleSet] == NO)
                {
                    [result addObject:ruleSet];
                    [items addObject:ruleSet];
                }
            }
        }
    }

    // fallback to all uncategorized ruleSets. Note that these are already included in the element name, id, and class
    // lists above, so we only need to add these if we didn't find any of those
    if (result.count == 0)
    {
        result = uncategorizedRuleSets_;
    }

    return (result != nil) ? [NSArray arrayWithArray:result] : nil;
}

#pragma mark - Methods

- (void)addRuleSet:(PXRuleSet *)ruleSet toPartition:(NSMutableDictionary *)partition withKey:(NSString *)key
{
    NSMutableArray *ruleSets = [partition objectForKey:key];

    // create ruleset array if we don't have one already
    if (ruleSets == nil)
    {
        ruleSets = [NSMutableArray array];

        // be sure to include in this array all uncategorized ruleSets that came before this one
        [ruleSets addObjectsFromArray:uncategorizedRuleSets_];

        // save the ruleSet array back to the partition dictionary
        [partition setObject:ruleSets forKey:key];
    }

    // add this ruleSet to the ruleSet array associated with the given key
    [ruleSets addObject:ruleSet];
}

- (void)addRuleSet:(PXRuleSet *)ruleSet
{
    if (ruleSet)
    {
        if (!ruleSets_)
        {
            ruleSets_ = [NSMutableArray array];
        }

        [ruleSets_ addObject:ruleSet];

        // set origin specificity
        [ruleSet.specificity setSpecificity:kSpecificityTypeOrigin toValue:_origin];

        // setup lookup by element type
        PXTypeSelector *typeSelector = ruleSet.targetTypeSelector;
        // NOTE: we have to check for nil since hasUniversalType returns false with a nil typeSelector, but we need
        // the default to be true when typeSelector is nil
        NSString *elementName = (typeSelector == nil || typeSelector.hasUniversalType) ? nil : typeSelector.typeName;
        NSString *styleId = (typeSelector == nil) ? nil : typeSelector.styleId;
        NSArray *styleClasses = (typeSelector == nil) ? nil : typeSelector.styleClasses;
        BOOL added = NO;

        // NOTE: nesting if-statements to avoid walking type selector expressions for id and classes when not needed
        if (elementName != nil && [@"*" isEqualToString:elementName] == NO)
        {
            if (ruleSetsByElementName_ == nil) ruleSetsByElementName_ = [NSMutableDictionary dictionary];
            [self addRuleSet:ruleSet toPartition:ruleSetsByElementName_ withKey:elementName];
            added = YES;
        }

        if (styleId.length > 0)
        {
            if (ruleSetsById_ == nil) ruleSetsById_ = [NSMutableDictionary dictionary];
            [self addRuleSet:ruleSet toPartition:ruleSetsById_ withKey:styleId];
            added = YES;
        }

        if (styleClasses.count > 0)
        {
            if (ruleSetsByClass_ == nil) ruleSetsByClass_ = [NSMutableDictionary dictionary];

            for (NSString *styleClass in styleClasses)
            {
                [self addRuleSet:ruleSet toPartition:ruleSetsByClass_ withKey:styleClass];
            }

            added = YES;
        }

        // if this wasn't added to any of our partitions, then we need to collect it into the uncategorized partition
        // and add it to all other partitions to preserve rule set order in those sets as well
        if (added == NO)
        {
            if (uncategorizedRuleSets_ == nil) uncategorizedRuleSets_ = [NSMutableArray array];
            [uncategorizedRuleSets_ addObject:ruleSet];

            // add uncategorized ruleSets to all partitions
            for (NSString *key in ruleSetsByElementName_.allKeys)
            {
                NSMutableArray *items = [ruleSetsByElementName_ objectForKey:key];

                [items addObject:ruleSet];
            }

            for (NSString *key in ruleSetsById_.allKeys)
            {
                NSMutableArray *items = [ruleSetsById_ objectForKey:key];

                [items addObject:ruleSet];
            }

            for (NSString *key in ruleSetsByClass_.allKeys)
            {
                NSMutableArray *items = [ruleSetsByClass_ objectForKey:key];

                [items addObject:ruleSet];
            }
        }
    }
}

- (BOOL)matches
{
    // assume nil means "true" to cover non-media-query groups
    return (_query) ? [_query matches] : YES;
}

#pragma mark - Overrides

- (void)dealloc
{
    ruleSets_ = nil;
    ruleSetsByElementName_ = nil;
    ruleSetsById_ = nil;
    ruleSetsByClass_ = nil;
    uncategorizedRuleSets_ = nil;
    _query = nil;
}

- (NSString *)description
{
    NSMutableArray *parts = [NSMutableArray array];

    if (_query)
    {
        [parts addObject:[NSString stringWithFormat:@"@media %@ {", _query.description]];

        for (PXRuleSet *ruleSet in ruleSets_)
        {
            [parts addObject:[NSString stringWithFormat:@"  %@", ruleSet.description]];
        }

        [parts addObject:@"}"];
    }
    else
    {
        for (PXRuleSet *ruleSet in ruleSets_)
        {
            [parts addObject:ruleSet.description];
        }
    }

    return [parts componentsJoinedByString:@"\n"];
}

@end
