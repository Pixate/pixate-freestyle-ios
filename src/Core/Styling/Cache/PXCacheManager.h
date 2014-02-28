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
//  PXCacheManager.h
//  Pixate
//
//  Created by Kevin Lindsey on 10/7/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXStyleTreeInfo.h"

@interface PXCacheManager : NSObject

+ (UIImage *)imageForKey:(NSNumber *)key;
+ (void)setImage:(UIImage *)image forKey:(NSNumber *)key cost:(NSUInteger)cost;
+ (void)clearImageCache;
+ (NSUInteger)imageCacheCount;
+ (NSUInteger)imageCacheSize;
+ (void)setImageCacheCount:(NSUInteger)count;
+ (void)setImageCacheSize:(NSUInteger)size;

+ (PXStyleTreeInfo *)styleTreeInfoForKey:(NSString *)key;
+ (void)setStyleTreeInfo:(PXStyleTreeInfo *)styleTreeInfo forKey:(NSString *)key;
+ (void)clearStyleCache;
+ (NSUInteger)styleCacheCount;
+ (void)setStyleCacheCount:(NSUInteger)count;

+ (void)clearAllCaches;

@end
