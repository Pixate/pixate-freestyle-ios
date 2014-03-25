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
//  PixateFreestyle.m
//
//  Created by Paul Colton on 12/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PixateFreestyle.h"
#import "PixateFreestyle-Private.h"
#import "Version.h"

#import "PXStylesheet.h"
#import "PXStylesheet-Private.h"
#import "UIView+PXStyling.h"
#import "PXStylesheetParser.h"
#import "PXStyleUtils.h"
#import "PixateFreestyleConfiguration.h"
#import "PXStylerContext.h"
#import "PXCacheManager.h"

#import "PXForceLoadPixateCategories.h"
#import "PXForceLoadStylingCategories.h"
#import "PXForceLoadVirtualCategories.h"
#import "PXForceLoadControls.h"
#import "PXForceLoadCGCategories.h"

@implementation PixateFreestyle
{
    BOOL _refreshStylesWithOrientationChange;
}

+ (void) initializePixateFreestyle
{
    //
    // These are required so we don't have to require a -ObjC flag on the project
    //
    
    // Trigger categories to all load
    [PXForceLoadPixateCategories forceLoad];
    [PXForceLoadStylingCategories forceLoad];
    [PXForceLoadVirtualCategories forceLoad];
    [PXForceLoadCGCategories forceLoad];
    
    // Trigger our UI subclasses to load
    [PXForceLoadControls forceLoad];
}

+ (PixateFreestyle *)sharedInstance
{
	static __strong PixateFreestyle *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[PixateFreestyle alloc] init];

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM d yyyy"];
        NSLocale *localeUS = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateFormatter setLocale:localeUS];
        NSDate *date = [dateFormatter dateFromString:[NSString stringWithUTF8String:__DATE__]];
        sharedInstance->_buildDate = date;
        sharedInstance->_version = @PIXATE_FREESTYLE_VERSION;
        sharedInstance->_apiVersion = PIXATE_FREESTYLE_API_VERSION;
	});

	return sharedInstance;
}

+(NSString *)version
{
    return [PixateFreestyle sharedInstance].version;
}

+(NSDate *)buildDate
{
    return [PixateFreestyle sharedInstance].buildDate;
}

+ (int)apiVersion
{
    return [PixateFreestyle sharedInstance].apiVersion;
}

+(BOOL)titaniumMode
{
    return [PixateFreestyle sharedInstance].titaniumMode;
}

+(PixateFreestyleConfiguration *)configuration
{
    return [PixateFreestyle sharedInstance].configuration;
}

+(BOOL)refreshStylesWithOrientationChange
{
    return [PixateFreestyle sharedInstance]->_refreshStylesWithOrientationChange;
}

+(void)setRefreshStylesWithOrientationChange:(BOOL)value
{
    [[PixateFreestyle sharedInstance] internalSetRefreshStylesWithOrientationChange:value];
}

+ (NSArray *)selectFromStyleable:(id<PXStyleable>)styleable usingSelector:(NSString *)source
{
    PXStylesheetParser *parser = [[PXStylesheetParser alloc] init];
    id<PXSelector> selector = [parser parseSelectorString:source];
    NSMutableArray *result = nil;

    if (selector && parser.errors.count == 0)
    {
        result = [NSMutableArray array];

        [PXStyleUtils enumerateStyleableAndDescendants:styleable usingBlock:^(id<PXStyleable> obj, BOOL *stop, BOOL *stopDescending) {
            if ([selector matches:obj])
            {
                [result addObject:obj];
            }
        }];
    }

    return result;
}

+ (NSString *)matchingRuleSetsForStyleable:(id<PXStyleable>)styleable
{
    NSArray *ruleSets = [PXStyleUtils matchingRuleSetsForStyleable:styleable];
    NSMutableArray *stringValues = [NSMutableArray arrayWithCapacity:ruleSets.count];

    for (id<NSObject> ruleSet in ruleSets)
    {
        [stringValues addObject:ruleSet.description];
    }

    return [stringValues componentsJoinedByString:@"\n"];
}

