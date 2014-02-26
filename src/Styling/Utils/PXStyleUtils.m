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
//  PXStyleUtils.m
//  Pixate
//
//  Created by Kevin Lindsey on 11/27/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXStyleUtils.h"
#import "NSMutableArray+QueueAdditions.h"
#import "PXStylesheetParser.h"
#import "PXCacheManager.h"
#import "PixateFreestyle.h"
#import "objc.h"
#import "PXStylesheet-Private.h"
#import "NSDictionary+PXObject.h"
#import "NSMutableDictionary+PXObject.h"
#import "PXStyleTreeInfo.h"
#import "PXStyleInfo.h"
#import "NSObject+PXStyling.h"
#import "PXStyler.h"
#import "PXVirtualStyleableControl.h"

#import <QuartzCore/QuartzCore.h>

#import "PXUITableViewCell.h"

static const char hash;
static const char itemIndex;
static const char viewDelegate;

@implementation PXStyleUtils

+ (NSArray *)elementChildrenOfStyleable:(id<PXStyleable>)styleable
{
    NSMutableArray *children = [[NSMutableArray alloc] init];

    [styleable.pxStyleChildren enumerateObjectsUsingBlock:^(id<PXStyleable> obj, NSUInteger idx, BOOL *stop) {
        if (![obj.pxStyleElementName hasPrefix:@"#"])
        {
            [children addObject:obj];
        }
    }];

    return children;
}

+ (NSArray *)elementChildrenOfStyleable:(id<PXStyleable>)styleable ofType:(NSString *)type
{
    NSMutableArray *childrenOfType = [[NSMutableArray alloc] init];

    [styleable.pxStyleChildren enumerateObjectsUsingBlock:^(id<PXStyleable> obj, NSUInteger idx, BOOL *stop) {
        if (![obj.pxStyleElementName hasPrefix:@"#"])
        {
            if ([obj.pxStyleElementName isEqualToString:type])
            {
                [childrenOfType addObject:obj];
            }
        }
    }];

    return childrenOfType;
}

+ (NSInteger)childCountForStyleable:(id<PXStyleable>)styleable
{
    NSInteger result = 0;

    if ([styleable respondsToSelector:@selector(indexPathForCell:)])
    {
        // TODO: This won't work, need a child as last parameter
        NSIndexPath *path = [styleable performSelector:@selector(indexPathForCell:) withObject:styleable];

        if ([styleable respondsToSelector:@selector(numberOfItemsInSection:)])
        {
            NSUInteger sectionIndex = [path indexAtPosition:path.length - 2];

            result = [self getCountFromSelector:@selector(numberOfItemsInSection:) withParent:styleable index:sectionIndex];
        }
        else if ([styleable respondsToSelector:@selector(numberOfRowsInSection:)])
        {
            NSUInteger sectionIndex = [path indexAtPosition:path.length - 2];

            result = [self getCountFromSelector:@selector(numberOfRowsInSection:) withParent:styleable index:sectionIndex];
        }
    }
    else
    {
        result = styleable.pxStyleChildren.count;
    }

    return result;
}

