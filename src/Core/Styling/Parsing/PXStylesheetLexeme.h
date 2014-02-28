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
//  PXLexeme.h
//  Pixate
//
//  Created by Kevin Lindsey on 6/23/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXLexeme.h"

typedef enum {
    PXLexemeFlagFollowsWhitespace = 1
} PXLexemeFlagType;

@interface PXStylesheetLexeme : NSObject <PXLexeme>

+ (id)lexemeWithType:(int)type;
+ (id)lexemeWithType:(int)type withRange:(NSRange)range;
+ (id)lexemeWithType:(int)type withValue:(id)value;
+ (id)lexemeWithType:(int)type withRange:(NSRange)range withValue:(id)value;

- (id)initWithType:(int)type withRange:(NSRange)range withValue:(id)value;

@end