+ (NSString *)matchingDeclarationsForStyleable:(id<PXStyleable>)styleable
{
    NSArray *ruleSets = [PXStyleUtils matchingRuleSetsForStyleable:styleable];
    PXRuleSet *mergedRuleSet = [PXRuleSet ruleSetWithMergedRuleSets:ruleSets];
    NSMutableArray *declarationStrings = [NSMutableArray arrayWithCapacity:mergedRuleSet.declarations.count];

    for (id<NSObject> declaration in mergedRuleSet.declarations)
    {
        [declarationStrings addObject:declaration.description];
    }

    return [declarationStrings componentsJoinedByString:@"\n"];
}

+ (id)styleSheetFromFilePath:(NSString *)filePath withOrigin:(PXStylesheetOrigin)origin
{
    return [PXStylesheet styleSheetFromFilePath:filePath withOrigin:origin];
}

+ (id)styleSheetFromSource:(NSString *)source withOrigin:(PXStylesheetOrigin)origin
{
    return [PXStylesheet styleSheetFromSource:source withOrigin:origin];
}

+ (PXStylesheet *)currentApplicationStylesheet
{
    return [PXStylesheet currentApplicationStylesheet];
}

+ (PXStylesheet *)currentUserStylesheet
{
    return [PXStylesheet currentUserStylesheet];
}

+ (PXStylesheet *)currentViewStylesheet
{
    return [PXStylesheet currentViewStylesheet];
}

+ (void)applyStylesheets
{
    [self updateStylesForAllViews];
}

+ (void)updateStylesForAllViews
{
    [[UIApplication sharedApplication].windows enumerateObjectsUsingBlock:^(UIWindow *window, NSUInteger index, BOOL *stop)
    {
        if([self titaniumMode])
        {
            [[window subviews] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
                // Style the first Ti* named view we find, the rest should be recursive from that one
                if([[[view class] description] hasPrefix:@"Ti"])
                {
                    [view updateStylesAsync];
                    *stop = YES;
                }
            }];
        }
        else
        {
            [window updateStylesAsync];
        }
    }];
}

+ (void)updateStyles:(id<PXStyleable>)styleable
{
    [styleable updateStyles];
}

+ (void)updateStylesNonRecursively:(id<PXStyleable>)styleable
{
    [styleable updateStylesNonRecursively];
}

+ (void)updateStylesAsync:(id<PXStyleable>)styleable
{
    [styleable updateStylesAsync];
}

+ (void)updateStylesNonRecursivelyAsync:(id<PXStyleable>)styleable
{
    [styleable updateStylesNonRecursivelyAsync];
}

+ (void)clearImageCache
{
    [PXCacheManager clearImageCache];
}

+ (void)clearStyleCache
{
    [PXCacheManager clearStyleCache];
}

#pragma mark - Initializers

- (id)init
{
    if (self = [super init])
    {
        _configuration = [[PixateFreestyleConfiguration alloc] init];
    }

    return self;
}

#pragma mark - Properties (and Overrides)

-(void)internalSetRefreshStylesWithOrientationChange:(BOOL)val
{
    if(val && _refreshStylesWithOrientationChange)
    {
        // Prevent listening more than once at a time
        return;
    }

    if(val == YES)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationWillChangeNotification:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }

    _refreshStylesWithOrientationChange = val;
}

#pragma mark - Methods

- (void)orientationWillChangeNotification:(NSNotification *)notification
{
    /*
    UIInterfaceOrientation nextOrientation = [[notification.userInfo
                                               objectForKey:UIApplicationStatusBarOrientationUserInfoKey] intValue];
     NSLog(@"Rotate! %d", nextOrientation);
    */

    [PXCacheManager clearStyleCache];
    [PXStylesheet clearCache];

    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
    if (keyWindow.styleMode != PXStylingNormal)
        keyWindow.styleMode = PXStylingNormal;
    [keyWindow updateStyles];
}

@end
