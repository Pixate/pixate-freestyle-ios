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
//  PXShadowGroup.h
//  Pixate
//
//  Created by Kevin Lindsey on 12/7/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXShadowPaint.h"

/**
 *  A PXShadowGroup serves as a collection of PXShadowPaints
 */
@interface PXShadowGroup : NSObject <PXShadowPaint>

/**
 *  Returns the number of PXShadowPaints in this group
 */
@property (nonatomic, readonly) NSUInteger count;

/**
 *  The list of PXShadowPaints associated with this shadow group
 */
@property (nonatomic, readonly) NSArray *shadows;

/**
 *  Add a PXShapowPaint to this shadow group
 *
 *  @param shadow The PXShadowPaint to add
 */
- (void)addShadowPaint:(id<PXShadowPaint>)shadow;

@end
