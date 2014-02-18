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
//  PXShapeStyler.m
//  Pixate
//
//  Created by Kevin Lindsey on 12/18/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXShapeStyler.h"
#import "PXShape.h"
#import "PXEllipse.h"
#import "PXRectangle.h"
#import "PXArrowRectangle.h"

@implementation PXShapeStyler

#pragma mark - Static Methods

+ (PXShapeStyler *)sharedInstance
{
	static __strong PXShapeStyler *sharedInstance = nil;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		sharedInstance = [[PXShapeStyler alloc] init];
	});

	return sharedInstance;
}

#pragma mark - Overrides

- (NSDictionary *)declarationHandlers
{
    static __strong NSDictionary *handlers = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        handlers = @{
            @"shape" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                NSString *stringValue = declaration.stringValue;

                if ([@"ellipse" isEqualToString:stringValue])
                {
                    context.shape = [[PXEllipse alloc] init];
                }
                else if ([@"arrow-button-left" isEqualToString:stringValue])
                {
                    context.shape = [[PXArrowRectangle alloc] initWithDirection:PXArrowRectangleDirectionLeft];
                }
                else if ([@"arrow-button-right" isEqualToString:stringValue])
                {
                    context.shape = [[PXArrowRectangle alloc] initWithDirection:PXArrowRectangleDirectionRight];
                }
                else
                {
                    context.shape = [[PXRectangle alloc] init];
                }
            },
        };
    });

    return handlers;
}

@end
