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
//  PXDeclarationContainer.m
//  Pixate
//
//  Created by Kevin Lindsey on 3/5/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXDeclarationContainer.h"

@implementation PXDeclarationContainer
{
    NSMutableArray *declarations_;
    NSMutableSet *names_;
}

#pragma mark - Methods

- (void)addDeclaration:(PXDeclaration *)declaration
{
    if (declaration != nil)
    {
        if (declarations_ == nil)
        {
            declarations_ = [NSMutableArray array];
            names_ = [NSMutableSet set];
        }

        // check for dups
        PXDeclaration *addedDeclaration = [self declarationForName:declaration.name];

        // declarations that come later win, unless the earlier one is important and this new one is not
        if (addedDeclaration != nil)
        {
            if (addedDeclaration.important == NO || declaration.important)
            {
                [self removeDeclaration:addedDeclaration];
            }
        }

        [declarations_ addObject:declaration];
        [names_ addObject:declaration.name];
    }
}

- (void)removeDeclaration:(PXDeclaration *)declaration
{
    if (declaration && declarations_)
    {
        [declarations_ removeObject:declaration];
        [names_ removeObject:declaration.name];
    }
}

- (PXDeclaration *)declarationForName:(NSString *)name
{
    PXDeclaration *result = nil;

    for (PXDeclaration *declaration in declarations_)
    {
        if ([declaration.name isEqualToString:name])
        {
            result = declaration;
            break;
        }
    }

    return result;
}

#pragma mark - Getters

- (NSArray *)declarations
{
    return [NSArray arrayWithArray:declarations_];
}

- (BOOL)hasDeclarationForName:(NSString *)name
{
    return [names_ containsObject:name];
}

@end