+ (PXStyleableChildrenInfo *)childrenInfoForStyleable:(id<PXStyleable>)styleable
{
    PXStyleableChildrenInfo *result = malloc(sizeof(PXStyleableChildrenInfo));

    // init
    result->childrenCount = 0;
    result->childrenOfTypeCount = 0;
    result->childrenIndex = NSNotFound;
    result->childrenOfTypeIndex = NSNotFound;

    id<PXStyleable> parent = styleable.pxStyleParent;

    NSIndexPath *path = nil;
    
    // First check to see if we've set the index property
    if(path == nil)
    {
        path = [PXStyleUtils itemIndexForObject:styleable];
    }

    if (path || ([parent respondsToSelector:@selector(indexPathForCell:)] &&
                 ([styleable isKindOfClass:[UITableViewCell class]] ||
                  [styleable isKindOfClass:[UICollectionViewCell class]]))
                 )
    {
        // If we didn't find it, now check to see if the parent can figure it out
        if(path == nil)
        {
            path = [parent performSelector:@selector(indexPathForCell:) withObject:styleable];
        }
        
        if (path.length >= 2)
        {
            result->childrenIndex = result->childrenOfTypeIndex = [path indexAtPosition:path.length - 1] + 1;

            if ([parent respondsToSelector:@selector(numberOfItemsInSection:)])
            {
                NSUInteger sectionIndex = [path indexAtPosition:path.length - 2];
                NSInteger count = [self getCountFromSelector:@selector(numberOfItemsInSection:) withParent:parent index:sectionIndex];

                result->childrenCount = result->childrenOfTypeCount = count;
            }
            else if ([parent respondsToSelector:@selector(numberOfRowsInSection:)])
            {
                NSUInteger sectionIndex = [path indexAtPosition:path.length - 2];
                NSInteger count = [self getCountFromSelector:@selector(numberOfRowsInSection:) withParent:parent index:sectionIndex];

                result->childrenCount = result->childrenOfTypeCount = count;
            }
        }
        // else what?
    }
    else
    {
        [parent.pxStyleChildren enumerateObjectsUsingBlock:^(id<PXStyleable> obj, NSUInteger idx, BOOL *stop) {
            if (![obj.pxStyleElementName hasPrefix:@"#"])
            {
                result->childrenCount++;

                // test for element existance after adding to make index 1-based
                if (obj == styleable)
                {
                    result->childrenIndex = result->childrenCount;
                }

                if ([obj.pxStyleElementName isEqualToString:styleable.pxStyleElementName])
                {
                    result->childrenOfTypeCount++;

                    // test for element existance after adding to make index 1-based
                    if (obj == styleable)
                    {
                        result->childrenOfTypeIndex = result->childrenOfTypeCount;
                    }
                }
            }
        }];
    }

    return result;
}

+ (NSInteger)getCountFromSelector:(SEL)selector withParent:(NSObject *)parent index:(NSInteger)index
{
    //return [[parent performSelector:selector withObject:@(index)] intValue];
    //id count = objc_msgSend(parent, selector, index);

    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[(NSObject *)parent methodSignatureForSelector:selector]];
    NSInteger result;

    [inv setSelector:selector];
    [inv setTarget:parent];
    [inv setArgument:&index atIndex:2];
    [inv invoke];
    [inv getReturnValue:&result];

    return result;
}

+ (NSString *)descriptionForStyleable:(id<PXStyleable>)styleable
{
    NSMutableArray *parts = [[NSMutableArray alloc] init];

    // open text
    [parts addObject:@"{ "];

    // add class name and pointer address
    [parts addObject:@"Class="];
    [parts addObject:[[styleable class] description]];
    [parts addObject:@", Addr="];
    [parts addObject:[NSString stringWithFormat:@"0x%lx", (unsigned long) styleable]];

    // add selector
    [parts addObject:@", Selector="];
    [parts addObject:[self selectorFromStyleable:styleable]];

    // close text
    [parts addObject:@" }"];

    return [parts componentsJoinedByString:@""];
}

