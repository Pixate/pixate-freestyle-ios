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
//  PXAnimationInfo.m
//  Pixate
//
//  Created by Kevin Lindsey on 3/5/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXAnimationInfo.h"

#import "PXStylesheet.h"
#import "PXStylesheet-Private.h"

@implementation PXAnimationInfo

#pragma mark - Initializers

/**
 *  Use this method to get undefined values (needed for parsing)
 */
- (id)init
{
    if (self = [super init])
    {
        _animationName = nil;
        _animationDuration = CGFLOAT_MAX;
        _animationTimingFunction = PXAnimationTimingFunctionUndefined;
        _animationIterationCount = NSUIntegerMax;
        _animationDirection = PXAnimationDirectionUndefined;
        _animationPlayState = PXAnimationPlayStateUndefined;
        _animationDelay = CGFLOAT_MAX;
        _animationFillMode = PXAnimationFillModeUndefined;
    }

    return self;
}

/**
 *  Use this method to get CSS default values
 */
- (id)initWithCSSDefaults
{
    if (self = [super init])
    {
        _animationName = nil;
        _animationDuration = 0.0f;
        _animationTimingFunction = PXAnimationTimingFunctionEase;
        _animationIterationCount = 0;
        _animationDirection = PXAnimationDirectionNormal;
        _animationPlayState = PXAnimationPlayStateRunning;
        _animationDelay = 0.0f;
        _animationFillMode = PXAnimationFillModeNone;
    }

    return self;
}

#pragma mark - Getters

- (PXKeyframe *)keyframe
{
    PXKeyframe *result = [[PXStylesheet currentViewStylesheet] keyframeForName:_animationName];

    if (result == nil)
    {
        result = [[PXStylesheet currentUserStylesheet] keyframeForName:_animationName];
    }

    if (result == nil)
    {
        result = [[PXStylesheet currentApplicationStylesheet] keyframeForName:_animationName];
    }

    return result;
}

-(BOOL)isValid
{
    return (
            _animationDuration != CGFLOAT_MAX
        &&  _animationTimingFunction != PXAnimationTimingFunctionUndefined
        &&  _animationIterationCount != NSUIntegerMax
        &&  _animationDirection != PXAnimationDirectionUndefined
        &&  _animationPlayState != PXAnimationPlayStateUndefined
        &&  _animationDelay != CGFLOAT_MAX
        &&  _animationFillMode != PXAnimationFillModeUndefined);

}

#pragma mark - Methods

- (void)setUndefinedPropertiesWithAnimationInfo:(PXAnimationInfo *)info
{
    // skip animationName

    if (_animationDuration == CGFLOAT_MAX)
    {
        _animationDuration = info.animationDuration;
    }
    if (_animationTimingFunction == PXAnimationTimingFunctionUndefined)
    {
        _animationTimingFunction = info.animationTimingFunction;
    }
    if (_animationIterationCount == NSUIntegerMax)
    {
        _animationIterationCount = info.animationIterationCount;
    }
    if (_animationDirection == PXAnimationDirectionUndefined)
    {
        _animationDirection = info.animationDirection;
    }
    if (_animationPlayState == PXAnimationPlayStateUndefined)
    {
        _animationPlayState = info.animationPlayState;
    }
    if (_animationDelay == CGFLOAT_MAX)
    {
        _animationDelay = info.animationDelay;
    }
    if (_animationFillMode == PXAnimationFillModeUndefined)
    {
        _animationFillMode = info.animationFillMode;
    }
}

@end
