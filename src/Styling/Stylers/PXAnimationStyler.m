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
//  PXAnimationStyler.m
//  Pixate
//
//  Created by Kevin Lindsey on 3/5/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXAnimationStyler.h"
#import "PXAnimationInfo.h"
#import "PXAnimationPropertyHandler.h"
#import "PXKeyframeAnimation.h"

@implementation PXAnimationStyler

#pragma mark - Overrides

+ (PXAnimationStyler *)sharedInstance
{
	static __strong PXAnimationStyler *sharedInstance = nil;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		sharedInstance = [[PXAnimationStyler alloc] initWithCompletionBlock:nil];
	});

	return sharedInstance;
}

- (NSDictionary *)declarationHandlers
{
    static __strong NSDictionary *handlers = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        handlers = @{
             @"animation" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                 context.animationInfos = [NSMutableArray arrayWithArray:declaration.animationInfoList];
             },
             @"animation-name" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                 NSArray *names = declaration.nameListValue;

                 for (NSUInteger i = 0; i < names.count; i++)
                 {
                     PXAnimationInfo *info = [self animationInfoAtIndex:i context:context];
                     NSString *name = [names objectAtIndex:i];

                     info.animationName = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                 }
             },
             @"animation-duration" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                 NSArray *timeValues = declaration.secondsListValue;

                 for (NSUInteger i = 0; i < timeValues.count; i++)
                 {
                     PXAnimationInfo *info = [self animationInfoAtIndex:i context:context];
                     NSNumber *time = [timeValues objectAtIndex:i];

                     info.animationDuration = [time floatValue];
                 }
             },
             @"animation-timing-function" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                 NSArray *timingFunctions = declaration.animationTimingFunctionList;

                 for (NSUInteger i = 0; i < timingFunctions.count; i++)
                 {
                     PXAnimationInfo *info = [self animationInfoAtIndex:i context:context];
                     NSNumber *value = [timingFunctions objectAtIndex:i];

                     info.animationTimingFunction = (PXAnimationTimingFunction) [value intValue];
                 }
             },
             @"animation-iteration-count" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                 NSArray *counts = declaration.floatListValue;

                 for (NSUInteger i = 0; i < counts.count; i++)
                 {
                     PXAnimationInfo *info = [self animationInfoAtIndex:i context:context];
                     NSNumber *count = [counts objectAtIndex:i];

                     info.animationIterationCount = (NSUInteger)[count floatValue];
                 }
             },
             @"animation-direction" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                 NSArray *directions = declaration.animationDirectionList;

                 for (NSUInteger i = 0; i < directions.count; i++)
                 {
                     PXAnimationInfo *info = [self animationInfoAtIndex:i context:context];
                     NSNumber *value = [directions objectAtIndex:i];

                     info.animationDirection = (PXAnimationDirection) [value intValue];
                 }
             },
             @"animation-play-state" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                 NSArray *playStates = declaration.animationPlayStateList;

                 for (NSUInteger i = 0; i < playStates.count; i++)
                 {
                     PXAnimationInfo *info = [self animationInfoAtIndex:i context:context];
                     NSNumber *value = [playStates objectAtIndex:i];

                     info.animationPlayState = (PXAnimationPlayState) [value intValue];
                 }
             },
             @"animation-delay" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                 NSArray *timeValues = declaration.secondsListValue;

                 for (NSUInteger i = 0; i < timeValues.count; i++)
                 {
                     PXAnimationInfo *info = [self animationInfoAtIndex:i context:context];
                     NSNumber *time = [timeValues objectAtIndex:i];

                     info.animationDelay = [time floatValue];
                 }
             },
             @"animation-fill-mode" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                 NSArray *fillModes = declaration.animationFillModeList;

                 for (NSUInteger i = 0; i < fillModes.count; i++)
                 {
                     PXAnimationInfo *info = [self animationInfoAtIndex:i context:context];
                     NSNumber *value = [fillModes objectAtIndex:i];

                     info.animationFillMode = (PXAnimationFillMode) [value intValue];
                 }
             },
        };
    });

    return handlers;
}

