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
//  PXFileUtils.h
//  Pixate
//
//  Created by Kevin Lindsey on 12/1/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  A collection of utility methods to assist in file-related operations
 */
@interface PXFileUtils : NSObject

/**
 *  Return the text content of a local resource
 *
 *  @param resource The name of the local resource
 *  @param type The file type of the local resource
 */
+ (NSString *)sourceFromResource:(NSString *)resource ofType:(NSString *)type;

/**
 *  Return the text content of a file at a specified path
 *
 *  @param path The path of the file
 */
+ (NSString *)sourceFromPath:(NSString *)path;

@end