+ (NSString *)selectorFromStyleable:(id<PXStyleable>)styleable
{
    NSMutableArray *parts = [[NSMutableArray alloc] init];

    // add element name
    [parts addObject:styleable.pxStyleElementName];

    // add id
    if (styleable.styleId) [parts addObject:[NSString stringWithFormat:@"#%@", styleable.styleId]];

    // add classes
    NSArray *classes = [styleable.styleClass componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    classes = [classes sortedArrayUsingComparator:^NSComparisonResult(NSString *class1, NSString *class2) {
        return [class1 compare:class2];
    }];

    for (NSString *className in classes)
    {
        [parts addObject:[NSString stringWithFormat:@".%@", className]];
    }

    return [parts componentsJoinedByString:@""];
}

+ (void)enumerateStyleableAndDescendants:(id<PXStyleable>)styleable usingBlock:(void (^)(id obj, BOOL *stop, BOOL *stopDescending))block
{
    if (styleable && block)
    {
        // create queue
        NSMutableArray *queue = [NSMutableArray array];

        // initialize queue with the specified styleable
        [queue enqueue:styleable];

        // enumerate
        [self enumerateStyleableQueue:queue withBlock:block];
    }
}

+ (void)enumerateStyleableDescendants:(id<PXStyleable>)styleable usingBlock:(void (^)(id obj, BOOL *stop, BOOL *stopDescending))block
{
    if (styleable && block)
    {
        // create queue
        NSMutableArray *queue = [NSMutableArray array];

        // initialize queue with styleable's childen
        for (id child in [styleable pxStyleChildren])
        {
            [queue enqueue:child];
        }

        // enumerate
        [self enumerateStyleableQueue:queue withBlock:block];
    }
}

+ (void)enumerateStyleableQueue:(NSMutableArray *)queue withBlock:(void (^)(id obj, BOOL *stop, BOOL *stopDescending))block
{
    // initialize stop flag
    BOOL stop = NO;
    BOOL stopDescending = NO;

    // loop until the queue is empty or we're told to stop
    while (queue.count > 0 && !stop)
    {
        id<PXStyleable> current = [queue dequeue];

        // process styleable
        block(current, &stop, &stopDescending);

        // enqueue children, but only if we're going to continue
        if (stop == NO && stopDescending == NO)
        {
            for (id child in [current pxStyleChildren])
            {
                [queue enqueue:child];
            }
        }
    }
}

+ (NSDictionary *)viewStylerPropertyMapForStyleable:(id<PXStyleable>)styleable
{
    NSArray *viewStylers = ([styleable respondsToSelector:@selector(viewStylers)])
        ? ((NSObject *)styleable).viewStylers
        : nil;

    // build a dictionary of property names to stylers
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];

    for (id<PXStyler> styler in viewStylers)
    {
        for (NSString *property in styler.supportedProperties)
        {
            [properties setObject:styler forKey:property];
        }
    }

    return properties;
}

+ (NSMutableArray *)matchingRuleSetsForStyleable:(id<PXStyleable>)styleable
{
    // find matching rule sets, regardless of any supported or specified pseudo-classes
    NSMutableArray *ruleSets = [NSMutableArray arrayWithArray:[[PXStylesheet currentApplicationStylesheet] ruleSetsMatchingStyleable:styleable]];
    [ruleSets addObjectsFromArray:[[PXStylesheet currentUserStylesheet] ruleSetsMatchingStyleable:styleable]];
    [ruleSets addObjectsFromArray:[[PXStylesheet currentViewStylesheet] ruleSetsMatchingStyleable:styleable]];

    // include any inline styling
    if ([styleable respondsToSelector:@selector(styleCSS)])
    {
        // TODO: store and use cached values
        NSString *source = styleable.styleCSS;

        if (source.length > 0)
        {
            PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
            PXStylesheet *inlineStylesheet = [parser parseInlineCSS:source];

            [ruleSets addObjectsFromArray:inlineStylesheet.ruleSets];
        }
    }

    return ruleSets;
}

+ (NSArray *)filterRuleSets:(NSArray *)ruleSets forStyleable:(id<PXStyleable>)styleable byState:(NSString *)stateName
{
    NSMutableArray *ruleSetsForState = [[NSMutableArray alloc] init];

    // process each rule set
    for (PXRuleSet *ruleSet in ruleSets)
    {
        // grab the target type selector (the selector itself or a combinator's RHS)
        PXTypeSelector *selector = ruleSet.targetTypeSelector;

        // assume we will not be adding this rule set into our results
        BOOL add = NO;

        if (!selector.hasPseudoClasses)
        {
            // the selector didn't specify a pseudo-class so assume the default psuedo-class was specified

            if ([styleable respondsToSelector:@selector(defaultPseudoClass)])
            {
                // add rule set if default pseudo-class matches stateName
                add = [styleable.defaultPseudoClass isEqualToString:stateName];
            }
            else
            {
                // add rule set if the styleable doesn't have a default pseudo-class and the specified state name
                // was nil
                add = !stateName;
            }
        }
        else
        {
            // add if the styleable has the state name in its lists of supported pseudo-classes
            add = [selector hasPseudoClass:stateName];
        }

        if (add)
        {
            [ruleSetsForState addObject:ruleSet];
        }
    }

    return ruleSetsForState;
}

