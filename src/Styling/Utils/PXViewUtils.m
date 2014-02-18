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
//  PXViewUtils.m
//  Pixate
//
//  Created by Kevin Lindsey on 1/4/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "PXViewUtils.h"
#import "PXSourceWriter.h"
#import "PXStyleable.h"
#import "NSMutableArray+QueueAdditions.h"

@implementation PXViewUtils

+ (NSString *)viewDescription:(UIView *)view
{
    PXSourceWriter *writer = [[PXSourceWriter alloc] init];

    [self recursiveDescription:view withSourceWriter:writer];

    return writer.description;
}

+ (void)recursiveDescription:(UIView *)view withSourceWriter:(PXSourceWriter *)writer
{
    NSArray *subviews = view.subviews;

    if (subviews.count > 0 || view.layer)
    {
        // emit start tag
        [writer printIndent];
        [writer print:@"<view"];
        [self emitAttributes:view withSourceWriter:writer];
        [writer printWithNewLine:@">"];

        // emit children
        [writer increaseIndent];

        // emit layers
        [self emitLayer:view.layer withSourceWriter:writer];

        // emit sub-views
        for (UIView *subview in subviews)
        {
            [self recursiveDescription:subview withSourceWriter:writer];
        }

        [writer decreaseIndent];

        // emit end tag
        [writer printIndent];
        [writer printWithNewLine:@"</view>"];
    }
    else
    {
        // emit self-closing tag
        [writer printIndent];
        [writer print:@"<view"];
        [self emitAttributes:view withSourceWriter:writer];
        [writer printWithNewLine:@"/>"];
    }
}

+ (void)emitLayer:(CALayer *)layer withSourceWriter:(PXSourceWriter *)writer
{
    NSArray *sublayers = layer.sublayers;

    if (sublayers.count > 0)
    {
        // emit start tag
        [writer printIndent];
        [writer print:@"<layer"];
        [self emitAttributes:layer withSourceWriter:writer];
        [writer printWithNewLine:@">"];

        // emit children
        [writer increaseIndent];

        // emit layers
        for (CALayer *sublayer in sublayers)
        {
            [self emitLayer:sublayer withSourceWriter:writer];
        }

        [writer decreaseIndent];

        // emit end tag
        [writer printIndent];
        [writer printWithNewLine:@"</layer>"];
    }
    else
    {
        // emit self-closing tag
        [writer printIndent];
        [writer print:@"<layer"];
        [self emitAttributes:layer withSourceWriter:writer];
        [writer printWithNewLine:@"/>"];
    }
}

+ (void)emitAttributes:(NSObject *)view withSourceWriter:(PXSourceWriter *)writer
{
    // emit type
    [self emitAttributeName:@"type" value:[view.class description] withSourceWriter:writer];

    // emit pointer address
    [self emitAttributeName:@"ptr" value:[NSString stringWithFormat:@"0x%lX", (long) view] withSourceWriter:writer];

    // emit id and class
    if ([view conformsToProtocol:@protocol(PXStyleable)])
    {
        id<PXStyleable> styleable = (id<PXStyleable>) view;

        if (styleable.styleId)
        {
            [self emitAttributeName:@"id" value:styleable.styleId withSourceWriter:writer];
        }

        if (styleable.styleClass)
        {
            [self emitAttributeName:@"class" value:styleable.styleClass withSourceWriter:writer];
        }
    }
}

+ (void)emitAttributeName:(NSString *)name value:(NSString *)value withSourceWriter:(PXSourceWriter *)writer
{
    [writer print:@" "];
    [writer print:name];
    [writer print:@"=\""];
    [writer print:value];
    [writer print:@"\""];
}

@end
