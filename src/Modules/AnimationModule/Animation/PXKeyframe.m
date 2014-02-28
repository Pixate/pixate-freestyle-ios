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
//  PXKeyframe.m
//  Pixate
//
//  Created by Kevin Lindsey on 3/5/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXKeyframe.h"
#import "PXSourceWriter.h"

@implementation PXKeyframe
{
    NSMutableArray *blocks_;
}

#pragma mark - Initializers

- (id)initWithName:(NSString *)name
{
    if (self = [super init])
    {
        _name = name;
    }

    return self;
}

#pragma mark - Getters

- (NSArray *)blocks
{
    return [NSArray arrayWithArray:blocks_];
}

#pragma mark - Methods

- (void)addKeyframeBlock:(PXKeyframeBlock *)block
{
    if (block)
    {
        if (blocks_ == nil)
        {
            blocks_ = [[NSMutableArray alloc] init];
        }

        [blocks_ addObject:block];
    }
}

#pragma mark - Overrides

- (NSString *)description
{
    PXSourceWriter *writer = [[PXSourceWriter alloc] init];

    [writer print:[NSString stringWithFormat:@"@keyframes %@ ", self.name]];

    [writer printWithNewLine:@"{"];

    for (PXKeyframeBlock *block in self.blocks)
    {
        [writer printWithNewLine:block.description];
    }

    [writer print:@"}"];

    return writer.description;
}

@end
