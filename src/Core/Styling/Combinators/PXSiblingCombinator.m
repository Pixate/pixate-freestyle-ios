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
//  PXSiblingCombinator.m
//  Pixate
//
//  Created by Kevin Lindsey on 9/25/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXSiblingCombinator.h"
#import "PXStyleUtils.h"

@implementation PXSiblingCombinator

#ifdef PX_LOGGING
static int ddLogLevel = LOG_LEVEL_WARN;

+ (int)ddLogLevel
{
    return ddLogLevel;
}

+ (void)ddSetLogLevel:(int)logLevel
{
    ddLogLevel = logLevel;
}
#endif

#pragma mark - Getters

- (NSString *)displayName
{
    return @"GENERAL_SIBLING_COMBINATOR";
}

#pragma mark - Methods

- (BOOL)matches:(id<PXStyleable>)element
{
    BOOL result = NO;

    if ([self.rhs matches:element])
    {
        id parent = element.pxStyleParent;

        if ([parent conformsToProtocol:@protocol(PXStyleable)])
        {
            id<PXStyleable> styleableParent = parent;
            NSArray *children = [PXStyleUtils elementChildrenOfStyleable:styleableParent];
            NSUInteger elementIndex = [children indexOfObject:element];

            for (NSUInteger i = 0; i < elementIndex && result == NO; i++)
            {
                id previousSibling = [children objectAtIndex:i];

                if ([previousSibling conformsToProtocol:@protocol(PXStyleable)])
                {
                    id<PXStyleable> styleablePreviousSibling = previousSibling;

                    result = [self.lhs matches:styleablePreviousSibling];
                }
            }
        }
    }

    if (result)
    {
        DDLogVerbose(@"%@ matched %@", self.description, [PXStyleUtils descriptionForStyleable:element]);
    }
    else
    {
        DDLogVerbose(@"%@ did not match %@", self.description, [PXStyleUtils descriptionForStyleable:element]);
    }

    return result;
}

#pragma mark - Overrides

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ ~ %@", self.lhs, self.rhs];
}

@end
