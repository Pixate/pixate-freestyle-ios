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
//  PXNotPseudoClass.m
//  Pixate
//
//  Created by Kevin Lindsey on 9/1/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXNotPseudoClass.h"
#import "PXSpecificity.h"
#import "PXStyleUtils.h"

@implementation PXNotPseudoClass

@synthesize expression = _expression;

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

#pragma mark - Initializers

- (id)initWithExpression:(id<PXSelector>)expression
{
    if (self = [super init])
    {
        self->_expression = expression;
    }

    return self;
}

#pragma mark - Methods

- (void)incrementSpecificity:(PXSpecificity *)specificity
{
    if (_expression)
    {
        [_expression incrementSpecificity:specificity];
    }
}

- (BOOL)matches:(id<PXStyleable>)element
{
    BOOL result = NO;

    // NOTE: I can't find a definition for what to do with an empty :not(); however, the W3C selector level 3 tests,
    // specifically #49, implies that *|*:not() should match nothing, so I'm assuming no expression means :not()
    // always fails

    if (_expression)
    {
        result = ![_expression matches:element];
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
    if (_expression)
    {
        return [NSString stringWithFormat:@":not(%@)", _expression];
    }
    else
    {
        return @":not()";
    }
}

@end
