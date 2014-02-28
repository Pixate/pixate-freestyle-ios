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
//  PXTransformLexer.h
//  Pixate
//
//  Created by Kevin Lindsey on 7/27/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXStylesheetLexeme.h"

/**
 *  The PXTransformLexer is reponsible for converting a string into a stream of tokens needed to parse SVG transform
 *  values.
 */
@interface PXTransformLexer : NSObject

/**
 *  The source string to be scanned.
 */
@property (nonatomic, strong) NSString *source;

/**
 *  Initialize a new instance using the specified source string
 *
 *  @param source The sourse string to scane
 */
- (id)initWithString:(NSString *)source;

/**
 *  Return the next lexeme in the stream. This returns nil when no more tokens can be matched.
 */
- (PXStylesheetLexeme *)nextLexeme;

@end
