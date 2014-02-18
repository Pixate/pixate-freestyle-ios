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
//  PXCombinatorBase.h
//  Pixate
//
//  Created by Kevin Lindsey on 9/25/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXCombinatorBase.h"
#import "PXSpecificity.h"
#import "PXSourceWriter.h"

@implementation PXCombinatorBase

@synthesize lhs = _lhs;
@synthesize rhs = _rhs;

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

- (id)initWithLHS:(id<PXSelector>)lhs RHS:(id<PXSelector>)rhs
{
    if (self = [super init])
    {
        self->_lhs = lhs;
        self->_rhs = rhs;
    }

    return self;
}

#pragma mark - Getters

- (NSString *)displayName
{
    // sublasses need to implement this method
    return @"<unknown>";
}

#pragma mark - Methods

- (BOOL)matches:(id<PXStyleable>)element
{
    DDLogError(@"The 'matches:' method should not be called and should be overridden");

    // subclasses need to implement this method
    return NO;
}

- (void)incrementSpecificity:(PXSpecificity *)specificity
{
    [self->_lhs incrementSpecificity:specificity];
    [self->_rhs incrementSpecificity:specificity];
}

#pragma mark - PXSourcEmitter Methods

- (NSString *)source
{
    PXSourceWriter *writer = [[PXSourceWriter alloc] init];

    [self sourceWithSourceWriter:writer];

    return writer.description;
}

- (void)sourceWithSourceWriter:(id)writer
{
    [writer printIndent];
    [writer print:@"("];
    [writer print:self.displayName];
    [writer printNewLine];
    [writer increaseIndent];

    [self.lhs sourceWithSourceWriter:writer];
    [writer printNewLine];
    [self.rhs sourceWithSourceWriter:writer];

    [writer print:@")"];
    [writer decreaseIndent];
}

@end
