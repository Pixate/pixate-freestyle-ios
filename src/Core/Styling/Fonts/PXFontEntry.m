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
//  PXFontEntry.m
//  Pixate
//
//  Created by Kevin Lindsey on 10/25/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXFontEntry.h"

@implementation PXFontEntry

static NSArray *STRETCH;
static NSDictionary *WEIGHT_MAP;
static NSRegularExpression *DIGIT_PATTERN;
static NSRegularExpression *DIGIT_WEIGHT;

#pragma mark - Static Methods

+ (void)initialize
{
    if (!STRETCH)
    {
        STRETCH = @[
            @"ultra-condensed",
            @"extra-condensed",
            @"condensed",
            @"semi-condensed",
            @"normal",
            @"semi-expanded",
            @"expanded",
            @"extra-expanded",
            @"ultra-expanded"
        ];
    }

    if (!WEIGHT_MAP)
    {
        WEIGHT_MAP = @{
            @"black" : @(900),
            @"heavy" : @(900),
            @"extra-bold" : @(800),
            @"ultra-bold" : @(800),
            @"bold" : @(700),
            @"semi-bold" : @(600),
            @"demi-bold" : @(600),
            @"medium" : @(500),
            @"normal" : @(400),
            @"light" : @(300),
            @"extra-thin" : @(200),
            @"ultra-thin" : @(200),
            @"ultra-light" : @(200),
            @"thin" : @(100),
        };
    }

    if (!DIGIT_PATTERN)
    {
        NSError *error = NULL;

        DIGIT_PATTERN = [NSRegularExpression regularExpressionWithPattern:@"^\\s*[0-9]+\\s*$"
                                                                  options:0
                                                                    error:&error];
        DIGIT_WEIGHT = [NSRegularExpression regularExpressionWithPattern:@"-([1-9]00)$"
                                                                 options:0
                                                                   error:&error];
    }
}

+ (NSInteger)indexFromStretchName:(NSString *)name
{
    NSUInteger index = [STRETCH indexOfObject:name];

    if (index == NSNotFound)
    {
        index = [STRETCH indexOfObject:@"normal"];
    }

    return index;
}

+ (NSInteger)indexFromWeightName:(NSString *)name
{
    // default to normal
    NSInteger result = 400;
    NSNumber *weight = [WEIGHT_MAP objectForKey:name];

    if (weight)
    {
        result = [weight integerValue];
    }
    else
    {
        NSRange range = [DIGIT_PATTERN rangeOfFirstMatchInString:name options:0 range:NSMakeRange(0, [name length])];

        if (range.location != NSNotFound)
        {
            result = [name integerValue];
        }
    }

    return result;
}

#pragma mark - Filter methods

+ (NSArray *)fontEntriesForFamily:(NSString *)family
{
    NSMutableArray *infos = [[NSMutableArray alloc] init];

    for (NSString *fontName in [UIFont fontNamesForFamilyName:family])
    {
        [infos addObject:[[PXFontEntry alloc] initWithFontFamily:family fontName:fontName]];
    }

    return infos;
}

+ (NSArray *)filterEntries:(NSArray *)entries byStretch:(NSInteger)fontStretch
{
    // sort by stretch
    NSArray *sortedInfos = [entries sortedArrayUsingComparator:^NSComparisonResult(PXFontEntry *obj1, PXFontEntry *obj2) {
        NSInteger diff1 = obj1.stretch - fontStretch;
        NSInteger diff2 = obj2.stretch - fontStretch;
        NSInteger abs1 = ABS(diff1);
        NSInteger abs2 = ABS(diff2);

        if (abs1 < abs2)
        {
            return NSOrderedAscending;
        }
        else if (abs1 > abs2)
        {
            return NSOrderedDescending;
        }
        else
        {
            // when absolute values of diffs are the same, but the diffs are in opposite directions, then we need to
            // prefer thinner to bolder
            if (diff1 == diff2)
            {
                return NSOrderedSame;
            }
            else if (fontStretch <= 4)
            {
                return NSOrderedAscending;
            }
            else
            {
                return NSOrderedDescending;
            }
        }
    }];

    NSMutableArray *result = [[NSMutableArray alloc] init];

    if (sortedInfos.count > 0)
    {
        PXFontEntry *first = [sortedInfos objectAtIndex:0];
        NSInteger diff = first.stretch - fontStretch;

        [sortedInfos enumerateObjectsUsingBlock:^(PXFontEntry *obj, NSUInteger idx, BOOL *stop) {
            if ((obj.stretch - fontStretch) == diff)
            {
                [result addObject:obj];
            }
            else
            {
                *stop = YES;
            }
        }];
    }

    return result;
}

