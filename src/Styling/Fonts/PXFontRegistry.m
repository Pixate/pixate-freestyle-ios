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
//  PXFontRegistry.m
//  Pixate
//
//  Created by Kevin Lindsey on 9/21/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXFontRegistry.h"
#import "PXFontEntry.h"
#import <CoreText/CTFontManager.h>

@implementation PXFontRegistry

static NSMutableDictionary *REGISTRY;
static NSMutableSet *LOADED_FONTS;

+ (void)initialize
{
    if (!REGISTRY)
    {
        REGISTRY = [[NSMutableDictionary alloc] init];
        LOADED_FONTS = [[NSMutableSet alloc] init];
    }
}

+ (void)clearRegistry
{
    [REGISTRY removeAllObjects];
}

+ (UIFont *)fontWithFamily:(NSString *)family
               fontStretch:(NSString *)stretch
                fontWeight:(NSString *)weight
                 fontStyle:(NSString *)style
                      size:(CGFloat)size
{
    NSString *key = [self keyFromFamily:family stretch:stretch weight:weight style:style];
    id match = [REGISTRY objectForKey:key];

    if (!match)
    {
        NSArray *infos = [PXFontEntry fontEntriesForFamily:family];
        infos = [PXFontEntry filterEntries:infos byStretch:[PXFontEntry indexFromStretchName:stretch]];
        infos = [PXFontEntry filterEntries:infos byStyle:style];
        infos = [PXFontEntry filterEntries:infos byWeight:[PXFontEntry indexFromWeightName:weight]];

        // save result so won't do the rather expensive lookup process again
        if (infos.count > 0)
        {
            PXFontEntry *info = [infos objectAtIndex:0];

            match = info.name;
            [REGISTRY setObject:info.name forKey:key];
        }
        else
        {
            // store an NSNull as a surrogate for nil
            [REGISTRY setObject:[NSNull null] forKey:key];
        }
    }
    else if (match == [NSNull null])
    {
        // We already tried to look this one up and we got nothing, so update match to nil to indicate that
        match = nil;
    }

    // cast
    NSString *result = match;

    return (result) ? [UIFont fontWithName:result size:size] : nil;
}

+ (NSString *)keyFromFamily:(NSString *)family stretch:(NSString *)stretch weight:(NSString *)weight style:(NSString *)style
{
    return [NSString stringWithFormat:@"%@:%@:%@:%@", family, stretch, weight, style];
}

+ (void)loadFontFromURL:(NSURL *)URL
{
    if (URL != nil && [LOADED_FONTS containsObject:URL] == NO)
    {
        [LOADED_FONTS addObject:URL];

        NSData *data = [NSData dataWithContentsOfURL:URL];

        if (data != nil)
        {
            CFErrorRef error;
            CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
            CGFontRef font = CGFontCreateWithDataProvider(provider);

            if (!CTFontManagerRegisterGraphicsFont(font, &error))
            {
                CFStringRef errorDescription = CFErrorCopyDescription(error);
                NSLog(@"Failed to load font: %@", errorDescription);
                CFRelease(errorDescription);
            }

            CFRelease(font);
            CFRelease(provider);
        }
    }
}

@end
