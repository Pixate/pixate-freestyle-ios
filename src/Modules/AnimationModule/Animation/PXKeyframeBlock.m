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
//  PXKeyframeBlock.m
//  Pixate
//
//  Created by Kevin Lindsey on 3/5/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXKeyframeBlock.h"
#import "PXSourceWriter.h"

@implementation PXKeyframeBlock

- (id)initWithOffset:(CGFloat)offset
{
    if (self = [super init])
    {
        _offset = offset;
    }

    return self;
}

#pragma mark - Overrides

- (NSString *)description
{
    PXSourceWriter *writer = [[PXSourceWriter alloc] init];

    [writer increaseIndent];
    [writer printIndent];

    [writer print:[NSString stringWithFormat:@"%f ", self.offset]];

    [writer printWithNewLine:@"{"];
    [writer increaseIndent];

    for (PXDeclaration *declaration in self.declarations)
    {
        [writer printIndent];
        [writer printWithNewLine:declaration.description];
    }

    [writer decreaseIndent];
    [writer printIndent];
    [writer print:@"}"];

    [writer decreaseIndent];

    return writer.description;
}

@end
