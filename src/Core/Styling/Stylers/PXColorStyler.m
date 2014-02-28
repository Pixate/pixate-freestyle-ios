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
//  PXColorStyler.m
//  Pixate
//
//  Created by Kevin Lindsey on 11/3/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXColorStyler.h"
#import "PXRectangle.h"

@implementation PXColorStyler

- (NSDictionary *)declarationHandlers
{
    static __strong NSDictionary *handlers = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        handlers = @{
            @"color" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                [context setPropertyValue:declaration.colorValue forName:@"color"];
            },
        };
    });

    return handlers;
}

@end
