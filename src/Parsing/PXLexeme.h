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
//  Protostyle
//
//  Created by Kevin Lindsey on 2/3/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PXLexeme <NSObject>

@property (nonatomic, readonly) int type;
@property (nonatomic, strong, readonly) NSString *text;
@property (nonatomic, strong, readonly) NSString *name;

@property (nonatomic, strong, readonly) id value;
@property (nonatomic, readonly) NSRange range;

- (id)initWithType:(int)type text:(NSString *)text;

- (void)clearFlag:(int)type;
- (void)setFlag:(int)type;
- (BOOL)flagIsSet:(int)type;

@end