+ (NSArray *)filterEntries:(NSArray *)entries byStyle:(NSString *)style
{
    NSInteger normal, italic, oblique;

    // determine relative style values
    if ([@"italic" isEqualToString:style])
    {
        italic = 0;
        oblique = 1;
        normal = 2;
    }
    else if ([@"oblique" isEqualToString:style])
    {
        oblique = 0;
        italic = 1;
        normal = 2;
    }
    else
    {
        // assume "normal"
        normal = 0;
        italic = 1;
        oblique = 2;
    }

    // convert a style name to a relative style value
    NSInteger (^styleToInteger)(NSString *) = ^NSInteger(NSString *style) {
        if ([@"italic" isEqualToString:style])
        {
            return italic;
        }
        else if ([@"oblique" isEqualToString:style])
        {
            return oblique;
        }
        else
        {
            return normal;
        }
    };

    // sort by proximity to style
    NSInteger styleValue = styleToInteger(style);

    NSArray *sortedItalics = [entries sortedArrayUsingComparator:^NSComparisonResult(PXFontEntry *obj1, PXFontEntry *obj2) {
        NSInteger style1 = styleToInteger(obj1.style) - styleValue;
        NSInteger style2 = styleToInteger(obj2.style) - styleValue;
        NSInteger abs1 = ABS(style1);
        NSInteger abs2 = ABS(style2);

        if (abs1 < abs2)
        {
            return NSOrderedAscending;
        }
        else if (abs1 > abs2)
        {
            return NSOrderedDescending;
        }
        else
        {
            if (style1 == style2)
            {
                return NSOrderedSame;
            }
            else if (style1 < style2)
            {
                return NSOrderedAscending;
            }
            else
            {
                return NSOrderedDescending;
            }
        }
    }];

    NSMutableArray *result = [[NSMutableArray alloc] init];

    if (sortedItalics.count > 0)
    {
        PXFontEntry *first = [sortedItalics objectAtIndex:0];
        NSInteger diff = styleToInteger(first.style) - styleValue;

        [sortedItalics enumerateObjectsUsingBlock:^(PXFontEntry *obj, NSUInteger idx, BOOL *stop) {
            if ((styleToInteger(obj.style) - styleValue) == diff)
            {
                [result addObject:obj];
            }
            else
            {
                *stop = YES;
            }
        }];
    }

    return result;
}

+ (NSArray *)filterEntries:(NSArray *)entries byWeight:(NSInteger)weight
{
    // sort by weight
    NSArray *sortedInfos = [entries sortedArrayUsingComparator:^NSComparisonResult(PXFontEntry *obj1, PXFontEntry *obj2) {
        NSInteger diff1 = obj1.weight - weight;
        NSInteger diff2 = obj2.weight - weight;
        NSInteger abs1 = ABS(diff1);
        NSInteger abs2 = ABS(diff2);

        if (abs1 < abs2)
        {
            return NSOrderedAscending;
        }
        else if (abs1 > abs2)
        {
            return NSOrderedDescending;
        }
        else
        {
            // when absolute values of diffs are the same, but the diffs are in opposite directions, then we need to
            // prefer thinner to bolder
            if (diff1 == diff2)
            {
                return NSOrderedSame;
            }
            else if (weight <= 400)
            {
                return NSOrderedAscending;
            }
            else
            {
                return NSOrderedDescending;
            }
        }
    }];

    NSMutableArray *result = [[NSMutableArray alloc] init];

    if (sortedInfos.count > 0)
    {
        PXFontEntry *first = [sortedInfos objectAtIndex:0];
        NSInteger diff = first.weight - weight;

        [sortedInfos enumerateObjectsUsingBlock:^(PXFontEntry *obj, NSUInteger idx, BOOL *stop) {
            if ((obj.weight - weight) == diff)
            {
                [result addObject:obj];
            }
            else
            {
                *stop = YES;
            }
        }];
    }

    return result;
}

