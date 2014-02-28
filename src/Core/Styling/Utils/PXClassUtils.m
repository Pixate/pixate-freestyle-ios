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
//  PXClassUtils.m
//  Pixate
//
//  Created by Kevin Lindsey on 1/4/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXClassUtils.h"
#import "PXSourceWriter.h"
#import <objc/runtime.h>

@implementation PXClassUtils

+ (NSString *)classDescriptionForObject:(id)object
{
    return [self classDescription:object_getClass(object)];
}

+ (NSString *)classDescription:(Class)c
{
    PXSourceWriter *writer = [[PXSourceWriter alloc] init];

    // emit class name
    [writer print:[self stringFromCString:class_getName(c)]];

    // emit superclass
    Class sc = class_getSuperclass(c);
    [writer print:@" : "];
    [writer print:[self stringFromCString:class_getName(sc)]];

    [self emitProtocols:c withSourceWriter:writer];

    // emit content
    [writer printWithNewLine:@" {"];
    [writer increaseIndent];

    [self emitAddress:c withSourceWriter:writer];
    [self emitVersion:c withSourceWriter:writer];
    [self emitIvars:c withSourceWriter:writer];
    [self emitProperties:c withSourceWriter:writer];
    [self emitMethods:c withSourceWriter:writer];

    // close
    [writer decreaseIndent];
    [writer printIndent];
    [writer printWithNewLine:@"}"];

    return writer.description;
}

+ (void)emitProtocols:(Class)c withSourceWriter:(PXSourceWriter *)writer
{
    // emit protocols
    unsigned int count = 0;
    __unsafe_unretained Protocol **protocols = class_copyProtocolList(c, &count);

    if (count > 0)
    {
        [writer print:@" <"];

        for (NSUInteger index = 0; index < count; ++index)
        {
            Protocol *protocol = protocols[index];

            if (index)
            {
                [writer print:@","];
            }

            [writer print:[self stringFromCString:protocol_getName(protocol)]];
        }

        [writer print:@">"];
    }

    free(protocols);
}

+ (void)emitAddress:(Class)c withSourceWriter:(PXSourceWriter *)writer
{
    // emit pointer address
    [writer printIndent];
    [writer print:@"@ptr "];
    [writer printWithNewLine:[NSString stringWithFormat:@"0x%lX", (long) c]];
}

+ (void)emitVersion:(Class)c withSourceWriter:(PXSourceWriter *)writer
{
    // emit class version
    [writer printIndent];
    [writer print:@"@version "];
    [writer printWithNewLine:[NSString stringWithFormat:@"%d", class_getVersion(c)]];
}

+ (void)emitIvars:(Class)c withSourceWriter:(PXSourceWriter *)writer
{
    // emit ivars
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList(c, &count);

    for (NSUInteger index = 0; index < count; ++index)
    {
        Ivar ivar = ivars[index];

        [writer printIndent];
        [writer print:@"@ivar "];
        [writer printWithNewLine:[self stringFromCString:ivar_getName(ivar)]];
    }

    free(ivars);
}

+ (void)emitProperties:(Class)c withSourceWriter:(PXSourceWriter *)writer
{
    // emit properties
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList(c, &count);

    for (NSUInteger index = 0; index < count; ++index)
    {
        objc_property_t property = properties[index];

        [writer printIndent];
        [writer print:@"@property "];
        [writer printWithNewLine:[self stringFromCString:property_getName(property)]];
    }
}

+ (void)emitMethods:(Class)c withSourceWriter:(PXSourceWriter *)writer
{
    // emit methods
    unsigned int count = 0;
    Method *methods = class_copyMethodList(c, &count);

    for (NSUInteger index = 0; index < count; ++index)
    {
        Method method = methods[index];
        SEL methodName = method_getName(method);

        [writer printIndent];
        [writer print:@"@method "];
        [writer printWithNewLine:[self stringFromCString:sel_getName(methodName)]];
    }

    free(methods);
}

+ (NSString *)stringFromCString:(const char *)cstring
{
    return (cstring) ? [NSString stringWithCString:cstring encoding:NSUTF8StringEncoding] : @"";
}

@end
