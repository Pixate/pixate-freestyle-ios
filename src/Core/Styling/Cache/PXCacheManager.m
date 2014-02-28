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
//  PXCacheManager.m
//  Pixate
//
//  Created by Kevin Lindsey on 10/7/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXCacheManager.h"
#import "PixateFreestyle.h"

static NSCache *IMAGE_CACHE;
static NSCache *STYLE_CACHE;

@implementation PXCacheManager

#pragma mark - Static Methods

+(void)initialize
{
    IMAGE_CACHE = [[NSCache alloc] init];
    IMAGE_CACHE.name = @"Pixate Image Cache";
    IMAGE_CACHE.countLimit = PixateFreestyle.configuration.imageCacheCount;
    IMAGE_CACHE.totalCostLimit = PixateFreestyle.configuration.imageCacheSize;

    STYLE_CACHE = [[NSCache alloc] init];
    STYLE_CACHE.name = @"Pixate Style Cache";
    STYLE_CACHE.countLimit = PixateFreestyle.configuration.styleCacheCount;
}

+ (UIImage *)imageForKey:(NSNumber *)key
{
    return (key != nil) ? [IMAGE_CACHE objectForKey:key] : nil;
}

+ (PXStyleTreeInfo *)styleTreeInfoForKey:(NSString *)key
{
    return (key != nil) ? [STYLE_CACHE objectForKey:key] : nil;
}

+ (void)setImage:(UIImage *)image forKey:(NSNumber *)key cost:(NSUInteger)cost
{
    if (image != nil && key != nil)
    {
        [IMAGE_CACHE setObject:image forKey:key cost:cost];
    }
}

+ (void)setStyleTreeInfo:(PXStyleTreeInfo *)styleTreeInfo forKey:(NSString *)key
{
    if (styleTreeInfo != nil && key.length > 0)
    {
        [STYLE_CACHE setObject:styleTreeInfo forKey:key];
    }
}

+ (NSUInteger)imageCacheCount
{
    return IMAGE_CACHE.countLimit;
}

+ (NSUInteger)imageCacheSize
{
    return IMAGE_CACHE.totalCostLimit;
}

+ (void)setImageCacheCount:(NSUInteger)count
{
    IMAGE_CACHE.countLimit = count;
}

+ (void)setImageCacheSize:(NSUInteger)size
{
    IMAGE_CACHE.totalCostLimit = size;
}

+ (NSUInteger)styleCacheCount
{
    return STYLE_CACHE.countLimit;
}

+ (void)setStyleCacheCount:(NSUInteger)count
{
    STYLE_CACHE.countLimit = count;
}

+ (void)clearImageCache
{
    if (IMAGE_CACHE != nil)
    {
        [IMAGE_CACHE removeAllObjects];
    }
}

+ (void)clearStyleCache
{
    if (STYLE_CACHE != nil)
    {
        [STYLE_CACHE removeAllObjects];
    }
}

+ (void)clearAllCaches
{
    [self clearImageCache];
    [self clearStyleCache];
}

@end
