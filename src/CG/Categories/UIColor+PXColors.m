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
//  UIColor+PXColors.m
//  Pixate
//
//  Created by Kevin Lindsey on 6/15/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "UIColor+PXColors.h"

void PXForceLoadUIColorPXColor() {}

@implementation UIColor (PXColors)

#pragma mark - Static Methods

+(NSDictionary *)nameMap
{
    static NSDictionary *nameMap;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        nameMap = [NSDictionary dictionaryWithObjectsAndKeys:
           [UIColor colorWithRed:240.0/255.0 green:248.0/255.0 blue:255.0/255.0 alpha:1], @"aliceblue",
           [UIColor colorWithRed:250.0/255.0 green:235.0/255.0 blue:215.0/255.0 alpha:1], @"antiquewhite",
           [UIColor colorWithRed:0.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1], @"aqua",
           [UIColor colorWithRed:127.0/255.0 green:255.0/255.0 blue:212.0/255.0 alpha:1], @"aquamarine",
           [UIColor colorWithRed:240.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1], @"azure",
           [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:220.0/255.0 alpha:1], @"beige",
           [UIColor colorWithRed:255.0/255.0 green:228.0/255.0 blue:196.0/255.0 alpha:1], @"bisque",
           [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1], @"black",
           [UIColor colorWithRed:255.0/255.0 green:235.0/255.0 blue:205.0/255.0 alpha:1], @"blanchedalmond",
           [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:255.0/255.0 alpha:1], @"blue",
           [UIColor colorWithRed:138.0/255.0 green:43.0/255.0 blue:226.0/255.0 alpha:1], @"blueviolet",
           [UIColor colorWithRed:165.0/255.0 green:42.0/255.0 blue:42.0/255.0 alpha:1], @"brown",
           [UIColor colorWithRed:222.0/255.0 green:184.0/255.0 blue:135.0/255.0 alpha:1], @"burlywood",
           [UIColor colorWithRed:95.0/255.0 green:158.0/255.0 blue:160.0/255.0 alpha:1], @"cadetblue",
           [UIColor colorWithRed:127.0/255.0 green:255.0/255.0 blue:0.0/255.0 alpha:1], @"chartreuse",
           [UIColor colorWithRed:210.0/255.0 green:105.0/255.0 blue:30.0/255.0 alpha:1], @"chocolate",
           [UIColor colorWithRed:255.0/255.0 green:127.0/255.0 blue:80.0/255.0 alpha:1], @"coral",
           [UIColor colorWithRed:100.0/255.0 green:149.0/255.0 blue:237.0/255.0 alpha:1], @"cornflowerblue",
           [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:220.0/255.0 alpha:1], @"cornsilk",
           [UIColor colorWithRed:220.0/255.0 green:20.0/255.0 blue:60.0/255.0 alpha:1], @"crimson",
           [UIColor colorWithRed:0.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1], @"cyan",
           [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:139.0/255.0 alpha:1], @"darkblue",
           [UIColor colorWithRed:0.0/255.0 green:139.0/255.0 blue:139.0/255.0 alpha:1], @"darkcyan",
           [UIColor colorWithRed:184.0/255.0 green:134.0/255.0 blue:11.0/255.0 alpha:1], @"darkgoldenrod",
           [UIColor colorWithRed:169.0/255.0 green:169.0/255.0 blue:169.0/255.0 alpha:1], @"darkgray",
           [UIColor colorWithRed:0.0/255.0 green:100.0/255.0 blue:0.0/255.0 alpha:1], @"darkgreen",
           [UIColor colorWithRed:169.0/255.0 green:169.0/255.0 blue:169.0/255.0 alpha:1], @"darkgrey",
           [UIColor colorWithRed:189.0/255.0 green:183.0/255.0 blue:107.0/255.0 alpha:1], @"darkkhaki",
           [UIColor colorWithRed:139.0/255.0 green:0.0/255.0 blue:139.0/255.0 alpha:1], @"darkmagenta",
           [UIColor colorWithRed:85.0/255.0 green:107.0/255.0 blue:47.0/255.0 alpha:1], @"darkolivegreen",
           [UIColor colorWithRed:255.0/255.0 green:140.0/255.0 blue:0.0/255.0 alpha:1], @"darkorange",
           [UIColor colorWithRed:153.0/255.0 green:50.0/255.0 blue:204.0/255.0 alpha:1], @"darkorchid",
           [UIColor colorWithRed:139.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1], @"darkred",
           [UIColor colorWithRed:233.0/255.0 green:150.0/255.0 blue:122.0/255.0 alpha:1], @"darksalmon",
           [UIColor colorWithRed:143.0/255.0 green:188.0/255.0 blue:143.0/255.0 alpha:1], @"darkseagreen",
           [UIColor colorWithRed:72.0/255.0 green:61.0/255.0 blue:139.0/255.0 alpha:1], @"darkslateblue",
           [UIColor colorWithRed:47.0/255.0 green:79.0/255.0 blue:79.0/255.0 alpha:1], @"darkslategray",
           [UIColor colorWithRed:47.0/255.0 green:79.0/255.0 blue:79.0/255.0 alpha:1], @"darkslategrey",
           [UIColor colorWithRed:0.0/255.0 green:206.0/255.0 blue:209.0/255.0 alpha:1], @"darkturquoise",
           [UIColor colorWithRed:148.0/255.0 green:0.0/255.0 blue:211.0/255.0 alpha:1], @"darkviolet",
           [UIColor colorWithRed:255.0/255.0 green:20.0/255.0 blue:147.0/255.0 alpha:1], @"deeppink",
           [UIColor colorWithRed:0.0/255.0 green:191.0/255.0 blue:255.0/255.0 alpha:1], @"deepskyblue",
           [UIColor colorWithRed:105.0/255.0 green:105.0/255.0 blue:105.0/255.0 alpha:1], @"dimgray",
           [UIColor colorWithRed:105.0/255.0 green:105.0/255.0 blue:105.0/255.0 alpha:1], @"dimgrey",
           [UIColor colorWithRed:30.0/255.0 green:144.0/255.0 blue:255.0/255.0 alpha:1], @"dodgerblue",
           [UIColor colorWithRed:178.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1], @"firebrick",
           [UIColor colorWithRed:255.0/255.0 green:250.0/255.0 blue:240.0/255.0 alpha:1], @"floralwhite",
           [UIColor colorWithRed:34.0/255.0 green:139.0/255.0 blue:34.0/255.0 alpha:1], @"forestgreen",
           [UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:255.0/255.0 alpha:1], @"fuchsia",
           [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1], @"gainsboro",
           [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:255.0/255.0 alpha:1], @"ghostwhite",
           [UIColor colorWithRed:255.0/255.0 green:215.0/255.0 blue:0.0/255.0 alpha:1], @"gold",
           [UIColor colorWithRed:218.0/255.0 green:165.0/255.0 blue:32.0/255.0 alpha:1], @"goldenrod",
           [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1], @"gray",
           [UIColor colorWithRed:0.0/255.0 green:128.0/255.0 blue:0.0/255.0 alpha:1], @"green",
           [UIColor colorWithRed:173.0/255.0 green:255.0/255.0 blue:47.0/255.0 alpha:1], @"greenyellow",
           [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1], @"grey",
           [UIColor colorWithRed:240.0/255.0 green:255.0/255.0 blue:240.0/255.0 alpha:1], @"honeydew",
           [UIColor colorWithRed:255.0/255.0 green:105.0/255.0 blue:180.0/255.0 alpha:1], @"hotpink",
           [UIColor colorWithRed:205.0/255.0 green:92.0/255.0 blue:92.0/255.0 alpha:1], @"indianred",
           [UIColor colorWithRed:75.0/255.0 green:0.0/255.0 blue:130.0/255.0 alpha:1], @"indigo",
           [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:240.0/255.0 alpha:1], @"ivory",
           [UIColor colorWithRed:240.0/255.0 green:230.0/255.0 blue:140.0/255.0 alpha:1], @"khaki",
           [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:250.0/255.0 alpha:1], @"lavender",
           [UIColor colorWithRed:255.0/255.0 green:240.0/255.0 blue:245.0/255.0 alpha:1], @"lavenderblush",
           [UIColor colorWithRed:124.0/255.0 green:252.0/255.0 blue:0.0/255.0 alpha:1], @"lawngreen",
           [UIColor colorWithRed:255.0/255.0 green:250.0/255.0 blue:205.0/255.0 alpha:1], @"lemonchiffon",
           [UIColor colorWithRed:173.0/255.0 green:216.0/255.0 blue:230.0/255.0 alpha:1], @"lightblue",
           [UIColor colorWithRed:240.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1], @"lightcoral",
           [UIColor colorWithRed:224.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1], @"lightcyan",
           [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:210.0/255.0 alpha:1], @"lightgoldenrodyellow",
           [UIColor colorWithRed:211.0/255.0 green:211.0/255.0 blue:211.0/255.0 alpha:1], @"lightgray",
           [UIColor colorWithRed:144.0/255.0 green:238.0/255.0 blue:144.0/255.0 alpha:1], @"lightgreen",
           [UIColor colorWithRed:211.0/255.0 green:211.0/255.0 blue:211.0/255.0 alpha:1], @"lightgrey",
           [UIColor colorWithRed:255.0/255.0 green:182.0/255.0 blue:193.0/255.0 alpha:1], @"lightpink",
           [UIColor colorWithRed:255.0/255.0 green:160.0/255.0 blue:122.0/255.0 alpha:1], @"lightsalmon",
           [UIColor colorWithRed:32.0/255.0 green:178.0/255.0 blue:170.0/255.0 alpha:1], @"lightseagreen",
           [UIColor colorWithRed:135.0/255.0 green:206.0/255.0 blue:250.0/255.0 alpha:1], @"lightskyblue",
           [UIColor colorWithRed:119.0/255.0 green:136.0/255.0 blue:153.0/255.0 alpha:1], @"lightslategray",
           [UIColor colorWithRed:119.0/255.0 green:136.0/255.0 blue:153.0/255.0 alpha:1], @"lightslategrey",
           [UIColor colorWithRed:176.0/255.0 green:196.0/255.0 blue:222.0/255.0 alpha:1], @"lightsteelblue",
           [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:224.0/255.0 alpha:1], @"lightyellow",
           [UIColor colorWithRed:0.0/255.0 green:255.0/255.0 blue:0.0/255.0 alpha:1], @"lime",
           [UIColor colorWithRed:50.0/255.0 green:205.0/255.0 blue:50.0/255.0 alpha:1], @"limegreen",
           [UIColor colorWithRed:250.0/255.0 green:240.0/255.0 blue:230.0/255.0 alpha:1], @"linen",
           [UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:255.0/255.0 alpha:1], @"magenta",
           [UIColor colorWithRed:128.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1], @"maroon",
           [UIColor colorWithRed:102.0/255.0 green:205.0/255.0 blue:170.0/255.0 alpha:1], @"mediumaquamarine",
           [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:205.0/255.0 alpha:1], @"mediumblue",
           [UIColor colorWithRed:186.0/255.0 green:85.0/255.0 blue:211.0/255.0 alpha:1], @"mediumorchid",
           [UIColor colorWithRed:147.0/255.0 green:112.0/255.0 blue:219.0/255.0 alpha:1], @"mediumpurple",
           [UIColor colorWithRed:60.0/255.0 green:179.0/255.0 blue:113.0/255.0 alpha:1], @"mediumseagreen",
           [UIColor colorWithRed:123.0/255.0 green:104.0/255.0 blue:238.0/255.0 alpha:1], @"mediumslateblue",
           [UIColor colorWithRed:0.0/255.0 green:250.0/255.0 blue:154.0/255.0 alpha:1], @"mediumspringgreen",
           [UIColor colorWithRed:72.0/255.0 green:209.0/255.0 blue:204.0/255.0 alpha:1], @"mediumturquoise",
           [UIColor colorWithRed:199.0/255.0 green:21.0/255.0 blue:133.0/255.0 alpha:1], @"mediumvioletred",
           [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:112.0/255.0 alpha:1], @"midnightblue",
           [UIColor colorWithRed:245.0/255.0 green:255.0/255.0 blue:250.0/255.0 alpha:1], @"mintcream",
           [UIColor colorWithRed:255.0/255.0 green:228.0/255.0 blue:225.0/255.0 alpha:1], @"mistyrose",
           [UIColor colorWithRed:255.0/255.0 green:228.0/255.0 blue:181.0/255.0 alpha:1], @"moccasin",
           [UIColor colorWithRed:255.0/255.0 green:222.0/255.0 blue:173.0/255.0 alpha:1], @"navajowhite",
           [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:128.0/255.0 alpha:1], @"navy",
           [UIColor colorWithRed:253.0/255.0 green:245.0/255.0 blue:230.0/255.0 alpha:1], @"oldlace",
           [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:0.0/255.0 alpha:1], @"olive",
           [UIColor colorWithRed:107.0/255.0 green:142.0/255.0 blue:35.0/255.0 alpha:1], @"olivedrab",
           [UIColor colorWithRed:255.0/255.0 green:165.0/255.0 blue:0.0/255.0 alpha:1], @"orange",
           [UIColor colorWithRed:255.0/255.0 green:69.0/255.0 blue:0.0/255.0 alpha:1], @"orangered",
           [UIColor colorWithRed:218.0/255.0 green:112.0/255.0 blue:214.0/255.0 alpha:1], @"orchid",
           [UIColor colorWithRed:238.0/255.0 green:232.0/255.0 blue:170.0/255.0 alpha:1], @"palegoldenrod",
           [UIColor colorWithRed:152.0/255.0 green:251.0/255.0 blue:152.0/255.0 alpha:1], @"palegreen",
           [UIColor colorWithRed:175.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1], @"paleturquoise",
           [UIColor colorWithRed:219.0/255.0 green:112.0/255.0 blue:147.0/255.0 alpha:1], @"palevioletred",
           [UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:213.0/255.0 alpha:1], @"papayawhip",
           [UIColor colorWithRed:255.0/255.0 green:218.0/255.0 blue:185.0/255.0 alpha:1], @"peachpuff",
           [UIColor colorWithRed:205.0/255.0 green:133.0/255.0 blue:63.0/255.0 alpha:1], @"peru",
           [UIColor colorWithRed:255.0/255.0 green:192.0/255.0 blue:203.0/255.0 alpha:1], @"pink",
           [UIColor colorWithRed:221.0/255.0 green:160.0/255.0 blue:221.0/255.0 alpha:1], @"plum",
           [UIColor colorWithRed:176.0/255.0 green:224.0/255.0 blue:230.0/255.0 alpha:1], @"powderblue",
           [UIColor colorWithRed:128.0/255.0 green:0.0/255.0 blue:128.0/255.0 alpha:1], @"purple",
           [UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1], @"red",
           [UIColor colorWithRed:188.0/255.0 green:143.0/255.0 blue:143.0/255.0 alpha:1], @"rosybrown",
           [UIColor colorWithRed:65.0/255.0 green:105.0/255.0 blue:225.0/255.0 alpha:1], @"royalblue",
           [UIColor colorWithRed:139.0/255.0 green:69.0/255.0 blue:19.0/255.0 alpha:1], @"saddlebrown",
           [UIColor colorWithRed:250.0/255.0 green:128.0/255.0 blue:114.0/255.0 alpha:1], @"salmon",
           [UIColor colorWithRed:244.0/255.0 green:164.0/255.0 blue:96.0/255.0 alpha:1], @"sandybrown",
           [UIColor colorWithRed:46.0/255.0 green:139.0/255.0 blue:87.0/255.0 alpha:1], @"seagreen",
           [UIColor colorWithRed:255.0/255.0 green:245.0/255.0 blue:238.0/255.0 alpha:1], @"seashell",
           [UIColor colorWithRed:160.0/255.0 green:82.0/255.0 blue:45.0/255.0 alpha:1], @"sienna",
           [UIColor colorWithRed:192.0/255.0 green:192.0/255.0 blue:192.0/255.0 alpha:1], @"silver",
           [UIColor colorWithRed:135.0/255.0 green:206.0/255.0 blue:235.0/255.0 alpha:1], @"skyblue",
           [UIColor colorWithRed:106.0/255.0 green:90.0/255.0 blue:205.0/255.0 alpha:1], @"slateblue",
           [UIColor colorWithRed:112.0/255.0 green:128.0/255.0 blue:144.0/255.0 alpha:1], @"slategray",
           [UIColor colorWithRed:112.0/255.0 green:128.0/255.0 blue:144.0/255.0 alpha:1], @"slategrey",
           [UIColor colorWithRed:255.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1], @"snow",
           [UIColor colorWithRed:0.0/255.0 green:255.0/255.0 blue:127.0/255.0 alpha:1], @"springgreen",
           [UIColor colorWithRed:70.0/255.0 green:130.0/255.0 blue:180.0/255.0 alpha:1], @"steelblue",
           [UIColor colorWithRed:210.0/255.0 green:180.0/255.0 blue:140.0/255.0 alpha:1], @"tan",
           [UIColor colorWithRed:0.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1], @"teal",
           [UIColor colorWithRed:216.0/255.0 green:191.0/255.0 blue:216.0/255.0 alpha:1], @"thistle",
           [UIColor colorWithRed:255.0/255.0 green:99.0/255.0 blue:71.0/255.0 alpha:1], @"tomato",
           [UIColor clearColor], @"transparent",
           [UIColor colorWithRed:64.0/255.0 green:224.0/255.0 blue:208.0/255.0 alpha:1], @"turquoise",
           [UIColor colorWithRed:238.0/255.0 green:130.0/255.0 blue:238.0/255.0 alpha:1], @"violet",
           [UIColor colorWithRed:245.0/255.0 green:222.0/255.0 blue:179.0/255.0 alpha:1], @"wheat",
           [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1], @"white",
           [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1], @"whitesmoke",
           [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:0.0/255.0 alpha:1], @"yellow",
           [UIColor colorWithRed:154.0/255.0 green:205.0/255.0 blue:50.0/255.0 alpha:1], @"yellowgreen",
           nil];
    });

    return nameMap;
}

