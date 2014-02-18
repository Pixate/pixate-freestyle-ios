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
//  PXPseudoClassSelector.h
//  Pixate
//
//  Created by Kevin Lindsey on 9/1/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXSelector.h"

/**
 *  A PXPseudoClassExpression is used to represent a specific state of an element, for purposes of styling.
 */
@interface PXPseudoClassSelector : NSObject <PXSelector>

/**
 *  The pseudo-class name to match
 */
@property (readonly, nonatomic, strong) NSString *className;

/**
 *  Initializer a new instance with the specified pseudo-class name
 *
 *  @param name The pseudo-class name
 */
- (id)initWithClassName:(NSString *)name;

@end
