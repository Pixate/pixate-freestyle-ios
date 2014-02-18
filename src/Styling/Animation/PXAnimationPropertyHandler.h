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
//  PXAnimationPropertyHandler.h
//  Pixate
//
//  Created by Kevin Lindsey on 3/31/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXDeclaration.h"

/**
 *  A typedef for the block that will be called once this styler is ready to be applied to a control
 *
 *  @param view The view to be styled
 *  @param styler The styler to use when styling the view
 *  @param context Any additional context associated with this styling cycle
 */
typedef id(^PXAnimationPropertyHandlerBlock)(PXDeclaration *declaration);

@interface PXAnimationPropertyHandler : NSObject

@property (nonatomic, strong) NSString *keyPath;
@property (nonatomic, strong) PXAnimationPropertyHandlerBlock block;

+ (PXAnimationPropertyHandlerBlock)FloatValueBlock;

- (id)initWithKeyPath:(NSString *)keyPath block:(PXAnimationPropertyHandlerBlock)block;
- (id)getValueFromDeclaration:(PXDeclaration *)declaration;

@end
