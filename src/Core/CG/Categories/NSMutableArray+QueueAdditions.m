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
//  NSMutableArray+QueueAdditions.m
//  Pixate
//
//  Created by Kevin Lindsey on 6/30/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "NSMutableArray+QueueAdditions.h"

void PXForceLoadQueueAdditions() {}

@implementation NSMutableArray (QueueAdditions)

#pragma mark - Methods

- (id)dequeue
{
    id result = nil;

    if (self.count > 0)
    {
        result = [self objectAtIndex:0];

        [self removeObjectAtIndex:0];
    }

    return result;
}

- (void)enqueue:(id)object
{
    [self addObject:object];
}

@end
