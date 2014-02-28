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
//  PXDeclarationContainer.h
//  Pixate
//
//  Created by Kevin Lindsey on 3/5/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXDeclaration.h"

@interface PXDeclarationContainer : NSObject

@property (readonly, nonatomic) NSArray *declarations;

/**
 *  Add a declaration to the list of declarations associated with this container
 *
 *  @param declaration The declaration to add
 */
- (void)addDeclaration:(PXDeclaration *)declaration;

/**
 *  Remove the specified declaration from this container
 */
- (void)removeDeclaration:(PXDeclaration *)declaration;

/**
 *  A predicate used to determine if this container contains a declaration for a given property name
 *
 *  @param name The name of the property to look for
 */
- (BOOL)hasDeclarationForName:(NSString *)name;

/**
 *  Return the declaration associated with a specified name. Nil will be returned if the container does not contain a
 *  declaration for the given name.
 *
 *  @param name The name of the property to return
 */
- (PXDeclaration *)declarationForName:(NSString *)name;

@end
