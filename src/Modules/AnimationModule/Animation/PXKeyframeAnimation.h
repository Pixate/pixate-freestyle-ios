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
//  PXKeyframeAnimation.h
//  Pixate
//
//  Created by Kevin Lindsey on 3/28/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXAnimationInfo.h"
#import <QuartzCore/QuartzCore.h>

@interface PXKeyframeAnimation : NSObject

@property (nonatomic) NSString *keyPath;
@property (nonatomic) CGFloat beginTime;
@property (nonatomic) CGFloat duration;
@property (nonatomic) NSArray *values;
@property (nonatomic) NSArray *keyTimes;
@property (nonatomic) NSArray *timingFunctions;
@property (nonatomic) PXAnimationFillMode fillMode;
@property (nonatomic) NSUInteger repeatCount;

@property (nonatomic) CAKeyframeAnimation *caKeyframeAnimation;

- (void)addValue:(id)value;
- (void)addKeyTime:(CGFloat)keyTime;
- (void)addTimingFunction:(PXAnimationTimingFunction)timingFunction;

@end
