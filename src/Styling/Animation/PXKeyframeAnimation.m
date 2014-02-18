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
//  PXKeyframeAnimation.m
//  Pixate
//
//  Created by Kevin Lindsey on 3/28/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXKeyframeAnimation.h"
#import <QuartzCore/QuartzCore.h>

@implementation PXKeyframeAnimation
{
    NSMutableArray *_values;
    NSMutableArray *_keyTimes;
    NSMutableArray *_timingFunctions;
    NSString *caFillMode_;
}

#pragma mark - Setters

- (void)setFillMode:(PXAnimationFillMode)fillMode
{
    _fillMode = fillMode;

    // TODO: This is the CA default. What should it be for CSS?
    caFillMode_ = kCAFillModeRemoved;

    switch (_fillMode)
    {
        case PXAnimationFillModeBackwards:
            caFillMode_ = kCAFillModeBackwards;
            break;

        case PXAnimationFillModeBoth:
            caFillMode_ = kCAFillModeBoth;
            break;

        case PXAnimationFillModeForwards:
            caFillMode_ = kCAFillModeForwards;
            break;

        case PXAnimationFillModeNone:
        case PXAnimationFillModeUndefined:
        default:
            break;
    }
}

#pragma mark - Methods

- (void)addValue:(id)value
{
    if (_values == nil)
    {
        _values = [[NSMutableArray alloc] init];
    }

    [_values addObject:value];
}

- (void)addKeyTime:(CGFloat)keyTime
{
    if (_keyTimes == nil)
    {
        _keyTimes = [[NSMutableArray alloc] init];
    }

    [_keyTimes addObject:@(keyTime)];
}

- (void)addTimingFunction:(PXAnimationTimingFunction)timingFunction
{
    if (_timingFunctions == nil)
    {
        _timingFunctions = [[NSMutableArray alloc] init];
    }

    // TODO: default to linear?
    CAMediaTimingFunction *tf = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];

    switch (timingFunction)
    {
        case PXAnimationTimingFunctionEase:
            break;

        case PXAnimationTimingFunctionEaseIn:
            tf = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
            break;

        case PXAnimationTimingFunctionEaseInOut:
            tf = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            break;

        case PXAnimationTimingFunctionEaseOut:
            tf = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            break;

        case PXAnimationTimingFunctionLinear:
            tf = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            break;

        case PXAnimationTimingFunctionStepEnd:
        case PXAnimationTimingFunctionStepStart:
        case PXAnimationTimingFunctionUndefined:
        default:
            break;
    }

    [_timingFunctions addObject:tf];
}

- (CAKeyframeAnimation *)caKeyframeAnimation
{
    CAKeyframeAnimation *result = nil;

    if (self.isValid)
    {
        result = [CAKeyframeAnimation animationWithKeyPath:self.keyPath];
        result.values = _values;
        result.keyTimes = _keyTimes;
        result.timingFunctions = _timingFunctions;
        result.duration = _duration;
        result.fillMode = caFillMode_;
        result.repeatCount = _repeatCount;
        result.beginTime = CACurrentMediaTime() + _beginTime;

        // should these settable via properties?
        result.cumulative = YES;

        // TODO: this needs to be removed. Perhaps a delegate and remove the animation and set the values to match
        // the end of the animation
        result.removedOnCompletion = NO;
    }

    return result;
}

#pragma mark - Helper Methods

- (BOOL)isValid
{
    return
        _keyPath.length > 0
    &&  _duration > 0.0f
    &&  _values.count == _keyTimes.count
    && _keyTimes.count == _timingFunctions.count;
}

@end
