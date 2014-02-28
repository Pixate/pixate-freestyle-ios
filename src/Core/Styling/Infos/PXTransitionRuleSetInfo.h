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
//  PXTransitionRuleSetInfo.h
//  Pixate
//
//  Created by Paul Colton on 2/28/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXStyleable.h"

@interface PXTransitionRuleSetInfo : NSObject

@property (nonatomic, readonly, strong) NSArray *allMatchingRuleSets;
@property (nonatomic, readonly, strong) NSArray *ruleSetsForState;
@property (nonatomic, readonly, strong) NSArray *nonAnimatingRuleSets;
@property (nonatomic, readonly, strong) NSArray *animatingRuleSets;
@property (nonatomic, readonly, strong) PXRuleSet *mergedRuleSet;
@property (nonatomic, readonly, strong) NSArray *transitions;

- (id)initWithStyleable:(id<PXStyleable>)styleable withStateName:(NSString *)stateName;

@end
