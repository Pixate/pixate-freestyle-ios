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
//  PXTransitionStyler.m
//  Pixate
//
//  Created by Kevin Lindsey on 3/7/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXTransitionStyler.h"

@implementation PXTransitionStyler

#pragma mark - Overrides

- (NSDictionary *)declarationHandlers
{
    static __strong NSDictionary *handlers = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        handlers = @{
             @"transition" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                 context.transitionInfos = [NSMutableArray arrayWithArray:declaration.transitionInfoList];
             },
             @"transition-property" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                 NSArray *names = declaration.nameListValue;

                 for (NSUInteger i = 0; i < names.count; i++)
                 {
                     PXAnimationInfo *info = [self transitionInfoAtIndex:i context:context];
                     NSString *name = [names objectAtIndex:i];

                     info.animationName = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                 }
             },
             @"transition-duration" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                 NSArray *timeValues = declaration.secondsListValue;

                 for (NSUInteger i = 0; i < timeValues.count; i++)
                 {
                     PXAnimationInfo *info = [self transitionInfoAtIndex:i context:context];
                     NSNumber *time = [timeValues objectAtIndex:i];

                     info.animationDuration = [time floatValue];
                 }
             },
             @"transition-timing-function" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                 NSArray *timingFunctions = declaration.animationTimingFunctionList;

                 for (NSUInteger i = 0; i < timingFunctions.count; i++)
                 {
                     PXAnimationInfo *info = [self transitionInfoAtIndex:i context:context];
                     NSNumber *value = [timingFunctions objectAtIndex:i];

                     info.animationTimingFunction = (PXAnimationTimingFunction) [value intValue];
                 }
             },
             @"transition-delay" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                 NSArray *timeValues = declaration.secondsListValue;

                 for (NSUInteger i = 0; i < timeValues.count; i++)
                 {
                     PXAnimationInfo *info = [self transitionInfoAtIndex:i context:context];
                     NSNumber *time = [timeValues objectAtIndex:i];

                     info.animationDelay = [time floatValue];
                 }
             },
         };
    });

    return handlers;
}

- (PXAnimationInfo *)transitionInfoAtIndex:(NSUInteger)index context:(PXStylerContext *)context
{
    NSMutableArray *infos = context.transitionInfos;

    if (infos == nil)
    {
        infos = [[NSMutableArray alloc] init];
        context.animationInfos = infos;
    }

    while (infos.count <= index)
    {
        [infos addObject:[[PXAnimationInfo alloc] init]];
    }

    return [infos objectAtIndex:index];
}

- (void)applyStylesWithContext:(PXStylerContext *)context
{
    // remove invalid transition infos
    NSMutableArray *infos = context.transitionInfos;
    NSMutableArray *toRemove = [[NSMutableArray alloc] init];
    PXAnimationInfo *currentSettings = [[PXAnimationInfo alloc] initWithCSSDefaults];

    for (PXAnimationInfo *info in infos)
    {
        if (info.animationName.length == 0)
        {
            // queue up to delete this unnamed animation
            [toRemove addObject:info];
        }
        else
        {
            // set any undefined values using the latest settings
            [info setUndefinedPropertiesWithAnimationInfo:currentSettings];
            currentSettings = info;
        }
    }

    [infos removeObjectsInArray:toRemove];
    context.transitionInfos = infos;

    // continue with default behavior
    [super applyStylesWithContext:context];
}

@end
