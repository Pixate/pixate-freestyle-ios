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
//  PXOffsets.m
//  Pixate
//
//  Created by Kevin Lindsey on 12/17/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXOffsets.h"

@implementation PXOffsets

#pragma mark - Initializers

- (id)init
{
    return [self initWithTop:0.0f right:0.0f bottom:0.0f left:0.0f];
}

- (id)initWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left
{
    if (self = [super init])
    {
        _top = top;
        _right = right;
        _bottom = bottom;
        _left = left;
    }

    return self;
}

#pragma mark - Getters

- (BOOL)hasOffset
{
    return (_top > 0.0f || _right > 0.0f || _bottom > 0.0f || _left > 0.0f);
}

@end
