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
//  PXClassSelector.m
//  Pixate
//
//  Created by Kevin Lindsey on 9/1/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXClassSelector.h"
#import "PXSpecificity.h"
#import "PXStyleable.h"
#import "PXStyleUtils.h"

@implementation PXClassSelector
{
    BOOL canMatch_;
}

@synthesize className = className_;

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

- (id)initWithClassName:(NSString *)name
{
    if (self = [super init])
    {
        className_ = name;
        // names with whitespace can never match
        canMatch_ = ([name rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]].location == NSNotFound);
    }

    return self;
}

#pragma mark - Methods

- (void)incrementSpecificity:(PXSpecificity *)specificity
{
    [specificity incrementSpecifity:kSpecificityTypeClassOrAttribute];
}

- (BOOL)matches:(id<PXStyleable>)element
{
    BOOL result = NO;

    if (canMatch_)
    {
        result = [element.styleClasses containsObject:className_];
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
    return [NSString stringWithFormat:@".%@", className_];
}

- (void)sourceWithSourceWriter:(PXSourceWriter *)writer
{
    [writer printIndent];
    [writer print:@"(CLASS "];
    [writer print:className_];
    [writer print:@")"];
}

@end