+ (UIColor *)colorFromName:(NSString *)name
{
    UIColor *result = nil;

    if (name.length > 0)
    {
        result = [[UIColor nameMap] objectForKey:[name lowercaseString]];

        if (result == nil)
        {
            // convert to camel case
            name = [self toCamelCase:name];

            Class colorClass = [UIColor class];
            NSString *selectorName = ([name hasSuffix:@"Color"] == NO) ? [NSString stringWithFormat:@"%@Color", name] : name;
            SEL selector = NSSelectorFromString(selectorName);

            if ([colorClass respondsToSelector:selector])
            {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                id candidate = [colorClass performSelector:selector];
#pragma clang diagnostic pop

                if ([candidate isKindOfClass:colorClass])
                {
                    result = candidate;
                }
            }
        }
    }

    return (result) ? result : [UIColor blackColor];
}

+ (NSString *)toCamelCase:(NSString *)source
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"-([a-z])"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];
    NSMutableString *result = [NSMutableString stringWithString:source];

    // keep track of how many additional characters we've added (1 per iteration)
    __block NSUInteger count = 0;

    [regex enumerateMatchesInString:source
                            options:0
                              range:NSMakeRange(0, [source length])
                         usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
                             NSString *character = [source substringWithRange:[match rangeAtIndex:1]];
                             NSString *upperCharacter = [character uppercaseString];

                             // every iteration, the output string is getting longer
                             // so we need to adjust the range that we are editing
                             NSRange updateRange = NSMakeRange(match.range.location - count, match.range.length);
                             [result replaceCharactersInRange:updateRange withString:upperCharacter];

                             count++;
                         }];

    return result;
}

