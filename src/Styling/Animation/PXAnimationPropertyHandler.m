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
//  PXAnimationPropertyHandler.m
//  Pixate
//
//  Created by Kevin Lindsey on 3/31/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXAnimationPropertyHandler.h"

@implementation PXAnimationPropertyHandler

#pragma mark - Static Methods

+ (PXAnimationPropertyHandlerBlock)FloatValueBlock
{
    return (id)^(PXDeclaration *declaration)
    {
        return @(declaration.floatValue);
    };
}

#pragma mark - Initializers

- (id)initWithKeyPath:(NSString *)keyPath block:(PXAnimationPropertyHandlerBlock)block
{
    if (self = [super init])
    {
        _keyPath = keyPath;
        _block = block;
    }

    return self;
}

#pragma mark - Getters

- (id)getValueFromDeclaration:(PXDeclaration *)declaration
{
    id result = nil;

    if (_block != nil)
    {
        result = _block(declaration);
    }

    return result;
}

@end
