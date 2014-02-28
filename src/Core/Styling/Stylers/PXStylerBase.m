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
//  PXStylerBase.m
//  Pixate
//
//  Created by Kevin Lindsey on 10/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXStylerBase.h"
#import "UIView+PXStyling.h"
#import "PXPseudoClassSelector.h"

@implementation PXStylerBase

#pragma mark - Initializers

- (id)initWithCompletionBlock:(PXStylerCompletionBlock)block
{
    if (self = [super init])
    {
        _completionBlock = block;
    }

    return self;
}

#pragma mark - Helper Methods

- (NSDictionary *)declarationHandlers
{
    // Subclasses need to implement this
    return nil;
}

#pragma mark - PXStyler Implementation

- (NSArray *)supportedProperties
{
    return self.declarationHandlers.allKeys;
}

- (void)processDeclaration:(PXDeclaration *)declaration withContext:(PXStylerContext *)context
{
    PXDeclarationHandlerBlock block = [[self declarationHandlers] objectForKey:declaration.name];

    if (block)
    {
        block(declaration, context);
    }
}

- (void)applyStylesWithContext:(PXStylerContext *)context
{
    if (self.completionBlock)
    {
        self.completionBlock(context.styleable, self, context);
    }
}

@end