+ (UIColor *)colorWithHue:(CGFloat)hue saturation:(CGFloat)saturation lightness:(CGFloat)lightness
{
    return [UIColor colorWithHue:hue saturation:saturation lightness:lightness alpha:1.0];
}

+ (UIColor *)colorWithHue:(CGFloat)hue saturation:(CGFloat)saturation lightness:(CGFloat)lightness alpha:(CGFloat)alpha
{
    float hh = hue;
    float ss = saturation;
    float ll = lightness;

    float h, s, v;

    h = hh;
    ll *= 2;
    ss *= (ll <= 1) ? ll : 2 - ll;
    v = (ll + ss) / 2;
    s = ((ll + ss) != 0) ? (2 * ss) / (ll + ss) : 0;

    return [UIColor colorWithHue:h saturation:s brightness:v alpha:alpha];
}

+ (UIColor *) colorWithHexString:(NSString *)hexString
{
    return [UIColor colorWithHexString:hexString withAlpha:1.0];
}

+ (UIColor *) colorWithHexString:(NSString *)hexString withAlpha:(CGFloat)alpha
{
    uint value = 0;

    if (hexString)
    {
        int startingIndex = ([hexString hasPrefix:@"#"]) ? 1 : 0;
        BOOL useSuppliedAlpha = YES;

        if (hexString.length - startingIndex == 3)
        {
            NSString *h1 = [hexString substringWithRange:NSMakeRange(0 + startingIndex, 1)];
            NSString *h2 = [hexString substringWithRange:NSMakeRange(1 + startingIndex, 1)];
            NSString *h3 = [hexString substringWithRange:NSMakeRange(2 + startingIndex, 1)];

            hexString = [NSString stringWithFormat:@"%@%@%@%@%@%@", h1, h1, h2, h2, h3, h3];

            startingIndex = 0;
        }
        else if (hexString.length - startingIndex == 4)
        {
            NSString *h1 = [hexString substringWithRange:NSMakeRange(0 + startingIndex, 1)];
            NSString *h2 = [hexString substringWithRange:NSMakeRange(1 + startingIndex, 1)];
            NSString *h3 = [hexString substringWithRange:NSMakeRange(2 + startingIndex, 1)];
            NSString *h4 = [hexString substringWithRange:NSMakeRange(3 + startingIndex, 1)];

            hexString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@", h1, h1, h2, h2, h3, h3, h4, h4];

            startingIndex = 0;
            useSuppliedAlpha = NO;
        }
        else if (hexString.length - startingIndex == 8)
        {
            useSuppliedAlpha = NO;
        }

        [[NSScanner scannerWithString:[hexString substringFromIndex:startingIndex]] scanHexInt:&value];

        if (useSuppliedAlpha)
        {
            // clip to bounds
            alpha = MIN(MAX(0.0, alpha), 1.0);
            uint alphaByte = (uint) (alpha * 255.0);

            value |= (alphaByte << 24);
        }
    }

    return [UIColor colorWithARGBValue:value];
}