#pragma mark - Initializers

- (id)initWithFontFamily:(NSString *)family fontName:(NSString *)name
{
    if (self = [super init])
    {
        _family = family;
        _name = name;
        _weight = [self weightForFontName:name];
        _stretch = [self stretchForFontName:name];
        _style = [self styleForFontName:name];
    }

    return self;
}

#pragma mark - Helper Methods

- (NSInteger)weightForFontName:(NSString *)name
{
    NSInteger result;

    // see if the weight number is included in the name
    NSArray *matches = [DIGIT_WEIGHT matchesInString:name options:0 range:NSMakeRange(0, name.length)];

    if (matches.count > 0)
    {
        NSTextCheckingResult *match = [matches objectAtIndex:0];
        NSString *number = [name substringWithRange:[match rangeAtIndex:1]];

        result = [number integerValue];
    }
    else
    {
        name = [name lowercaseString];

        if ([name rangeOfString:@"black"].location != NSNotFound || [name rangeOfString:@"heavy"].location != NSNotFound)
        {
            result = 900;
        }
        else if ([name rangeOfString:@"extrabold"].location != NSNotFound || [name rangeOfString:@"ultrabold"].location != NSNotFound)
        {
            result = 800;
        }
        else if ([name rangeOfString:@"semibold"].location != NSNotFound || [name rangeOfString:@"demibold"].location != NSNotFound)
        {
            result = 600;
        }
        else if ([name rangeOfString:@"bold"].location != NSNotFound)
        {
            result = 700;
        }
        else if ([name rangeOfString:@"medium"].location != NSNotFound)
        {
            result = 500;
        }
        // NOTE: "normal" is the default below
        else if ([name rangeOfString:@"light"].location != NSNotFound && [name rangeOfString:@"ultralight"].location == NSNotFound)
        {
            result = 300;
        }
        else if (
                [name rangeOfString:@"extrathin"].location != NSNotFound
            ||  [name rangeOfString:@"ultrathin"].location != NSNotFound
            ||  [name rangeOfString:@"ultralight"].location != NSNotFound)
        {
            result = 200;
        }
        else if ([name rangeOfString:@"thin"].location != NSNotFound)
        {
            result = 100;
        }
        else
        {
            // default to "normal"
            result = 400;
        }
    }

    return result;
}

- (NSInteger)stretchForFontName:(NSString *)name
{
    NSInteger result;

    name = [name lowercaseString];

    if ([name rangeOfString:@"ultracondensed"].location != NSNotFound)
    {
        result = 0;
    }
    else if ([name rangeOfString:@"extracondensed"].location != NSNotFound)
    {
        result = 1;
    }
    else if ([name rangeOfString:@"condensed"].location != NSNotFound)
    {
        result = 2;
    }
    else if ([name rangeOfString:@"semicondensed"].location != NSNotFound)
    {
        result = 3;
    }
    // NOTE: "normal" is the default below
    else if ([name rangeOfString:@"semiexpanded"].location != NSNotFound)
    {
        result = 5;
    }
    else if ([name rangeOfString:@"expanded"].location != NSNotFound)
    {
        result = 6;
    }
    else if ([name rangeOfString:@"extraexpanded"].location != NSNotFound)
    {
        result = 7;
    }
    else if ([name rangeOfString:@"ultraexpanded"].location != NSNotFound)
    {
        result = 8;
    }
    else
    {
        // default to "normal"
        result = 4;
    }

    return result;
}

- (NSString *)styleForFontName:(NSString *)name
{
    NSString *result;

    name = [name lowercaseString];

    if ([name rangeOfString:@"italic"].location != NSNotFound)
    {
        result = @"italic";
    }
    else if ([name rangeOfString:@"oblique"].location != NSNotFound)
    {
        result = @"oblique";
    }
    else
    {
        result = @"normal";
    }

    return result;
}

#pragma mark - Overrides

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@[family=%@, stretch=%ld, weight=%ld, style=%@]", _name, _family, (long) _stretch, (long) _weight, _style];
}

@end
