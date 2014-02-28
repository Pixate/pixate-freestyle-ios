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
//  PXBoxShadowStyler.m
//  Pixate
//
//  Created by Kevin Lindsey on 12/18/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXBoxShadowStyler.h"

@implementation PXBoxShadowStyler

#pragma mark - Static Methods

+ (PXBoxShadowStyler *)sharedInstance
{
	static __strong PXBoxShadowStyler *sharedInstance = nil;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		sharedInstance = [[PXBoxShadowStyler alloc] init];
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
            @"box-shadow" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                context.shadow = declaration.shadowValue;
            }
        };
    });

    return handlers;
}

- (void)applyStylesWithContext:(PXStylerContext *)context
{
    if (self.completionBlock)
    {
        [super applyStylesWithContext:context];
    }
    else
    {
        id<PXStyleable> styleable = context.styleable;

        if ([styleable isKindOfClass:[UIView class]])
        {
            [context applyOuterShadowToLayer:((UIView *)styleable).layer];
        }
    }
}

@end