+ (UIColor *)colorWithARGBValue:(uint)value
{
    uint a = (value & 0xFF000000) >> 24;
    uint r = (value & 0x00FF0000) >> 16;
    uint g = (value & 0x0000FF00) >> 8;
    uint b = (value & 0x000000FF);

    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a/255.0];
}

+ (UIColor *)colorWithRGBAValue:(uint)value
{
    uint r = (value & 0xFF000000) >> 24;
    uint g = (value & 0x00FF0000) >> 16;
    uint b = (value & 0x0000FF00) >> 8;
    uint a = (value & 0x000000FF);

    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a/255.0];
}

+ (UIColor *)colorWithRGBValue:(uint)value
{
    uint r = (value & 0x00FF0000) >> 16;
    uint g = (value & 0x0000FF00) >> 8;
    uint b = (value & 0x000000FF);

    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
}

#pragma mark - Methods

- (BOOL)getHue:(CGFloat *)hue saturation:(CGFloat *)saturation lightness:(CGFloat *)lightness alpha:(CGFloat *)alpha;
{
    CGFloat r, g, b;
    BOOL result = NO;

    if ([self getRed:&r green:&g blue:&b alpha:alpha])
    {
        float max = MAX(MAX(r, g), b);
        float min = MIN(MIN(r, g), b);

        float h = 0.0f;
        float s = 0.0f;
        float l = (min + max) * 0.5f;

        if (l > 0.0f)
        {
            float range = max - min;

            s = range;

            if (s > 0.0f)
            {
                s /= (l <= 0.5f) ? (max + min) : (2.0f - max - min);

                float r2 = (max - r) / range;
                float g2 = (max - g) / range;
                float b2 = (max - b) / range;

                if (r == max)
                {
                    h = (g == min ? 5.0f + b2 : 1.0f - g2);
                }
                else if (g == max)
                {
                    h = (b == min ? 1.0f + r2 : 3.0 - b2);
                }
                else
                {
                    h = (r == min ? 3.0f + g2 : 5.0f - r2);
                }

                h /= 6.0f;

            }

            *hue = h;
            *saturation = s;
            *lightness = l;

            result = YES;

        }
    }


    return result;
}

- (BOOL)isOpaque
{
    CGFloat red, green, blue, alpha;

    BOOL success = [self getRed:&red green:&green blue:&blue alpha:&alpha];

    if(!success)
    {
        success = [self getWhite:&red alpha:&alpha];
    }

    return success ? (alpha == 1.0f) : NO;
}

- (UIColor *)lightenByPercent:(CGFloat)percent
{
    CGFloat hue, saturation, lightness, alpha;

    [self getHue:&hue saturation:&saturation lightness:&lightness alpha:&alpha];

    lightness = MIN(1.0f, lightness + percent * 0.01f);

    return [UIColor colorWithHue:hue saturation:saturation lightness:lightness alpha:alpha];
}

- (UIColor *)darkenByPercent:(CGFloat)percent
{
    CGFloat hue, saturation, lightness, alpha;

    [self getHue:&hue saturation:&saturation lightness:&lightness alpha:&alpha];

    lightness = MAX(0.0f, lightness - percent * 0.01f);

    return [UIColor colorWithHue:hue saturation:saturation lightness:lightness alpha:alpha];
}

@end
