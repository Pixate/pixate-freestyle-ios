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
//  UIView+PXStyling.h
//  PXButtonDemo
//
//  Created by Kevin Lindsey on 8/22/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

//
// Timing macros
//

#include <mach/mach.h>
#include <mach/mach_time.h>

#define TICK  \
    uint64_t startTick = mach_absolute_time(); \
    mach_timebase_info_data_t timebaseInfo; \
    mach_timebase_info(&timebaseInfo);


#define TOCK  \
    uint64_t endTick = mach_absolute_time(); \
    uint64_t tickDiff = endTick - startTick; \
    double diffMillis = (double) (tickDiff * timebaseInfo.numer) / (double) (timebaseInfo.denom * 1e6); \
    NSLog(@"Time: %f ms", diffMillis);

//
// Interface
//

#import <UIKit/UIKit.h>
#import "PXStyleable.h"

@interface UIView (PXStyling) <PXStyleable>

@property (nonatomic, copy) NSString *styleId;
@property (nonatomic, copy) NSString *styleClass;
@property (nonatomic, copy) NSString *styleCSS;
@property (nonatomic) PXStylingMode styleMode UI_APPEARANCE_SELECTOR;

- (void)addStyleClass:(NSString *)styleClass;
- (void)removeStyleClass:(NSString *)styleClass;
- (void)styleClassed:(NSString *)styleClass enabled:(bool)enabled;

+ (void)updateStyles:(id<PXStyleable>)styleable recursively:(bool)recurse;

@end
