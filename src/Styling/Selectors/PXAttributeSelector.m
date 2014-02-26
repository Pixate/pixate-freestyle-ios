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
//  PXAttributeSelector.m
//  Pixate
//
//  Created by Kevin Lindsey on 9/1/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXAttributeSelector.h"
#import "PXStyleable.h"
#import "PXSpecificity.h"
#import "PXStyleUtils.h"

@implementation PXAttributeSelector

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

- (id)init
{
    return [self initWithNamespaceURI:nil attributeName:nil];
}

- (id)initWithAttributeName:(NSString *)name
{
    return [self initWithNamespaceURI:nil attributeName:name];
}

- (id)initWithNamespaceURI:(NSString *)uri attributeName:(NSString *)name
{
    if (self = [super init])
    {
        _namespaceURI = uri;
        _attributeName = name;
    }

    return self;
}

#pragma mark - PXAttributeMatcher Implementation

- (void)incrementSpecificity:(PXSpecificity *)specificity
{
    // TODO: verify this is correct
    [specificity incrementSpecifity:kSpecificityTypeClassOrAttribute];
}

- (BOOL)matches:(id<PXStyleable>)element
{
    BOOL result = NO;

    if ([element respondsToSelector:@selector(attributeValueForName:withNamespace:)])
    {
        result = ([element attributeValueForName:_attributeName withNamespace:_namespaceURI].length > 0);
    }

#if LOG_VERBOSE
    if (result)
    {
        DDLogVerbose(@"'%@' attribute exists on '%@'", _attributeName, [PXStyleUtils descriptionForStyleable:element]);
    }
    else
    {
        DDLogVerbose(@"'%@' attribute does not exist on '%@'", _attributeName, [PXStyleUtils descriptionForStyleable:element]);
    }
#endif

    return result;
}

#pragma mark - Overrides

- (NSString *)description
{
    if (_namespaceURI)
    {
        return [NSString stringWithFormat:@"[%@|%@]", _namespaceURI, _attributeName];
    }
    else
    {
        return [NSString stringWithFormat:@"[*|%@]", _attributeName];
    }
}

@end
