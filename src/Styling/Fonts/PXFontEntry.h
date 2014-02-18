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
//  PXFontEntry.h
//  Pixate
//
//  Created by Kevin Lindsey on 10/25/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PXFontEntry : NSObject

@property (readonly, nonatomic) NSString *family;
@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) NSInteger weight;
@property (readonly, nonatomic) NSInteger stretch;
@property (readonly, nonatomic) NSString *style;

+ (NSInteger)indexFromStretchName:(NSString *)name;
+ (NSInteger)indexFromWeightName:(NSString *)name;

+ (NSArray *)fontEntriesForFamily:(NSString *)family;
+ (NSArray *)filterEntries:(NSArray *)entries byStretch:(NSInteger)fontStretch;
+ (NSArray *)filterEntries:(NSArray *)entries byStyle:(NSString *)style;
+ (NSArray *)filterEntries:(NSArray *)entries byWeight:(NSInteger)weight;

- (id)initWithFontFamily:(NSString *)family fontName:(NSString *)name;

@end
