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
//  PXStylesheet.m
//  Pixate
//
//  Created by Kevin Lindsey on 7/10/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXStylesheet.h"
#import "PXStylesheet-Private.h"
#import "PXSpecificity.h"
#import "PXStylesheetParser.h"
#import "PXFileWatcher.h"
#import "PXStyleUtils.h"
#import "PXMediaExpression.h"
#import "PXMediaGroup.h"
#import "PixateFreestyle.h"

//NSString *const PXStylesheetDidChangeNotification = @"kPXStylesheetDidChangeNotification";

static PXStylesheetParser *PARSER;

static PXStylesheet *currentApplicationStylesheet = nil;
static PXStylesheet *currentUserStylesheet = nil;
static PXStylesheet *currentViewStylesheet = nil;

@implementation PXStylesheet
{
    NSMutableArray *mediaGroups_;
    id<PXMediaExpression> activeMediaQuery_;
    PXMediaGroup *activeMediaGroup_;
    NSMutableDictionary *namespacePrefixMap_;
    NSMutableDictionary *keyframesByName_;
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

#pragma mark - Static initializers

+ (void)initialize
{
    // TODO: Use a parser pool since the parser is not thread safe
    if (PARSER == nil)
    {
        PARSER = [[PXStylesheetParser alloc] init];
    }
}

+ (id)styleSheetFromSource:(NSString *)source withOrigin:(PXStylesheetOrigin)origin
{
    return [self styleSheetFromSource:source withOrigin:origin filename:nil];
}

+ (id)styleSheetFromSource:(NSString *)source withOrigin:(PXStylesheetOrigin)origin filename:(NSString *)name
{
    PXStylesheet *result = nil;

    // TODO: maybe the following can be more intelligent and only remove cache entries that reference the stylesheet
    // being replaced

    // clear style cache
    [PixateFreestyle clearStyleCache];

    if (source.length > 0)
    {
        result = [PARSER parse:source withOrigin:origin filename:name];
        result->_errors = PARSER.errors;
    }
    else
    {
        result = [[PXStylesheet alloc] initWithOrigin:origin];
    }

    // update configuration - !!! This needs to be done some other way, just don't know how yet
    [PXStyleUtils updateStyleForStyleable:PixateFreestyle.configuration];

    return result;
}

+ (id)styleSheetFromFilePath:(NSString *)aFilePath withOrigin:(PXStylesheetOrigin)origin
{
    NSString* source = [NSString stringWithContentsOfFile:aFilePath encoding:NSUTF8StringEncoding error:NULL];

    return [self styleSheetFromSource:source withOrigin:origin filename:aFilePath];
}

+ (void)clearCache
{
    [[self currentApplicationStylesheet] clearCache];
    [[self currentUserStylesheet] clearCache];
    [[self currentViewStylesheet] clearCache];
}

#pragma mark - Initializers

- (id)init
{
    return [self initWithOrigin:PXStylesheetOriginApplication];
}

- (id)initWithOrigin:(PXStylesheetOrigin)anOrigin
{
    if (self = [super init])
    {
        self->_origin = anOrigin;
        // Set this new stylesheet as one of the three current sheets (i.e. App, User, View)
        [PXStylesheet assignCurrentStylesheet:self withOrigin:anOrigin];
    }

    return self;
}

- (void)clearCache
{
    for (PXMediaGroup *group in mediaGroups_)
        [group clearCache];
}

#pragma mark - Getters

- (NSArray *)ruleSets
{
    NSMutableArray *combined;

    for (PXMediaGroup *group in mediaGroups_)
    {
        if ([group matches])
        {
            if (!combined)
            {
                combined = [NSMutableArray array];
            }

            [combined addObjectsFromArray:group.ruleSets];
        }
    }

    return combined;
}

- (NSArray *)ruleSetsForStyleable:(id<PXStyleable>)styleable
{
    NSMutableArray *combined;

    for (PXMediaGroup *group in mediaGroups_)
    {
        if ([group matches])
        {
            if (!combined)
            {
                combined = [NSMutableArray array];
            }

            [combined addObjectsFromArray:[group ruleSetsForStyleable:styleable]];
        }
    }

    return combined;
}

- (NSArray *)mediaGroups
{
    return (mediaGroups_) ? [NSArray arrayWithArray:mediaGroups_] : nil;
}

+ (PXStylesheet *)currentApplicationStylesheet
{
	return currentApplicationStylesheet;
}

+ (PXStylesheet *)currentUserStylesheet
{
	return currentUserStylesheet;
}

+ (PXStylesheet *)currentViewStylesheet
{
	return currentViewStylesheet;
}

#pragma mark - Setters

- (void)setActiveMediaQuery:(id<PXMediaExpression>)activeMediaQuery
{
    // TODO: test for equivalence of active query? If they match, then do nothing
    activeMediaQuery_ = activeMediaQuery;
    activeMediaGroup_ = nil;
}

- (void)setMonitorChanges:(BOOL)state
{
    if(self.filePath)
    {
        if(state)
        {
            [[PXFileWatcher sharedInstance] watchFile:self.filePath handler:^{
                // reload file
                [PXStylesheet styleSheetFromFilePath:self.filePath withOrigin:self.origin];

                // update all views
                [PixateFreestyle updateStylesForAllViews];
                
            }];
        }
        else
        {
            // NO OP right now
        }
    }
}

#pragma mark - Methods

- (void)addRuleSet:(PXRuleSet *)ruleSet
{
    if (ruleSet)
    {
        if (!activeMediaGroup_)
        {
            activeMediaGroup_ = [[PXMediaGroup alloc] initWithQuery:activeMediaQuery_ origin:self.origin];

            [self addMediaGroup:activeMediaGroup_];
        }

        [activeMediaGroup_ addRuleSet:ruleSet];
    }
}

- (void)addMediaGroup:(PXMediaGroup *)mediaGroup
{
    if (mediaGroup)
    {
        if (!mediaGroups_)
        {
            mediaGroups_ = [NSMutableArray array];
        }

        [mediaGroups_ addObject:mediaGroup];
    }
}

- (NSArray *)ruleSetsMatchingStyleable:(id<PXStyleable>)element
{
    NSMutableArray *result = [NSMutableArray array];

    if (element)
    {
        NSArray *candidateRuleSets = [self ruleSetsForStyleable:element];
//        NSArray *candidateRuleSets = [self ruleSets];
//        NSLog(@"%@ = %d", [PXStyleUtils descriptionForStyleable:element], candidateRuleSets.count);

        for (PXRuleSet *ruleSet in candidateRuleSets)
        {
            if ([ruleSet matches:element])
            {
                DDLogInfo(@"%@ matched\n%@", [PXStyleUtils descriptionForStyleable:element], ruleSet.description);

                [result addObject:ruleSet];
            }
        }
    }

    return [NSArray arrayWithArray:result];
}

- (void)setURI:(NSString *)uri forNamespacePrefix:(NSString *)prefix
{
    if (uri)
    {
        if (prefix == nil)
        {
            prefix = @"";
        }

        if (namespacePrefixMap_ == nil)
        {
            namespacePrefixMap_ = [[NSMutableDictionary alloc] init];
        }

        [namespacePrefixMap_ setObject:uri forKey:prefix];
    }
}

- (NSString *)namespaceForPrefix:(NSString *)prefix
{
    NSString *result = nil;

    if (namespacePrefixMap_)
    {
        if (prefix == nil)
        {
            prefix = @"";
        }

        result = [namespacePrefixMap_ objectForKey:prefix];
    }

    return result;
}

- (void)addKeyframe:(PXKeyframe *)keyframe
{
    if (keyframe != nil)
    {
        if (keyframesByName_ == nil)
        {
            keyframesByName_ = [[NSMutableDictionary alloc] init];
        }

        [keyframesByName_ setObject:keyframe forKey:keyframe.name];
    }
}

- (PXKeyframe *)keyframeForName:(NSString *)name
{
    return [keyframesByName_ objectForKey:name];
}

#pragma mark - Static public methods

// none

#pragma mark - Static private methods

+ (void)assignCurrentStylesheet:(PXStylesheet *)sheet withOrigin:(PXStylesheetOrigin)anOrigin
{
    switch (anOrigin)
    {
        case PXStylesheetOriginApplication:
            currentApplicationStylesheet = sheet;
            break;

        case PXStylesheetOriginUser:
            currentUserStylesheet = sheet;
            break;

        case PXStylesheetOriginView:
            currentViewStylesheet = sheet;
            break;

        case PXStylesheetOriginInline:
            // this origin type should never be handled here, but in PXStyleController directly
            break;
    }
}

#pragma mark - Overrides

- (void)dealloc
{
    activeMediaGroup_ = nil;
    activeMediaQuery_ = nil;
    mediaGroups_ = nil;
}

- (NSString *)description
{
    NSMutableArray *parts = [NSMutableArray array];

    for (PXMediaGroup *mediaGroup in mediaGroups_)
    {
        [parts addObject:mediaGroup.description];
    }

    return [parts componentsJoinedByString:@"\n"];
}

@end