- (PXAnimationInfo *)animationInfoAtIndex:(NSUInteger)index context:(PXStylerContext *)context
{
    NSMutableArray *infos = context.animationInfos;

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
    // remove invalid animation infos
    NSMutableArray *infos = context.animationInfos;
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
    context.animationInfos = infos;

    if (self.completionBlock)
    {
        // continue with default behavior
        [super applyStylesWithContext:context];
    }
    else
    {
        NSArray *animationInfos = context.animationInfos;
        NSArray *keyframes = [self keyframeAnimationsFromInfos:animationInfos styleable:context.styleable];

        // TODO: Can this be something else than UIView?
        UIView *view = (UIView *)context.styleable;

        [keyframes enumerateObjectsUsingBlock:^(CAKeyframeAnimation *keyframe, NSUInteger idx, BOOL *stop) {
            [view.layer addAnimation:keyframe forKey:nil];
        }];


        /*
        CATransition* trans = [CATransition animation];
        trans.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        trans.duration = 1;
        trans.type = kCATransitionFade;
        trans.removedOnCompletion = YES;
        trans.subtype = kCATransitionFromTop;

        [NSObject performBlock:^{
            [view.layer addAnimation:trans forKey:@"transition"];
            context.styleable.styleId = @"button1fun";
        } afterDelay:0.02];
         */
    }
}

- (NSDictionary *)defaultAnimationPropertyHandlers
{
    static NSDictionary *KEY_PATH_FROM_PROPERTY;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        KEY_PATH_FROM_PROPERTY = @{
            @"left": [[PXAnimationPropertyHandler alloc] initWithKeyPath:@"position.x" block:PXAnimationPropertyHandler.FloatValueBlock],
            @"top": [[PXAnimationPropertyHandler alloc] initWithKeyPath:@"position.y" block:PXAnimationPropertyHandler.FloatValueBlock],
            @"opacity": [[PXAnimationPropertyHandler alloc] initWithKeyPath:@"opacity" block:PXAnimationPropertyHandler.FloatValueBlock],
            @"rotation": [[PXAnimationPropertyHandler alloc] initWithKeyPath:@"transform.rotation.z" block:PXAnimationPropertyHandler.FloatValueBlock],
            @"scale": [[PXAnimationPropertyHandler alloc] initWithKeyPath:@"transform.scale" block:PXAnimationPropertyHandler.FloatValueBlock],
        };
    });
    
    return KEY_PATH_FROM_PROPERTY;
}

- (NSArray *)keyframeAnimationsFromInfos:(NSArray *)infos styleable:(id<PXStyleable>)styleable
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSMutableDictionary *propertyHandlers = [[NSMutableDictionary alloc] initWithDictionary:[self defaultAnimationPropertyHandlers]];

    // Add any additional user-provided property handlers
    if ([styleable respondsToSelector:@selector(animationPropertyHandlers)])
    {
        [propertyHandlers addEntriesFromDictionary:[styleable animationPropertyHandlers]];
    }
    
    NSMutableDictionary *keyframes = [[NSMutableDictionary alloc] init];

    [infos enumerateObjectsUsingBlock:^(PXAnimationInfo *info, NSUInteger idx, BOOL *stop) {
        if (info.isValid)
        {
            PXKeyframe *keyframe = info.keyframe;

            if (keyframe)
            {
                [keyframe.blocks enumerateObjectsUsingBlock:^(PXKeyframeBlock *block, NSUInteger idx, BOOL *stop) {
                    [block.declarations enumerateObjectsUsingBlock:^(PXDeclaration *declaration, NSUInteger idx, BOOL *stop) {
                        PXAnimationPropertyHandler *propertyHandler = [propertyHandlers objectForKey:declaration.name];

                        if (propertyHandler != nil)
                        {
                            NSString *keyPath = propertyHandler.keyPath;
                            PXKeyframeAnimation *animation = [keyframes objectForKey:keyPath];

                            if (animation == nil)
                            {
                                animation = [[PXKeyframeAnimation alloc] init];
                                animation.keyPath = keyPath;
                                animation.duration = info.animationDuration;
                                animation.fillMode = info.animationFillMode;
                                animation.repeatCount = info.animationIterationCount;
                                animation.beginTime = info.animationDelay;

                                [keyframes setObject:animation forKey:keyPath];
                            }

                            // TODO: need to grab value type as is appropriate for the property being animated (via blocks?)
                            [animation addValue:[propertyHandler getValueFromDeclaration:declaration]];
                            [animation addKeyTime:block.offset];
                            [animation addTimingFunction:info.animationTimingFunction];
                        }
                    }];
                }];
            }
        }
    }];

    [keyframes enumerateKeysAndObjectsUsingBlock:^(NSString *key, PXKeyframeAnimation *animation, BOOL *stop) {
        CAKeyframeAnimation *keyframe = animation.caKeyframeAnimation;

        if (keyframe != nil)
        {
            [result addObject:keyframe];
        }
    }];

    return result;
}

@end