+ (NSArray *)filterRuleSets:(NSArray *)ruleSets byPseudoElement:(NSString *)pseudoElement
{
    NSMutableArray *ruleSetsForPseudoElement = nil;

    // if we have a pseudo-element name, then filter the specified rulesets to those only referencing this pseudo-element
    if (pseudoElement.length > 0)
    {
        // process each rule set
        for (PXRuleSet *ruleSet in ruleSets)
        {
            // grab the target type selector (the selector itself or a combinator's RHS)
            PXTypeSelector *selector = ruleSet.targetTypeSelector;

            if ([pseudoElement isEqualToString:selector.pseudoElement])
            {
                if (ruleSetsForPseudoElement == nil)
                {
                    ruleSetsForPseudoElement = [[NSMutableArray alloc] init];
                }

                [ruleSetsForPseudoElement addObject:ruleSet];
            }
        }
    }

    return ruleSetsForPseudoElement;
}

+ (BOOL)stylesOfStyleable:(id<PXStyleable>)styleable matchDeclarations:(NSArray *)declarations state:(NSString *)state
{
    BOOL result = NO;

    // grab hash for active state
    if (PixateFreestyle.configuration.preventRedundantStyling)
    {
        // grab associated hash dictionary on styleable, or create one (and store) if it doesn't have one already
        NSMutableDictionary *cachedHashValues = objc_getAssociatedObject(styleable, &hash);

        if (!cachedHashValues)
        {
            cachedHashValues = [[NSMutableDictionary alloc] init];
            objc_setAssociatedObject(styleable, &hash, cachedHashValues, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }

        // grab last saved hash, may be nil
        NSString *stateNameKey = (state) ? state : @"";
        NSValue *cachedHashValue = [cachedHashValues objectForKey:stateNameKey];

        // calculate active declarations hash
        CGRect bounds = styleable.bounds;
        NSString *boundsString = [NSString stringWithFormat:@"%f,%f,%f,%f", bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height];
        __block NSUInteger activeDeclarationsHash = boundsString.hash;

        [declarations enumerateObjectsUsingBlock:^(PXDeclaration *declaration, NSUInteger idx, BOOL *stop) {
            activeDeclarationsHash = activeDeclarationsHash * 31 + declaration.hash;
        }];

        // if we had a previous hash, then see if it matches our new hash
        if (cachedHashValue)
        {
            NSUInteger cachedHash;

            [cachedHashValue getValue:&cachedHash];

            result = (activeDeclarationsHash == cachedHash);
        }

        // show hashes match or save new (different) hash for next time
        if (result)
        {
            DDLogInfo(@"Styleable's style does not need updating: %@", [PXStyleUtils descriptionForStyleable:styleable]);
        }
        else
        {
            [cachedHashValues setObject:[[NSValue alloc] initWithBytes:&activeDeclarationsHash objCType:@encode(NSUInteger)] forKey:stateNameKey];
        }
    }
    
    return result;
}

+ (void)invalidateStyleable:(id<PXStyleable>)styleable
{
    objc_setAssociatedObject(styleable, &hash, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)invalidateStyleableAndDescendants:(id<PXStyleable>)styleable
{
    [PXStyleUtils enumerateStyleableAndDescendants:styleable usingBlock:^(id<PXStyleable> s, BOOL *stop, BOOL *stopDescending) {
        objc_setAssociatedObject(s, &hash, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }];
}

+ (NSUInteger)hashValueForStyleable:(id<PXStyleable>)styleable state:(NSString *)state
{
    NSMutableDictionary *cachedHashValues = objc_getAssociatedObject(styleable, &hash);
    NSString *stateNameKey = (state) ? state : @"";
    NSValue *cachedHashValue = [cachedHashValues objectForKey:stateNameKey];
    NSUInteger cachedHash;

    [cachedHashValue getValue:&cachedHash];

    return cachedHash;
}

+ (void)updateStyleForStyleable:(id<PXStyleable>)styleable
{
    static NSMutableSet *viewsBeingStyled;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        viewsBeingStyled = [NSMutableSet set];
    });

    BOOL preventStyling = [styleable respondsToSelector:@selector(preventStyling)] && [styleable preventStyling];
    
    // We prevent nested styling of a styleable by checking to see if it is currently being styled
    if (![viewsBeingStyled containsObject:styleable] && !preventStyling && styleable.styleMode != PXStylingNone)
    {
        // catch all exceptions to make sure we remove the current styleable from viewsBeingStyled
        @try
        {
            [viewsBeingStyled addObject:styleable];

            if (PixateFreestyle.configuration.cacheStyles &&
                ([styleable isKindOfClass:[UITableViewCell class]] || [styleable isKindOfClass:[UICollectionViewCell class]]))
            {
                // grab styleable's style hash
                NSString *styleKey = styleable.styleKey;
                PXStyleTreeInfo *cache = [PXCacheManager styleTreeInfoForKey:styleKey];

                // cache this items style info if we haven't seen it before
                if (cache == nil)
                {
                    // collect style info
                    cache = [[PXStyleTreeInfo alloc] initWithStyleable:styleable];

                    // save for later
                    [PXCacheManager setStyleTreeInfo:cache forKey:styleKey];
                }

                // apply style info to the styleable and its descendants
                [cache applyStylesToStyleable:styleable];
            }
            else
            {
                PXStyleInfo *styleInfo = [PXStyleInfo styleInfoForStyleable:styleable];

                if (styleInfo != nil)
                {
                    [styleInfo applyToStyleable:styleable];
                }
            }
        }
        @finally
        {
            [viewsBeingStyled removeObject:styleable];
        }
    }
}

+ (void)updateStylesForStyleable:(id<PXStyleable>)styleable andDescendants:(BOOL)recurse
{
    if (styleable)
    {
        if (recurse)
        {
            [PXStyleUtils enumerateStyleableAndDescendants:styleable usingBlock:^(id<PXStyleable> obj, BOOL *stop, BOOL *stopDescending) {
                [PXStyleUtils updateStyleForStyleable:obj];

                if (PixateFreestyle.configuration.cacheStyles)
                {
                    *stopDescending = [obj isKindOfClass:[UITableViewCell class]];
                }
            }];
        }
        else
        {
            [PXStyleUtils updateStyleForStyleable:styleable];
        }
    }
}

+ (void)setViewDelegate:(id)delegate forObject:(id)object
{
    objc_setAssociatedObject(object, &viewDelegate, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (id)viewDelegateForObject:(id)object
{
    return objc_getAssociatedObject(object, &viewDelegate);
}

+ (void)setItemIndex:(NSIndexPath *)index forObject:(NSObject *)object
{
    objc_setAssociatedObject(object, &itemIndex, index, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSIndexPath *)itemIndexForObject:(NSObject *)object
{
    return objc_getAssociatedObject(object, &itemIndex);
}

+ (void)updateCellStyleWhenReady:(UIView *)view
{
    [self updateCellStyleWhenReady:view startTime:[[NSDate date] timeIntervalSince1970] recursive:YES];
}

+ (void)updateCellStyleNonRecursiveWhenReady:(UIView *)view
{
    [self updateCellStyleWhenReady:view startTime:[[NSDate date] timeIntervalSince1970] recursive:NO];
}

+ (void)updateCellStyleWhenReady:(UIView *)view startTime:(double)time recursive:(BOOL)recursive
{
    // If this takes more than 1 second, abort
    if(([[NSDate date] timeIntervalSince1970] - time) > 1)
    {
        return;
    }

    id parent = view.superview;

    if ([parent respondsToSelector:@selector(indexPathForCell:)])
    {
        NSIndexPath *path = [parent performSelector:@selector(indexPathForCell:) withObject:view];

        if(path == nil)
        {
            // We'll try again...
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateCellStyleWhenReady:view startTime:time recursive:recursive];
            });
        }
        else
        {
            if(recursive)
            {
                [view updateStyles];
            }
            else
            {
                [view updateStylesNonRecursively];
            }
        }
    }
}

@end
